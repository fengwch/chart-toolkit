#!/usr/bin/env python3
"""把 TYSZ（天翼数字生活 · 红蓝工作汇报风）页头风格套用到 deck 的全部内容页。

两种模式：
  * --mode layout（默认）：deck 已含 TYSZ 版式（`2_仅标题空内容`）时使用——删掉内容页
    上的全幅白色矩形，把每页 slideLayout 关系指回该版式，页头装饰（红橙渐变分隔线 +
    右上 logo + 右下装饰块）由版式自带。
  * --mode draw：deck 没有 TYSZ 版式（例如别的模板生成的 deck）时使用——直接在每页
    用图片/形状把页头装饰画出来（分隔线、logo、右下装饰块几何与 TYSZ 版式一致）。

两种模式都会：
  1. 标题框对齐 TYSZ 几何 (335359,122216,10314711×658085)，设为 28pt 粗体 #C00000 微软雅黑
  2. 导语行（可选）下移到 y=930000，设为 16pt 粗体 #404040 微软雅黑
  3. 正文整体下移 --content-shift，页脚统一到 --footer-top 并避让右下装饰块
  4. 输出与页脚的重叠量，重叠 >0 时以非零码退出（便于 CI/自查）

用法：
  python3 apply_tysz_style.py deck.pptx --dry-run
  python3 apply_tysz_style.py deck.pptx --mode layout --from-page 3
  python3 apply_tysz_style.py deck.pptx --mode draw
"""
from __future__ import annotations

import argparse
import os
import re
import shutil
import zipfile

from lxml import etree
from pptx import Presentation
from pptx.enum.text import PP_ALIGN
from pptx.oxml.ns import qn
from pptx.util import Emu

# ---- TYSZ 设计常量（EMU / 字号 / 颜色 / 字体）--------------------------------
A_NS = "http://schemas.openxmlformats.org/drawingml/2006/main"
SLIDE_W, SLIDE_H = 12192000, 6858000

TITLE_BOX = (335359, 122216, 10314711, 658085)
TITLE = (28, "C00000")          # 28pt 粗体 C00000 微软雅黑
LEAD_BOX = (335359, 930000, 11500000, 220000)
LEAD = (16, "404040")
FOOTER_TOP = 6630000
FOOTER_RIGHT_LIMIT = 11470000
FOOTER_BAND = 6400000          # 页脚/装饰带起点：此带内的形状不下移（装饰件、页码）
CONTENT_SHIFT = 115000
DIVIDER = (335359, 807730, 11520001, 67235)      # 红橙渐变分隔线
LOGO = (9556115, 224790, 2265680, 467995)        # 右上 logo
CORNER = (11568608, 6444602, 425116, 338554)     # 右下装饰块
FONT = "微软雅黑"
CONTENT_LAYOUT_NAME = "2_仅标题空内容"
ASSETS = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "assets")


def set_run(run, size, bold, color, font=FONT):
    """重建 rPr：DrawingML 要求 solidFill 在 latin/ea/cs 之前，且 latin→ea→cs 有序。"""
    xml = (
        f'<a:rPr xmlns:a="{A_NS}" lang="zh-CN" altLang="en-US" '
        f'sz="{int(size * 100)}" b="{1 if bold else 0}" dirty="0">'
        f'<a:solidFill><a:srgbClr val="{color}"/></a:solidFill>'
        f'<a:latin typeface="{font}"/><a:ea typeface="{font}"/><a:cs typeface="{font}"/>'
        f"</a:rPr>"
    )
    r = run._r
    new = etree.fromstring(xml)
    old = r.find(qn("a:rPr"))
    if old is not None:
        r.replace(old, new)
    else:
        r.insert(0, new)


def style_frame(tf, size, color, bold=True, align=PP_ALIGN.LEFT):
    tf.word_wrap = True
    for p in tf.paragraphs:
        p.alignment = align
        for r in p.runs:
            set_run(r, size, bold, color)


def unify_font_family(shape, font=FONT):
    """整框替换历史字体残留（华文细黑 / Calibri / 等线 / 宋体 …）→ 微软雅黑。"""
    xml = shape._element.xml
    if any(f'typeface="{old}"' in xml
           for old in ("华文细黑", "Calibri Light", "Calibri", "等线", "宋体", "Arial")):
        new_xml = xml
        for old in ("华文细黑", "Calibri Light", "Calibri", "等线", "宋体", "Arial"):
            new_xml = new_xml.replace(f'typeface="{old}"', f'typeface="{font}"')
        shape._element.getparent().replace(shape._element, etree.fromstring(new_xml))


def is_fullpage_rect(sh):
    return (sh.left == 0 and sh.top == 0
            and (sh.width or 0) >= SLIDE_W - 2000 and (sh.height or 0) >= SLIDE_H - 8000)


def rewrite_layout_rels(path, pairs):
    """pairs: [(slide_partname, layout_partname)] —— zip 层改写 slideLayout 关系目标。"""
    if not pairs:
        return
    mapping = {
        str(sp).replace("/ppt/slides/", "ppt/slides/_rels/") + ".rels":
        str(lp).replace("/ppt/", "../")
        for sp, lp in pairs
    }
    tmp = path + ".tmp"
    with zipfile.ZipFile(path) as zin, zipfile.ZipFile(tmp, "w", zipfile.ZIP_DEFLATED) as zout:
        for item in zin.infolist():
            data = zin.read(item.filename)
            if item.filename in mapping:
                txt = data.decode("utf-8")
                txt, n = re.subn(r'(Type="[^"]*/slideLayout"[^>]*Target=")[^"]+(")',
                                 lambda m: m.group(1) + mapping[item.filename] + m.group(2),
                                 txt)
                if n != 1:
                    raise RuntimeError(f"layout rel 改写失败: {item.filename} ({n} 处)")
                data = txt.encode("utf-8")
            zout.writestr(item, data)
    shutil.move(tmp, path)


def draw_header(slide, only_missing=True):
    """draw 模式下在页面自绘页头装饰（分隔线 + logo + 右下装饰块）。"""
    existing = {sh.name for sh in slide.shapes}
    if not only_missing or "TYSZ分隔线" not in existing:
        pic = slide.shapes.add_picture(os.path.join(ASSETS, "tysz-header-divider.jpeg"),
                                       Emu(DIVIDER[0]), Emu(DIVIDER[1]),
                                       Emu(DIVIDER[2]), Emu(DIVIDER[3]))
        pic.name = "TYSZ分隔线"
    if not only_missing or "TYSZ Logo" not in existing:
        pic = slide.shapes.add_picture(os.path.join(ASSETS, "tysz-logo.png"),
                                       Emu(LOGO[0]), Emu(LOGO[1]),
                                       Emu(LOGO[2]), Emu(LOGO[3]))
        pic.name = "TYSZ Logo"
    if not only_missing or "TYSZ装饰块" not in existing:
        from pptx.enum.shapes import MSO_SHAPE
        sh = slide.shapes.add_shape(MSO_SHAPE.RECTANGLE, Emu(CORNER[0]), Emu(CORNER[1]),
                                    Emu(CORNER[2]), Emu(CORNER[3]))
        sh.name = "TYSZ装饰块"
        sh.fill.solid()
        sh.fill.fore_color.rgb = __import__("pptx.dml.color", fromlist=["RGBColor"]).RGBColor(0xC0, 0x00, 0x00)
        sh.line.fill.background()
        sh.shadow.inherit = False


def title_already_styled(slide):
    """该页标题是否已符合 TYSZ 规范（已排好版 → 不要再次下移正文，保证幂等）。"""
    for sh in slide.shapes:
        if not sh.has_text_frame or not sh.text_frame.text.strip():
            continue
        if (sh.top or 0) >= 500000:
            continue
        xml = sh._element.xml
        return ("2800" in re.findall(r'sz="(\d+)"', xml)
                and "C00000" in xml and FONT in xml
                and (sh.left, sh.top) == (TITLE_BOX[0], TITLE_BOX[1]))
    return False


def process(args):
    prs = Presentation(args.pptx)
    layouts = {l.name: l for l in prs.slide_masters[0].slide_layouts}
    if args.mode == "layout" and CONTENT_LAYOUT_NAME not in layouts:
        raise SystemExit(
            f"当前 deck 没有版式「{CONTENT_LAYOUT_NAME}」→ 请改用 --mode draw；"
            f"现有版式：{list(layouts)}")

    pending, rows = [], []
    for idx, slide in enumerate(prs.slides, start=1):
        if idx < args.from_page:
            continue
        if args.mode == "layout":
            for sh in list(slide.shapes):
                if is_fullpage_rect(sh):
                    sh._element.getparent().remove(sh._element)
            pending.append((slide.part.partname, layouts[CONTENT_LAYOUT_NAME].part.partname))
        else:
            draw_header(slide)

        for sh in list(slide.shapes):
            if not sh.has_text_frame or not sh.text_frame.text.strip():
                continue
            top = sh.top or 0
            if top < 500000:                                   # 标题
                sh.left, sh.top, sh.width, sh.height = TITLE_BOX
                style_frame(sh.text_frame, TITLE[0], TITLE[1])
                unify_font_family(sh)
            elif 500000 <= top <= 1000000:                     # 导语
                sh.left, sh.top, sh.width, sh.height = LEAD_BOX
                style_frame(sh.text_frame, LEAD[0], LEAD[1])

        for sh in list(slide.shapes):
            if sh.name.startswith("TYSZ"):                     # 自绘装饰件保持原位
                continue
            if sh.has_text_frame and sh.text_frame.text.strip():
                unify_font_family(sh)                          # 全页字体归一

        # 幂等：标题已符合规范说明该页已排好版 → 不再整体下移，只做校验
        if args.no_shift or title_already_styled(slide):
            rows.append((idx, round(max(((s.top or 0) + (s.height or 0)) for s in slide.shapes
                                       if (s.top or 0) < FOOTER_BAND) / 914400, 2), 0.0))
            continue

        for sh in list(slide.shapes):
            if sh.name.startswith("TYSZ"):
                continue
            top = sh.top or 0
            if 1000000 <= top < FOOTER_BAND:                   # 正文整体下移
                sh.top = top + CONTENT_SHIFT
            elif top >= FOOTER_BAND:                           # 页脚归一 + 避让装饰块
                sh.top = FOOTER_TOP
                if (sh.left or 0) > 8000000 and sh.width:
                    sh.width = max(1000000, FOOTER_RIGHT_LIMIT - sh.left)

        content_bottom = max(
            ((s.top or 0) + (s.height or 0)) for s in slide.shapes
            if (s.top or 0) < FOOTER_BAND) if len(slide.shapes) else 0
        overflow = max(0, content_bottom - FOOTER_TOP)
        rows.append((idx, round(content_bottom / 914400, 2), round(overflow / 914400, 3)))

    print(f"{'页':>4} {'内容底(in)':>11} {'压页脚(in)':>11}")
    for r in rows:
        print(f"{r[0]:>4} {r[1]:>11} {r[2]:>11}")
    bad = [r for r in rows if r[2] > 0]
    if bad:
        print(f"\n⚠️ {len(bad)} 页内容压页脚：{ [r[0] for r in bad] } —— 请减小 --content-shift 或下移 --footer-top")

    if args.dry_run:
        print("\n[dry-run] 未写盘")
        return 1 if bad else 0
    prs.save(args.pptx)
    if args.mode == "layout":
        rewrite_layout_rels(args.pptx, pending)
        print(f"\n已写盘；{len(pending)} 页版式指向 {CONTENT_LAYOUT_NAME}")
    else:
        print(f"\n已写盘；{len(rows)} 页自绘 TYSZ 页头")
    return 1 if bad else 0


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("pptx")
    ap.add_argument("--mode", choices=["layout", "draw"], default="layout")
    ap.add_argument("--from-page", type=int, default=1)
    ap.add_argument("--no-shift", action="store_true",
                    help="只统一页头样式/字体，不下移正文（对已排好版的 deck 安全）")
    ap.add_argument("--dry-run", action="store_true")
    args = ap.parse_args()
    raise SystemExit(process(args))


if __name__ == "__main__":
    main()
