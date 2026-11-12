# TYSZ-PPT Adapter

## Engine
`engines/tysz-ppt/SKILL.md` — 天翼数字生活（TYSZ）红蓝工作汇报风 PPT 模板引擎

## Capabilities
- 从打包的基础模板（`.pptx` 母版 + 两套版式）**新建**一份汇报 deck（封面 + 内容页骨架）
- 把**已有** deck（python-pptx / slidep / tencent-pptx 等产出）套成 TYSZ 页头风格
- 结构自检：版式名、越界、内容压页脚、页头安全区、字体残留、标题规格
- 逐页 PNG 预览（macOS 走 Keynote，其它平台回退 LibreOffice + pdftoppm）
- 封面主视觉 / 内容页插图由 **gpt-image-gen** 生成，风格 brief 取自
  `engines/gpt-image-gen/references/天翼数字生活风格.md`

## Output
- `.pptx`（可编辑，原生 Office 文件）
- `.png`（逐页预览，仅用于目视 QA，不是交付物）

## Prerequisites
- Python 3.9+
- `python-pptx`（`pip install python-pptx`，已含 `lxml`）
- `Pillow` —— 仅 `extract_template.py` 需要
- `openai` + `OPENAI_API_KEY` —— 仅在用 gpt-image-gen 生成配图时需要

## Configuration

无需 API key 即可完成**新建 / 套用 / 自检**。只有在生成配图时才需要
`OPENAI_API_KEY`，检查方式与 gpt-image 引擎一致（env 优先，其次
`engines/gpt-image-gen/.env`）。

## Execution

1. **Load the upstream skill**: Read `engines/tysz-ppt/SKILL.md`
2. **Verify runtime** (see `references/runtime-check.md` → `### tysz-ppt`)
3. **Choose the workflow**:

   | Situation | Workflow | Command |
   |---|---|---|
   | 新建一份 TYSZ 风格汇报 | A. scaffold | `python3 engines/tysz-ppt/scripts/scaffold_deck.py --out deck.pptx --deck-title ... --cover-title ... --pages-file pages.txt` |
   | 已有 deck 套成 TYSZ 风格 | B. apply | `python3 engines/tysz-ppt/scripts/apply_tysz_style.py deck.pptx --mode layout`（deck 已含 TYSZ 版式）或 `--mode draw`（其它来源） |
   | 交付前自检 | C. validate | `python3 engines/tysz-ppt/scripts/validate_deck.py deck.pptx` |

4. **Fill the body** with python-pptx（表格 / 双面板 / 卡片网格）——组件规范见
   `engines/tysz-ppt/references/style-spec.md` 第 6 节
5. **Generate images**（可选）——见下方「配图」
6. **Validate + preview**（必做）——`validate_deck.py` 异常页为 0，并目视抽查截图

## 配图：沿用 gpt-image-gen 的图片生成样式

图片**不由本引擎生成**，而是复用 gpt-image-gen 的风格 brief 体系，保证 PPT 配图
与图表工具箱其它引擎的视觉语言一致。

1. **选 brief**：首选 `engines/gpt-image-gen/references/天翼数字生活风格.md`
   ——它是 `强电信风格.md` 的 TYSZ 变体，只用 TYSZ 五色色板
   （`#C00000 / #000000 / #404040 / #DDEBF7 / #5B9BD5`），且明确不重画页头
   分隔线与右上 logo。其余 brief（麦肯锡风格 / 清爽专业风 / 教学课件风 …）可用，
   但需把主色收敛到 `#C00000` 家族。
2. **生成**：

   ```bash
   python3 engines/gpt-image-gen/scripts/image_gen.py generate \
     --prompt "<brief 的 visual_direction + color_palette + typography 摘要>" \
     --size 1536x1024 --quality high --out cover-art.png --force
   ```

   > `image_gen.py` 只在**完整 release 包**中提供；`-secure` 构建不含脚本。

3. **落位**：封面主视觉位 `2000250, 3629025, 8191500, 1257300`（见 style-spec 第 5 节），
   或插入内容页正文区（`top ≥ 1000000`，底边 `≤ 6630000`）。

## 硬约束（引擎级，违反即返工）

1. 只用 TYSZ 五色色板；灰阶用黑色 + 透明度。
2. 全文字体微软雅黑（`latin`/`ea`/`cs` 三处都写），清掉 `华文细黑` 等残留。
3. 内容页标题 28pt 粗体 `#C00000`；封面 39pt 粗体 `#C00000`（`wrap=false`）。
4. 正文不进入 y < 1000000，不越过 y = 6630000。
5. 每页至少一个"结论性标题"。
6. 交付前 `validate_deck.py` 异常页为 0 + 目视抽查。

## When to Use This Engine

- 用户要做「TYSZ / 天翼数字生活 / 工作汇报模板」风格的 PPT
- 用户要「新建一份 PPT 模板 / 从模板起一份汇报」
- 用户要把现有 pptx「套成公司模板样式 / 统一页头」
- 用户明确提到 TYSZ、天翼数字生活、红蓝工作汇报风

## When NOT to Use

- 只要一张架构图 / 流程图 → 用 fireworks / mermaid / gpt-image
- 只想看排版效果、不需要可编辑 pptx → 用 gpt-image 直接出整页图
- 其它公司模板风格 → 本引擎只覆盖 TYSZ 色板与版式
