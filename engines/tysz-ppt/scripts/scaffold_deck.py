#!/usr/bin/env python3
"""用 TYSZ 基础模板搭出「封面 + N 页内容骨架」的新 deck（页头/页脚已按规范就位）。

输入页面清单（二选一）：
  --pages-file pages.txt    每行一页：`标题 || 导语`（导语可省略）
  或 --pages "标题1||导语1" --pages "标题2||导语2"

用法：
  python3 scaffold_deck.py --out new.pptx --deck-title "基于 AI Agent 的 RCA 取证与根因定位" \
      --cover-title "基于 AI Agent 的 RCA 取证与根因定位" \
      --cover-subtitle "从「人肉翻看板」到「证据驱动闭环」" \
      --cover-footer "研发部 · 运维开发团队 · 2026 年 10 月" \
      --pages-file pages.txt

产物：p1 封面（版式 1_标题页，含底图/logo）+ p2..N 内容页（版式 2_仅标题空内容，
标题 28pt 粗体 C00000 微软雅黑、导语 16pt 404040、页脚 9pt 黑 55% 透明度、右下页码导航），
正文区留白（y 1100000–6450000 EMU）供后续填充表格/卡片/图示。
"""
from __future__ import annotations

import argparse
import os

from lxml import etree
from pptx import Presentation
from pptx.dml.color import RGBColor
from pptx.enum.text import PP_ALIGN
from pptx.oxml.ns import qn
from pptx.util import Emu, Pt

HERE = os.path.dirname(os.path.abspath(__file__))
BASE = os.path.join(HERE, "..", "assets", "tysz-base-template.pptx")
COVER_ART = os.path.join(HERE, "..", "assets", "tysz-cover-art.png")

FONT = "微软雅黑"
A_NS = "http://schemas.openxmlformats.org/drawingml/2006/main"
TITLE_BOX = (335359, 122216, 10314711, 658085)
LEAD_BOX = (335359, 930000, 11500000, 220000)
FOOTER_TOP = 6630000
FOOTER_LEFT = (476250, 6630000, 5900000, 142875)
FOOTER_RIGHT = (8200000, 6630000, 3264025, 142875)


def set_char_alpha(run, alpha_pct):
    """给 run 的颜色加透明度（页脚用 55% 黑）。"""
    xml = run._r.xml
    if "<a:alpha" in xml:
        return
    xml = xml.replace("</a:srgbClr>", f'<a:alpha val="{int(alpha_pct * 1000)}"/></a:srgbClr>')
    r = run._r
    parent = r.getparent()
    idx = list(parent).index(r)
    parent.remove(r)
    parent.insert(idx, etree.fromstring(xml))


def add_text(slide, box, text, size, color, bold=False, align=PP_ALIGN.LEFT, alpha=None,
             wrap=True):
    tb = slide.shapes.add_textbox(Emu(box[0]), Emu(box[1]), Emu(box[2]), Emu(box[3]))
    tf = tb.text_frame
    # 封面大标题 / 副标题 / 落款用 wrap="none"：与模板一致，避免折行压到下一行元素
    tf.word_wrap = wrap
    p = tf.paragraphs[0]
    p.alignment = align
    r = p.add_run()
    r.text = text
    r.font.size = Pt(size)
    r.font.bold = bold
    r.font.name = FONT
    r.font.color.rgb = RGBColor.from_string(color)
    rPr = r._r.get_or_add_rPr()
    for tag in ("a:ea", "a:cs"):
        el = rPr.makeelement(qn(tag), {"typeface": FONT})
        latin = rPr.find(qn("a:latin"))
        (latin.addnext(el) if latin is not None else rPr.append(el))
    if alpha:
        set_char_alpha(r, alpha)
    return tb


def style_paragraph(p, size, color, bold=True, font=FONT):
    for r in p.runs:
        r.font.size = Pt(size)
        r.font.bold = bold
        r.font.name = font
        r.font.color.rgb = RGBColor.from_string(color)


def strip_placeholders(slide):
    """删掉 add_slide 克隆来的占位符。

    版式里的封面占位符带提示文案「单击此处编辑母版文本样式」，克隆后 Keynote / 部分
    渲染器会把它画到页面上；同时无显式几何的占位符在 Keynote 里也可能被丢弃。
    统一改为自带几何的文本框，渲染最稳（与成品 deck 的做法一致）。
    """
    n = 0
    for sh in list(slide.shapes):
        if sh._element.find('.//' + qn('p:ph')) is not None:
            sh._element.getparent().remove(sh._element)
            n += 1
    return n


def make_cover(prs, title, subtitle, footer):
    layout = next(l for l in prs.slide_masters[0].slide_layouts if l.name == "1_标题页")
    slide = prs.slides.add_slide(layout)
    strip_placeholders(slide)
    add_text(slide, (1790700, 1847850, 8620125, 600075), title, 39, "C00000",
             bold=True, align=PP_ALIGN.CENTER, wrap=False)
    if subtitle:
        # 一行放不下时自动降一档字号，避免换行压到细分隔线
        size = 18 if len(subtitle) <= 42 else 16
        add_text(slide, (1000125, 2619375, 10191750, 276225), subtitle, size, "000000",
                 align=PP_ALIGN.CENTER, wrap=False)
    rule = slide.shapes.add_shape(1, Emu(1809750), Emu(3238500), Emu(8572500), Emu(9525))
    rule.fill.solid()
    rule.fill.fore_color.rgb = RGBColor(0x00, 0x00, 0x00)
    rule.fill.fore_color._xFill.find(qn("a:srgbClr")).append(
        etree.fromstring(f'<a:alpha xmlns:a="{A_NS}" val="25000"/>'))
    rule.line.fill.background()
    rule.shadow.inherit = False
    if os.path.exists(COVER_ART):
        slide.shapes.add_picture(COVER_ART, Emu(2000250), Emu(3629025), Emu(8191500), Emu(1257300))
    if footer:
        add_text(slide, (3200400, 5286375, 5791200, 228600), footer, 15, "000000",
                 align=PP_ALIGN.CENTER, wrap=False)
    return slide


def make_content(prs, title, lead, deck_title, idx, total):
    layout = next(l for l in prs.slide_masters[0].slide_layouts
                  if l.name == "2_仅标题空内容")
    slide = prs.slides.add_slide(layout)
    # 版式自带的标题占位符：Keynote 会丢弃「无显式几何」的占位符，
    # 因此删掉它、改用显式几何文本框（与成品 deck 完全一致，渲染最稳）。
    strip_placeholders(slide)
    add_text(slide, TITLE_BOX, title, 28, "C00000", bold=True)
    if lead:
        add_text(slide, LEAD_BOX, lead, 16, "404040", bold=True)
    add_text(slide, FOOTER_LEFT, deck_title, 9, "000000", alpha=55)
    add_text(slide, FOOTER_RIGHT, f"{idx:02d} / {total:02d}", 9, "000000",
             alpha=55, align=PP_ALIGN.RIGHT)
    return slide


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", required=True)
    ap.add_argument("--deck-title", default="")
    ap.add_argument("--cover-title", required=True)
    ap.add_argument("--cover-subtitle", default="")
    ap.add_argument("--cover-footer", default="")
    ap.add_argument("--pages", action="append", default=[])
    ap.add_argument("--pages-file")
    args = ap.parse_args()

    pages = list(args.pages)
    if args.pages_file:
        with open(args.pages_file, encoding="utf-8") as f:
            pages += [ln.strip() for ln in f if ln.strip() and not ln.startswith("#")]

    prs = Presentation(BASE)
    make_cover(prs, args.cover_title, args.cover_subtitle, args.cover_footer)
    total = len(pages)
    for i, raw in enumerate(pages, start=1):
        title, _, lead = raw.partition("||")
        make_content(prs, title.strip(), lead.strip(), args.deck_title or args.cover_title, i, total)
    prs.save(args.out)
    print(f"已生成 {args.out}：封面 1 页 + 内容 {total} 页（正文区留白待填）")


if __name__ == "__main__":
    main()
