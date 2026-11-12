#!/usr/bin/env python3
"""把 pptx 导出为逐页 PNG，用于目视 QA（macOS 走 Keynote，跨平台可接 LibreOffice）。

macOS（无 PowerPoint/LibreOffice 时最稳）：
  python3 export_preview.py deck.pptx --out /tmp/preview --dpi 150
  → /tmp/preview/out.001.png ...

其他平台：安装 LibreOffice 后自动回退 `soffice --convert-to pdf` + `pdftoppm`。

注意：永远导出**副本**，不要让 Keynote/LibreOffice 打开正式交付文件（避免被改写）。
"""
from __future__ import annotations

import argparse
import os
import shutil
import subprocess
import sys
import tempfile


def keynote_export(pptx: str, out_dir: str, dpi: int) -> bool:
    """macOS Keynote AppleScript 导出。Keynote 不认 dpi 参数，这里先转 PDF 再栅格化更可控。"""
    script = f'''
    tell application "Keynote"
        set d to open POSIX file "{pptx}"
        delay 2
        export d to POSIX file "{out_dir}" as slide images with properties {{image format:PNG, skipped slides:false}}
        delay 1
        close d saving no
    end tell
    '''
    try:
        r = subprocess.run(["osascript", "-e", script], capture_output=True, text=True, timeout=300)
        return r.returncode == 0
    except Exception as e:  # noqa: BLE001
        print("Keynote 导出失败：", e, file=sys.stderr)
        return False


def soffice_export(pptx: str, out_dir: str, dpi: int) -> bool:
    soffice = shutil.which("soffice") or shutil.which("libreoffice")
    if not soffice:
        return False
    with tempfile.TemporaryDirectory() as tmp:
        subprocess.run([soffice, "--headless", "--convert-to", "pdf", "--outdir", tmp, pptx],
                       check=False, capture_output=True)
        pdfs = [f for f in os.listdir(tmp) if f.endswith(".pdf")]
        if not pdfs:
            return False
        if shutil.which("pdftoppm"):
            subprocess.run(["pdftoppm", "-png", "-r", str(dpi),
                            os.path.join(tmp, pdfs[0]), os.path.join(out_dir, "out")], check=False)
            return True
        shutil.copy(os.path.join(tmp, pdfs[0]), os.path.join(out_dir, pdfs[0]))
    return True


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("pptx")
    ap.add_argument("--out", required=True)
    ap.add_argument("--dpi", type=int, default=150)
    args = ap.parse_args()

    os.makedirs(args.out, exist_ok=True)
    # 始终操作副本
    copy = os.path.join(tempfile.gettempdir(), "tysz_preview_" + os.path.basename(args.pptx))
    shutil.copy(args.pptx, copy)

    ok = keynote_export(copy, args.out, args.dpi) if sys.platform == "darwin" else False
    if not ok:
        ok = soffice_export(copy, args.out, args.dpi)
    if not ok:
        raise SystemExit("没有可用的渲染器：macOS 请装 Keynote，其余平台请装 LibreOffice + poppler")
    files = sorted(f for f in os.listdir(args.out) if f.lower().endswith((".png", ".pdf")))
    print(f"导出 {len(files)} 个文件到 {args.out}：{files[:5]}{' ...' if len(files) > 5 else ''}")


if __name__ == "__main__":
    main()
