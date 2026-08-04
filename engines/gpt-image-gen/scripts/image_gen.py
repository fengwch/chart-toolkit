#!/usr/bin/env python3
"""CLI for image generation or editing with GPT Image models.

Supports gpt-image-2 and compatible models via OpenAI API or proxy providers.
Reads OPENAI_API_KEY, OPENAI_BASE_URL, and CODEX_PPT_IMAGE_MODEL env vars.
"""

from __future__ import annotations

import argparse
import asyncio
import base64
from io import BytesIO
import json
import os
from pathlib import Path
import re
import sys
import time
from typing import Any, Dict, Iterable, List, Optional, Tuple
from urllib.parse import urlparse

from image_providers import create_image_provider
from image_providers.atlascloud import atlascloud_model_for_operation

DEFAULT_MODEL = "gpt-image-2"
DEFAULT_SIZE = "1536x1024"
DEFAULT_QUALITY = "medium"
DEFAULT_OUTPUT_FORMAT = "png"
DEFAULT_CONCURRENCY = 5
DEFAULT_OUTPUT_PATH = "output/image.png"
GPT_IMAGE_MODEL_PREFIX = "gpt-image-"

ALLOWED_LEGACY_SIZES = {"1024x1024", "1536x1024", "1024x1536", "auto"}
ALLOWED_QUALITIES = {"low", "medium", "high", "auto"}
ALLOWED_BACKGROUNDS = {"transparent", "opaque", "auto", None}
ALLOWED_INPUT_FIDELITIES = {"low", "high", None}

GPT_IMAGE_2_MODEL = "gpt-image-2"
GPT_IMAGE_2_MIN_PIXELS = 655_360
GPT_IMAGE_2_MAX_PIXELS = 8_294_400
GPT_IMAGE_2_MAX_EDGE = 3840
GPT_IMAGE_2_MAX_RATIO = 3.0

MAX_IMAGE_BYTES = 50 * 1024 * 1024
MAX_BATCH_JOBS = 500
ENV_FIELDS = ("OPENAI_API_KEY", "OPENAI_BASE_URL", "CODEX_PPT_IMAGE_MODEL")


def _die(message: str, code: int = 1) -> None:
    print(f"Error: {message}", file=sys.stderr)
    raise SystemExit(code)


def _warn(message: str) -> None:
    print(f"Warning: {message}", file=sys.stderr)


def _load_dotenv() -> None:
    """Load .env from engine directory if present."""
    path = Path(__file__).resolve().parent.parent / ".env"
    if not path.exists():
        return
    for raw in path.read_text(encoding="utf-8").splitlines():
        line = raw.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, value = line.split("=", 1)
        key = key.strip()
        if key not in ENV_FIELDS or os.getenv(key):
            continue
        value = value.strip().strip('"').strip("'")
        os.environ[key] = value


def _default_model() -> str:
    return os.getenv("CODEX_PPT_IMAGE_MODEL", DEFAULT_MODEL)


def _api_base_url() -> Optional[str]:
    return os.getenv("OPENAI_BASE_URL") or None


def _api_target_label() -> str:
    base_url = _api_base_url()
    if base_url:
        hostname = urlparse(base_url).hostname or ""
        if "atlascloud.ai" in hostname.lower():
            return f"AtlasCloud (OPENAI_BASE_URL={base_url})"
        return f"OpenAI-compatible proxy (OPENAI_BASE_URL={base_url})"
    return "OpenAI API"


def _ensure_api_key(dry_run: bool) -> None:
    if os.getenv("OPENAI_API_KEY"):
        print(f"API target: {_api_target_label()}", file=sys.stderr)
        return
    if dry_run:
        _warn("OPENAI_API_KEY not set; dry-run only.")
        return
    _die(
        "OPENAI_API_KEY is not set.\n"
        "Set environment variables or create engines/gpt-image-gen/.env:\n"
        "  OPENAI_API_KEY=your-api-key\n"
        "  OPENAI_BASE_URL=https://your-proxy/v1  (optional, for proxy)\n"
        "  CODEX_PPT_IMAGE_MODEL=gpt-image-2      (optional)"
    )


def _read_prompt(prompt: Optional[str], prompt_file: Optional[str]) -> str:
    if prompt and prompt_file:
        _die("Use --prompt or --prompt-file, not both.")
    if prompt_file:
        if prompt_file == "-":
            return sys.stdin.read().strip()
        path = Path(prompt_file)
        if not path.exists():
            _die(f"Prompt file not found: {path}")
        return path.read_text(encoding="utf-8").strip()
    if prompt:
        return prompt.strip()
    _die("Missing prompt. Use --prompt or --prompt-file.")
    return ""


def _check_image_paths(paths: Iterable[str]) -> List[Path]:
    resolved: List[Path] = []
    for raw in paths:
        path = Path(raw)
        if not path.exists():
            _die(f"Image file not found: {path}")
        if path.stat().st_size > MAX_IMAGE_BYTES:
            _warn(f"Image exceeds 50MB limit: {path}")
        resolved.append(path)
    return resolved


def _normalize_output_format(fmt: Optional[str]) -> str:
    if not fmt:
        return DEFAULT_OUTPUT_FORMAT
    fmt = fmt.lower()
    if fmt not in {"png", "jpeg", "jpg", "webp"}:
        _die("output-format must be png, jpeg, jpg, or webp.")
    return "jpeg" if fmt == "jpg" else fmt


def _parse_size(size: str) -> Optional[Tuple[int, int]]:
    match = re.fullmatch(r"([1-9][0-9]*)x([1-9][0-9]*)", size)
    if not match:
        return None
    return int(match.group(1)), int(match.group(2))


def _validate_gpt_image_2_size(size: str) -> None:
    if size == "auto":
        return
    parsed = _parse_size(size)
    if parsed is None:
        _die("size must be auto or WIDTHxHEIGHT.")
    width, height = parsed
    if max(width, height) > GPT_IMAGE_2_MAX_EDGE:
        _die("gpt-image-2 max edge: 3840px.")
    if width % 16 != 0 or height % 16 != 0:
        _die("gpt-image-2 dimensions must be multiples of 16px.")
    if max(width, height) / min(width, height) > GPT_IMAGE_2_MAX_RATIO:
        _die("gpt-image-2 aspect ratio must not exceed 3:1.")
    total = width * height
    if total < GPT_IMAGE_2_MIN_PIXELS or total > GPT_IMAGE_2_MAX_PIXELS:
        _die("gpt-image-2 total pixels: 655,360 – 8,294,400.")


def _validate_size(size: str, model: str) -> None:
    if GPT_IMAGE_2_MODEL in model:
        _validate_gpt_image_2_size(size)
    elif size not in ALLOWED_LEGACY_SIZES:
        _die("size must be 1024x1024, 1536x1024, 1024x1536, or auto.")


def _validate_quality(quality: str) -> None:
    if quality not in ALLOWED_QUALITIES:
        _die("quality must be low, medium, high, or auto.")


def _validate_background(background: Optional[str]) -> None:
    if background not in ALLOWED_BACKGROUNDS:
        _die("background must be transparent, opaque, or auto.")


def _validate_model(model: str) -> None:
    if GPT_IMAGE_MODEL_PREFIX not in model:
        _die("model must contain 'gpt-image-' (e.g. gpt-image-2).")


def _validate_transparency(background: Optional[str], output_format: str) -> None:
    if background == "transparent" and output_format not in {"png", "webp"}:
        _die("transparent background requires png or webp output.")


def _validate_generate_payload(payload: Dict[str, Any]) -> None:
    model = str(payload.get("model", DEFAULT_MODEL))
    _validate_model(model)
    n = int(payload.get("n", 1))
    if n < 1 or n > 10:
        _die("n must be between 1 and 10")
    size = str(payload.get("size", DEFAULT_SIZE))
    quality = str(payload.get("quality", DEFAULT_QUALITY))
    background = payload.get("background")
    _validate_size(size, model)
    _validate_quality(quality)
    _validate_background(background)
    if GPT_IMAGE_2_MODEL in model and background == "transparent":
        _die("gpt-image-2 does not support transparent backgrounds.")
    oc = payload.get("output_compression")
    if oc is not None and not (0 <= int(oc) <= 100):
        _die("output_compression must be 0–100")


def _build_output_paths(out: str, output_format: str, count: int, out_dir: Optional[str]) -> List[Path]:
    ext = "." + output_format
    if out_dir:
        out_base = Path(out_dir)
        out_base.mkdir(parents=True, exist_ok=True)
        return [out_base / f"image_{i}{ext}" for i in range(1, count + 1)]
    out_path = Path(out)
    if out_path.exists() and out_path.is_dir():
        return [out_path / f"image_{i}{ext}" for i in range(1, count + 1)]
    if out_path.suffix == "":
        out_path = out_path.with_suffix(ext)
    if count == 1:
        return [out_path]
    return [out_path.with_name(f"{out_path.stem}-{i}{out_path.suffix}") for i in range(1, count + 1)]


def _decode_write_and_downscale(images, outputs, *, force, output_format):
    for idx, image_b64 in enumerate(images):
        if idx >= len(outputs):
            break
        out_path = outputs[idx]
        if out_path.exists() and not force:
            _die(f"Output exists: {out_path} (use --force to overwrite)")
        out_path.parent.mkdir(parents=True, exist_ok=True)
        out_path.write_bytes(base64.b64decode(image_b64))
        print(f"Wrote {out_path}")


def _generate(args: argparse.Namespace) -> None:
    prompt = _read_prompt(args.prompt, args.prompt_file)

    payload = {
        "model": args.model,
        "prompt": prompt,
        "n": args.n,
        "size": args.size,
        "quality": args.quality,
        "background": args.background,
        "output_format": args.output_format,
        "output_compression": args.output_compression,
        "moderation": args.moderation,
    }
    payload = {k: v for k, v in payload.items() if v is not None}

    output_format = _normalize_output_format(args.output_format)
    _validate_transparency(args.background, output_format)
    payload["output_format"] = output_format
    output_paths = _build_output_paths(args.out, output_format, args.n, args.out_dir)

    if args.dry_run:
        print(json.dumps({"endpoint": "/v1/images/generations", "outputs": [str(p) for p in output_paths], **payload}, indent=2))
        return

    print("Calling Image API...", file=sys.stderr)
    started = time.time()
    provider = create_image_provider(api_key=os.getenv("OPENAI_API_KEY"), base_url=_api_base_url())
    images = provider.generate(payload)
    print(f"Done in {time.time() - started:.1f}s.", file=sys.stderr)

    _decode_write_and_downscale(images, output_paths, force=args.force, output_format=output_format)


def _edit(args: argparse.Namespace) -> None:
    prompt = _read_prompt(args.prompt, args.prompt_file)
    image_paths = _check_image_paths(args.image)
    mask_path = Path(args.mask) if args.mask else None

    payload = {
        "model": args.model,
        "prompt": prompt,
        "n": args.n,
        "size": args.size,
        "quality": args.quality,
        "background": args.background,
        "output_format": args.output_format,
        "output_compression": args.output_compression,
        "input_fidelity": args.input_fidelity,
        "moderation": args.moderation,
    }
    payload = {k: v for k, v in payload.items() if v is not None}

    output_format = _normalize_output_format(args.output_format)
    _validate_transparency(args.background, output_format)
    payload["output_format"] = output_format
    output_paths = _build_output_paths(args.out, output_format, args.n, args.out_dir)

    if args.dry_run:
        payload["image"] = [str(p) for p in image_paths]
        print(json.dumps({"endpoint": "/v1/images/edits", "outputs": [str(p) for p in output_paths], **payload}, indent=2))
        return

    print(f"Calling Image API (edit) with {len(image_paths)} image(s)...", file=sys.stderr)
    started = time.time()
    provider = create_image_provider(api_key=os.getenv("OPENAI_API_KEY"), base_url=_api_base_url())
    images = provider.edit(payload, image_paths, mask_path)
    print(f"Done in {time.time() - started:.1f}s.", file=sys.stderr)

    _decode_write_and_downscale(images, output_paths, force=args.force, output_format=output_format)


def _add_shared_args(parser: argparse.ArgumentParser) -> None:
    parser.add_argument("--model", default=_default_model())
    parser.add_argument("--prompt")
    parser.add_argument("--prompt-file")
    parser.add_argument("--n", type=int, default=1)
    parser.add_argument("--size", default=DEFAULT_SIZE)
    parser.add_argument("--quality", default=DEFAULT_QUALITY)
    parser.add_argument("--background")
    parser.add_argument("--output-format")
    parser.add_argument("--output-compression", type=int)
    parser.add_argument("--moderation")
    parser.add_argument("--out", default=DEFAULT_OUTPUT_PATH)
    parser.add_argument("--out-dir")
    parser.add_argument("--force", action="store_true")
    parser.add_argument("--dry-run", action="store_true")


def main() -> int:
    _load_dotenv()
    parser = argparse.ArgumentParser(description="GPT Image generation/edit CLI")
    subparsers = parser.add_subparsers(dest="command", required=True)

    gen = subparsers.add_parser("generate", help="Create a new image")
    _add_shared_args(gen)
    gen.set_defaults(func=_generate)

    edit = subparsers.add_parser("edit", help="Edit an existing image")
    _add_shared_args(edit)
    edit.add_argument("--image", action="append", required=True)
    edit.add_argument("--mask")
    edit.add_argument("--input-fidelity")
    edit.set_defaults(func=_edit)

    args = parser.parse_args()
    if args.n < 1 or args.n > 10:
        _die("--n must be 1–10")
    if args.output_compression is not None and not (0 <= args.output_compression <= 100):
        _die("--output-compression must be 0–100")

    _validate_model(args.model)
    _validate_size(args.size, args.model)
    _validate_quality(args.quality)
    _validate_background(args.background)
    _ensure_api_key(args.dry_run)

    args.func(args)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
