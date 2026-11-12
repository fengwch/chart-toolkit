#!/usr/bin/env python3
"""从任意已含 TYSZ 样式的 pptx 中抽出「纯样式模板」（母版 + 版式 + 主题 + 媒体，0 页）。

用法：
  python3 extract_template.py 源deck.pptx --out assets/tysz-base-template.pptx \
      --media-out assets/media --spec-out references/extracted-spec.json

产物：
  * out           —— 可直接 `Presentation(out)` 后 add_slide 使用的基础模板（保留
                     1_标题页 / 2_仅标题空内容 两套版式与其装饰图片）
  * media-out     —— 抽出的全部 ppt/media/*（logo、分隔线、封面底图等）
  * spec-out      —— 版式几何 / 主题色 / 字体的机器可读规格（JSON）

实现要点：python-pptx 无法删除全部幻灯片，因此在 zip 层重建包：剔除 ppt/slides/**、
重写 presentation.xml 的 sldIdLst 为空、删除 presentation rels 里的 slide 关系、
删除 [Content_Types].xml 里的 slide Override。
"""
from __future__ import annotations

import argparse
import json
import os
import re
import zipfile

A_NS = "http://schemas.openxmlformats.org/drawingml/2006/main"


def strip_slides(src: str, out: str) -> tuple[int, int]:
    zin = zipfile.ZipFile(src)
    names = zin.namelist()
    n_slides = len([n for n in names if re.match(r"ppt/slides/slide\d+\.xml$", n)])

    with zipfile.ZipFile(out, "w", zipfile.ZIP_DEFLATED) as zout:
        for item in zin.infolist():
            n = item.filename
            if re.match(r"ppt/slides/", n) or n == "docProps/thumbnail.jpeg":
                continue
            data = zin.read(n)
            if n == "ppt/presentation.xml":
                txt = data.decode("utf-8")
                txt = re.sub(r"<p:sldIdLst>.*?</p:sldIdLst>", "<p:sldIdLst/>", txt, flags=re.S)
                data = txt.encode("utf-8")
            elif n == "ppt/_rels/presentation.xml.rels":
                txt = data.decode("utf-8")
                txt = re.sub(
                    r'<Relationship[^>]*Type="[^"]*/slide"[^>]*/>', "", txt
                )
                data = txt.encode("utf-8")
            elif n == "[Content_Types].xml":
                txt = data.decode("utf-8")
                txt = re.sub(r'<Override PartName="/ppt/slides/slide\d+\.xml"[^>]*/>', "", txt)
                data = txt.encode("utf-8")
            zout.writestr(item, data)
    return n_slides, len(names)


def extract_media(src: str, media_out: str) -> list[str]:
    os.makedirs(media_out, exist_ok=True)
    got = []
    with zipfile.ZipFile(src) as z:
        for n in z.namelist():
            if n.startswith("ppt/media/") and not n.endswith("/"):
                base = os.path.basename(n)
                with open(os.path.join(media_out, base), "wb") as f:
                    f.write(z.read(n))
                got.append(base)
    return got


def dump_spec(src: str) -> dict:
    spec = {"layouts": {}, "theme": {}, "master": {}}
    with zipfile.ZipFile(src) as z:
        th = z.read("ppt/theme/theme1.xml").decode()
        for m in re.finditer(r"<a:(dk1|lt1|dk2|lt2|accent[1-6]|hlink|folHlink)>(.*?)</a:\1>", th, re.S):
            v = re.search(r'(?:val|lastClr)="([0-9A-Fa-f]{6})"', m.group(2))
            if v:
                spec["theme"][m.group(1)] = v.group(1)
        fs = re.search(r"<a:fontScheme.*?</a:fontScheme>", th, re.S)
        if fs:
            spec["theme"]["major_latin"] = re.findall(
                r'<a:majorFont><a:latin typeface="([^"]*)"', fs.group(0))
            spec["theme"]["minor_latin"] = re.findall(
                r'<a:minorFont><a:latin typeface="([^"]*)"', fs.group(0))

        mx = z.read("ppt/slideMasters/slideMaster1.xml").decode()
        bg = re.search(r"<p:bg>.*?</p:bg>", mx, re.S)
        spec["master"]["bg"] = re.sub(r"\s+", " ", bg.group(0)) if bg else None

        for n in z.namelist():
            mm = re.match(r"ppt/slideLayouts/slideLayout(\d+)\.xml$", n)
            if not mm:
                continue
            num = mm.group(1)
            lx = z.read(n).decode()
            name_m = re.search(r'<p:cSld name="([^"]*)"', lx)
            rf = f"ppt/slideLayouts/_rels/slideLayout{num}.xml.rels"
            imgs = re.findall(r'Target="\.\./media/([^"]+)"',
                              z.read(rf).decode()) if rf in z.namelist() else []
            entry = {"shapes": [], "images": imgs}
            for kind in ("sp", "pic"):
                for sp in re.findall(rf"<p:{kind}>.*?</p:{kind}>", lx, re.S):
                    off = re.search(r'<a:off x="(-?\d+)" y="(-?\d+)"', sp)
                    ext = re.search(r'<a:ext cx="(\d+)" cy="(\d+)"', sp)
                    entry["shapes"].append({
                        "kind": kind,
                        "name": (re.search(r'name="([^"]*)"', sp) or [None, None])[1]
                        if re.search(r'name="([^"]*)"', sp) else None,
                        "placeholder": (re.search(r'<p:ph type="(\w+)"', sp).group(1)
                                        if re.search(r'<p:ph type="(\w+)"', sp) else None),
                        "offset": [int(x) for x in off.groups()] if off else None,
                        "extent": [int(x) for x in ext.groups()] if ext else None,
                        "color": re.findall(r'solidFill><a:srgbClr val="(\w{6})"', sp),
                        "size": re.findall(r'sz="(\d+)"', sp),
                        "font": sorted(set(re.findall(r'typeface="([^"]+)"', sp))),
                    })
            spec["layouts"][f"slideLayout{num}"] = {"name": name_m.group(1) if name_m else None,
                                                    **entry}
    return spec


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("src")
    ap.add_argument("--out", required=True)
    ap.add_argument("--media-out")
    ap.add_argument("--spec-out")
    args = ap.parse_args()

    n_slides, n_parts = strip_slides(args.src, args.out)
    print(f"基础模板已生成：{args.out}（源 {n_slides} 页 / {n_parts} 个部件 → 0 页）")
    if args.media_out:
        print("抽出媒体：", extract_media(args.src, args.media_out))
    if args.spec_out:
        spec = dump_spec(args.src)
        os.makedirs(os.path.dirname(os.path.abspath(args.spec_out)), exist_ok=True)
        with open(args.spec_out, "w", encoding="utf-8") as f:
            json.dump(spec, f, ensure_ascii=False, indent=2)
        print("样式规格已写出：", args.spec_out)


if __name__ == "__main__":
    main()
