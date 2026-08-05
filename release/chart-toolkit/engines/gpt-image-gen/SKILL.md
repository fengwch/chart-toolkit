---
name: gpt-image-gen
description: >-
  Generate diagrams, charts, and visual content using GPT Image models
  (gpt-image-2). Trigger on: "用AI画图" "生成图片" "image generation"
  "用gpt画图" or when user wants AI-generated visual content with
  natural language description.
---

# GPT Image Gen

Generate images using OpenAI's GPT Image API (gpt-image-2 or compatible models).

## Configuration

### Environment Variables

| Variable | Required | Default | Description |
|---|---|---|---|
| `OPENAI_API_KEY` | ✔ | — | API key for OpenAI or compatible provider |
| `OPENAI_BASE_URL` | ✘ | Official API | Proxy/relay base URL (e.g. `https://proxy.example.com/v1`) |
| `CODEX_PPT_IMAGE_MODEL` | ✘ | `gpt-image-2` | Model name |

### Setup

**Option A: Environment variables**

```bash
export OPENAI_API_KEY="sk-xxx"
export OPENAI_BASE_URL="https://your-proxy.com/v1"   # optional
export CODEX_PPT_IMAGE_MODEL="gpt-image-2"           # optional
```

**Option B: `.env` file** (in engine directory)

Create `engines/gpt-image-gen/.env`:

```env
OPENAI_API_KEY=sk-xxx
OPENAI_BASE_URL=https://your-proxy.com/v1
CODEX_PPT_IMAGE_MODEL=gpt-image-2
```

### Install Dependencies

```bash
pip install openai Pillow
```

Or: `pip install -r engines/gpt-image-gen/requirements.txt`

## CLI Usage

### Generate Image

```bash
python3 engines/gpt-image-gen/scripts/image_gen.py generate \
  --prompt "A microservices architecture diagram with API gateway, auth service, and database" \
  --size 1536x1024 \
  --quality medium \
  --out architecture.png
```

### Edit Image

```bash
python3 engines/gpt-image-gen/scripts/image_gen.py edit \
  --prompt "Add a Redis cache layer between the API gateway and services" \
  --image architecture.png \
  --out architecture-v2.png
```

### Options

| Flag | Default | Description |
|---|---|---|
| `--model` | `gpt-image-2` | Model name |
| `--size` | `1536x1024` | Image size (WxH or auto) |
| `--quality` | `medium` | low / medium / high / auto |
| `--background` | — | transparent / opaque / auto |
| `--output-format` | `png` | png / jpeg / webp |
| `--n` | 1 | Number of images (1–10) |
| `--out` | `output/image.png` | Output path |
| `--force` | false | Overwrite existing |
| `--dry-run` | false | Print request without calling API |

## Supported Sizes

### gpt-image-2

Any `WIDTHxHEIGHT` where:
- Both dimensions are multiples of 16
- Max edge ≤ 3840px
- Aspect ratio ≤ 3:1
- Total pixels: 655,360 – 8,294,400

Common sizes: `1024x1024`, `1536x1024`, `1024x1536`, `1920x1088`, `2560x1440`

### Other models

`1024x1024`, `1536x1024`, `1024x1536`, `auto`

## Providers

| Provider | Detection | Notes |
|---|---|---|
| OpenAI (official) | `OPENAI_BASE_URL` unset | Direct API |
| OpenAI-compatible proxy | `OPENAI_BASE_URL` set (non-AtlasCloud) | Relay/proxy services |
| AtlasCloud | `OPENAI_BASE_URL` contains `atlascloud.ai` | Async prediction API |

## Style Catalog

Use these built-in style templates as prompt foundations. Each file contains a structured JSON brief with color palette, typography, layout patterns, and visual direction.

| # | Style | File | Best For |
|---|---|---|---|
| 1 | 麦肯锡风格 | `references/麦肯锡风格.md` | Business consulting, strategy decks |
| 2 | 数据仪表盘风 | `references/数据仪表盘风.md` | KPI dashboards, BI reports |
| 3 | 手绘白板风 | `references/手绘白板风.md` | Teaching, brainstorming, tech sharing |
| 4 | 手绘技术解释风 | `references/手绘技术解释风.md` | Technical explanations, tutorials |
| 5 | 清爽专业风 | `references/清爽专业风.md` | Clean professional presentations |
| 6 | 创意杂志风 | `references/创意杂志风.md` | Creative editorial, magazine layout |
| 7 | 科研答辩风 | `references/科研答辩风.md` | Academic defense, research presentations |
| 8 | 教学课件风 | `references/教学课件风.md` | Teaching courseware, lectures |
| 9 | 党政红风格 | `references/党政红风格.md` | Government, official reports |
| 10 | 复古扁平插画风 | `references/复古扁平插画风.md` | Retro flat illustrations |
| 11 | 温暖手工风 | `references/温暖手工风.md` | Warm handmade, craft aesthetic |
| 12 | 电子墨水杂志风 | `references/电子墨水杂志风.md` | E-ink magazine, minimalist editorial |

To use a style: read the reference file, extract the JSON brief, and incorporate it into the generation prompt.

## Limitations

- gpt-image-2 does not support transparent backgrounds
- Max 50MB per input image for edit operations
- API key required for all non-dry-run operations
