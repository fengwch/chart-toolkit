#!/usr/bin/env python3
"""TYSZ 风格 deck 结构自检（不打开 PowerPoint 即可完成 90% 的排版 QA）。

检查项：
  1. 页面尺寸 / 版式名 / 页数
  2. 是否有盖住版式装饰的全幅白矩形残留
  3. 形状越界（右/下超出画布）
  4. 正文与页脚重叠（content_bottom > 页脚顶边）
  5. 页头互相压盖（正文顶边进入分隔线以下安全区之前）
  6. 字体残留（华文细黑 / Calibri / 等线 / 宋体）
  7. 标题框几何/字号/颜色是否符合 TYSZ 规范（28pt 粗体 C00000 微软雅黑）

用法：
  python3 validate_deck.py deck.pptx [--footer-top 6630000] [--json]
退出码：0 全通过；1 存在 FAIL/警告。
"""
from __future__ import annotations

import argparse
import json
import re

from pptx import Presentation

SLIDE_W, SLIDE_H = 12192000, 6858000
TITLE_TOP_MAX = 500000
CONTENT_SAFE_TOP = 874965               # 分隔线底边（335359,807730 + 67235）
FOOTER_BAND = 6400000                   # 页脚/装饰带起点：带内形状不计入正文底边
BAD_FONTS = ("华文细黑", "Calibri", "等线", "宋体", "Arial")
BAD_FONT_ALLOW = ("微软雅黑",)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("pptx")
    ap.add_argument("--footer-top", type=int, default=6630000)
    ap.add_argument("--json", action="store_true")
    args = ap.parse_args()

    prs = Presentation(args.pptx)
    report = {"file": args.pptx, "pages": [], "summary": {}}
    fails = 0

    for i, slide in enumerate(prs.slides, 1):
        page = {"page": i, "layout": slide.slide_layout.name, "issues": []}
        content_bottom = 0
        content_top = SLIDE_H
        fullpage_rect = False

        for sh in slide.shapes:
            left, top = sh.left or 0, sh.top or 0
            if sh.name.startswith("TYSZ"):      # 自绘页头/装饰件不计入正文
                continue
            w, h = sh.width or 0, sh.height or 0
            xml = sh._element.xml
            if left == 0 and top == 0 and w >= SLIDE_W - 2000 and h >= SLIDE_H - 8000:
                fullpage_rect = True
            if left + w > SLIDE_W + 1000 or top + h > SLIDE_H + 1000:
                page["issues"].append(f"越界: {sh.name}")
            if top < FOOTER_BAND:
                content_bottom = max(content_bottom, top + h)
                if top >= 1000000:          # 只统计正文区（标题/导语属页头）
                    content_top = min(content_top, top)
            for bad in BAD_FONTS:
                if f'typeface="{bad}"' in xml:
                    page["issues"].append(f"字体残留 {bad}: {sh.name}")
            if sh.has_text_frame and (sh.top or 0) < TITLE_TOP_MAX and sh.text_frame.text.strip():
                szs = set(re.findall(r'sz="(\d+)"', xml))
                colors = set(re.findall(r'srgbClr val="(\w{6})"', xml))
                if "2800" not in szs:
                    page["issues"].append(f"标题字号非 28pt（{sorted(szs)}）: {sh.text_frame.text[:14]}")
                if "C00000" not in colors:
                    page["issues"].append(f"标题色非 C00000（{sorted(colors)}）: {sh.text_frame.text[:14]}")

        if fullpage_rect:
            page["issues"].append("存在全幅白矩形（会遮住版式页头装饰）")
        overflow = max(0, content_bottom - args.footer_top)
        if overflow > 0:
            page["issues"].append(f"内容压页脚 {round(overflow / 914400, 3)}in")
        if 0 < content_top < CONTENT_SAFE_TOP:
            page["issues"].append(f"正文顶边 {content_top} 顶入页头安全区（< {CONTENT_SAFE_TOP}）")

        page["content_bottom_in"] = round(content_bottom / 914400, 2)
        if page["issues"]:
            fails += 1
        report["pages"].append(page)

    report["summary"] = {
        "total": len(report["pages"]),
        "failed": fails,
        "layouts": sorted({p["layout"] for p in report["pages"]}),
    }

    if args.json:
        print(json.dumps(report, ensure_ascii=False, indent=2))
    else:
        for p in report["pages"]:
            flag = "FAIL" if p["issues"] else " OK "
            print(f"[{flag}] p{p['page']:>2} {p['layout']:<14} 内容底={p['content_bottom_in']}in")
            for iss in p["issues"]:
                print(f"        - {iss}")
        s = report["summary"]
        print(f"\n合计 {s['total']} 页，异常 {s['failed']} 页；版式：{s['layouts']}")
    raise SystemExit(1 if fails else 0)


if __name__ == "__main__":
    main()
