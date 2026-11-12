---
name: tysz-ppt
description: >-
  天翼数字生活（TYSZ）红蓝工作汇报风 PPT 模板引擎：白底、微软雅黑、红色
  #C00000 标题与关键词强调、红橙渐变页头分隔线 + 右上 logo、浅蓝 #DDEBF7
  表头表格、#5B9BD5 圆角标签与图示、9pt 半透明页脚。用于"按 TYSZ/天翼数字生活/
  工作汇报模板风格做一份 PPT""把这份 PPT 套成 TYSZ 模板样式""统一页头为红色
  标题+分隔线+logo""从这套模板新建一份汇报"，并支持用 gpt-image-gen 的
  references 风格 brief 生成配图。触发词：TYSZ、天翼数字生活 PPT 模板、红蓝工作
  汇报风、红色标题风格、套用公司 PPT 模板、PPT 统一样式、PPT 模板创建。
description_en: >-
  TYSZ (China Telecom Digital Life) red/blue corporate report PPT template
  engine. Creates decks from a packaged .pptx master, restyles existing decks,
  validates layout, and pairs with gpt-image-gen style briefs for cover art.
agent_created: true
---

# TYSZ-PPT：天翼数字生活 PPT 模板引擎

只提供**样式能力**（版式、色板、字体、页头页脚装饰、组件规范），不携带任何具体业务内容。
完整设计令牌与几何规格见 `references/style-spec.md`（开始改/画任何页面之前先读它）。

引擎目录（本 SKILL.md 所在目录）即下文的 `ENGINE_DIR`：

```bash
ENGINE_DIR="engines/tysz-ppt"   # 相对 chart-toolkit 根目录
```

脚本内部用 `HERE/../assets` 定位资产，因此**必须从引擎目录内或用绝对路径调用**：

```bash
python3 "$ENGINE_DIR/scripts/scaffold_deck.py" --out new.pptx ...
```

## 何时使用

- 「按 TYSZ 模板 / 天翼数字生活 / 工作汇报模板风格做一份 PPT」
- 「把这份 PPT 套成这个模板样式」「统一页头：红色标题 + 渐变分隔线 + 右上 logo」
- 「拿第 N 页的样式复制到其他页」「页面风格不一致，统一一下」
- 从模板新建一份汇报（封面 + 内容页骨架）

## 资产（assets/）

| 文件 | 用途 |
|---|---|
| `tysz-base-template.pptx` | **基础模板**：白底母版 + `1_标题页` / `2_仅标题空内容` 两套版式，含页头装饰图片，0 页。直接 `Presentation()` 后 `add_slide()` 即可 |
| `tysz-header-divider.jpeg` | 页头红橙渐变分隔线（1549×16） |
| `tysz-logo.png` | 右上「天翼数字生活」logo（1400×289） |
| `tysz-cover-logo.png` / `tysz-cover-bg.jpeg` | 封面双 logo / 左下彩色波浪底图 |
| `tysz-cover-art.png` / `.svg` | 封面主视觉（告警洪泛 → AI Agent → 证据驱动结论） |

## 三条标准工作流

### A. 新建一份 TYSZ 风格 deck（推荐）

```bash
python3 "$ENGINE_DIR/scripts/scaffold_deck.py" --out new.pptx \
    --deck-title "汇报主题（用于页脚）" \
    --cover-title "封面主标题" --cover-subtitle "副标题一句话" \
    --cover-footer "部门 · 团队 · 2026 年 10 月" \
    --pages-file pages.txt        # 每行一页：`标题 || 导语`（导语可省）
```

产出封面 + N 页内容骨架，页头页脚已按规范就位，正文区（y 1000000–6450000）留空。
随后用 python-pptx 往正文区填表格 / 双面板 / 卡片网格 —— 组件规范见
`references/style-spec.md` 第 6 节；**只复刻样式，不引入任何非 TYSZ 色值**。

### B. 把已有 deck 套成 TYSZ 页头风格

```bash
python3 "$ENGINE_DIR/scripts/apply_tysz_style.py" deck.pptx --dry-run          # 先看清单与重叠量
python3 "$ENGINE_DIR/scripts/apply_tysz_style.py" deck.pptx --mode layout      # deck 已含 TYSZ 版式
python3 "$ENGINE_DIR/scripts/apply_tysz_style.py" deck.pptx --mode draw        # 别的模板来源，直接画页头装饰
```

脚本做 5 件事：删全幅白矩形 → 版式指向 `2_仅标题空内容`（或自绘装饰三件套）→
标题对齐几何并设 28pt 粗体 `#C00000` 微软雅黑 → 导语 16pt `#404040` 下移到分隔线之下 →
正文整体下移 + 页脚归一避让右下装饰块；并报告「内容压页脚」的重叠量。
**注意：`--mode layout` 会整体下移正文，对已排好版的 deck 只跑一次，不要反复执行。**

### C. 交付前自检（必做）

```bash
python3 "$ENGINE_DIR/scripts/validate_deck.py" deck.pptx          # 结构自检，退出码非 0 表示有问题
python3 "$ENGINE_DIR/scripts/export_preview.py" deck.pptx --out /tmp/preview   # 逐页 PNG 目视
```

自检覆盖：版式名 / 全幅白矩形残留 / 越界 / 内容压页脚 / 正文顶入页头安全区 /
字体残留（华文细黑、Calibri、等线、宋体）/ 标题是否 28pt `#C00000`。
`export_preview.py` 在 macOS 走 Keynote（导出副本，不动交付文件），其他平台回退 LibreOffice + pdftoppm。
**目视至少抽查封面、最复杂的一页、附录表格页。**

## 配图：沿用 gpt-image-gen 的图片生成样式

本引擎只负责**版式与正文**；封面主视觉 / 内容页插图用
`engines/gpt-image-gen` 生成，**风格 brief 复用它的 references 目录**，
这样 PPT 的视觉语言与图表工具箱其它引擎保持一致。

### 配图流程

1. 选风格 brief：读 `engines/gpt-image-gen/references/<风格名>.md`，取出其中的 JSON brief。
   **首选 `天翼数字生活风格.md`**——它是专为本引擎定制的 TYSZ 变体，只用 TYSZ 五色
   色板，且明确不重画页头分隔线与右上 logo。其余风格（强电信风格 / 麦肯锡风格 /
   清爽专业风 / 教学课件风 …）也可用，但需把 brief 里的主色收敛到 TYSZ 的 `#C00000` 家族。
2. 生成配图：

   ```bash
   python3 engines/gpt-image-gen/scripts/image_gen.py generate \
       --prompt "<brief 的 visual_direction + color_palette + typography 摘要>" \
       --size 1536x1024 --quality high --out cover-art.png --force
   ```

   > `image_gen.py` 只在**完整 release 包**中提供；`-secure` 构建不含脚本，
   > 此时请改用其它引擎出图，或从 release 获取完整包。

3. 落位：把生成图替换进封面主视觉位（`references/style-spec.md` 第 5 节：
   `2000250, 3629025, 8191500, 1257300`），或插入内容页正文区。
   **生成的位图不要压住页头分隔线与右上 logo**（正文安全区 top ≥ 1000000）。

### 与 TYSZ 样式的硬性对齐

- 生成的配图只能出现 TYSZ 色板里的色值：`#C00000 / #000000 / #404040 / #DDEBF7 / #5B9BD5`。
- 生成图里的中文字体按 brief 的 `'Microsoft YaHei','PingFang SC',Arial,sans-serif` 走，
  与 deck 正文的微软雅黑保持一致。
- 生成的图**不替代**版式自带的页头装饰（渐变分隔线 / logo / 右下装饰块）。

## 其它脚本

```bash
# 从任意已含 TYSZ 样式的 pptx 重新抽出基础模板 / 媒体 / 机器可读规格
python3 "$ENGINE_DIR/scripts/extract_template.py" 源deck.pptx --out assets/tysz-base-template.pptx \
        --spec-out references/extracted-spec.json
```

## 运行依赖

| 依赖 | 必需 | 说明 |
|---|---|---|
| `python-pptx` | ✔ | `pip install python-pptx` |
| `lxml` | ✔ | python-pptx 已依赖 |
| `Pillow` | ✘ | 仅 `extract_template.py` 处理媒体时需要 |
| `openai` + `OPENAI_API_KEY` | ✘ | 仅在用 gpt-image-gen 生成配图时需要 |

## 硬约束（违反即返工）

1. 全套只用 `#C00000 / #000000 / #404040 / #DDEBF7 / #5B9BD5`，灰阶一律用黑色 + `a:alpha`。
2. 全文字体 **微软雅黑**（`latin`/`ea`/`cs` 三处都写），清掉 `华文细黑` 等残留。
3. 内容页标题 28pt 粗体 `#C00000`；封面 39pt 粗体 `#C00000`（`wrap=false`）。
4. 正文不得进入 y < 1000000（页头安全区）、不得越过 y = 6630000（页脚线）。
5. 每页至少要有一个"结论性标题"（标题即观点），正文才展开论据。
6. 交付前必须跑 `validate_deck.py` 且异常页为 0，并目视抽查截图。
