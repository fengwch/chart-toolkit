# Style Catalog

Complete inventory of all available visual styles across all engines.

## Fireworks Tech Graph (12 styles)

| # | Name | Best For | Color Palette | Key Visual |
|---|---|---|---|---|---|
| 1 | Flat Icon (default) | General architecture, clean look | Blue/Green/Gray with flat icons | Modern, icon-anchored |
| 2 | Dark Terminal | AI/Agent workflows, dev tools | Dark bg, neon green/cyan accents | Terminal-inspired, geek aesthetic |
| 3 | Blueprint | Microservices, complex systems | White bg, blueprint blue lines | Engineering grid, precision |
| 4 | Notion Minimal | Simple overviews, management | White bg, gray text, subtle accent | Clean, typographic, minimal |
| 5 | Glass Card | Multi-agent, dashboard | Frosted glass cards, soft shadows | Layered, translucent |
| 6 | Claude Official | System architecture, AI systems | Warm tones, Claude brand colors | Friendly, polished |
| 7 | OpenAI Official | API flows, integrations | OpenAI brand green/black | Professional, branded |
| 8 | Dark Luxury (AI-drawn) | Premium presentations, clients | Dark bg, champagne gold lines | Luxury, hand-crafted |
| 9 | C4 Review Canvas | Architecture review | Engineering blue, structured | Single abstraction level |
| 10 | Cloud Fabric | Multi-region deployment | Neutral cloud icons, region colors | Infrastructure topology |
| 11 | Event Transit | Event-driven, messaging | Metro-map lines, station nodes | Event flow clarity |
| 12 | Ops Pulse | SRE, monitoring, reliability | Signal colors (green/yellow/red) | Golden signals, traces |

## Mermaid Visualizer (4 built-in + unlimited custom)

| Name | Key Feature |
|---|---|
| Professional (default) | Semantic colors (green=start, red=decision, purple=processing, orange=action) |
| Minimal | Monochrome, clean lines |
| Colorful | Vibrant, high contrast |
| Academic | Formal, publication-ready |

**Mermaid palette reference:**
- Green (#2f9e44): Input, Perception, Start
- Red (#c92a2a): Planning, Decision
- Purple (#5f3dc4): Processing, Reasoning
- Orange (#d9480f): Actions, Tools
- Cyan (#0c8599): Output, Execution
- Yellow (#e67700): Storage, Memory

## Excalidraw Diagram

| Mode | Aesthetic | Output |
|---|---|---|
| Obsidian (default) | Hand-drawn, Excalifont | .md (embedded) |
| Standard | Hand-drawn, Excalifont | .excalidraw |
| Animated | Hand-drawn + animation timeline | .excalidraw (+ excalidraw-animate) |

## Obsidian Canvas

| Layout | Aesthetic |
|---|---|
| MindMap | Radial, color-coded nodes (6 presets) |
| Freeform | Custom positions, curved edges |

## Drawio

Drawio uses its own built-in style system (sketch, minimal, etc.) selected within the browser UI.

## Dataviz

Dataviz uses a design-system-agnostic method with a replaceable palette file (`references/palette.md`). Default: brand-neutral professional palette with dark mode support.

## TYSZ-PPT (天翼数字生活工作汇报风)

单一品牌模板，色板锁定为 5 个 hex。

| Element | Value | Usage |
|---|---|---|
| Primary red | `#C00000` | 标题、关键词强调、结论条、流程连接线 |
| Black | `#000000` | 正文（需要次要时用黑色 + 透明度） |
| Lead gray | `#404040` | 标题下的导语行（观点句） |
| Table header blue | `#DDEBF7` | 表格表头底、浅色面板 |
| Label blue | `#5B9BD5` | 圆角标签、流程图节点、图标底块 |

- 字体：全篇**微软雅黑**（`latin`/`ea`/`cs` 三处都写），清掉 `华文细黑` 等残留
- 字号阶梯：封面标题 39pt 粗 / 页面标题 28pt 粗 / 导语 16pt 粗 / 正文 16–18pt / 表格 15pt / 页脚 9pt
- 正文安全区：`top ≥ 1000000`（页头），底边 `≤ 6630000`（页脚线）
- 配图风格 brief：`engines/gpt-image-gen/references/天翼数字生活风格.md`（gpt-image-gen references 体系内的 TYSZ 变体）

## GPT Image Gen (14 style briefs)

| # | Style | File | Best For |
|---|---|---|---|
| 1 | 麦肯锡风格 | `engines/gpt-image-gen/references/麦肯锡风格.md` | Business consulting, strategy decks |
| 2 | 数据仪表盘风 | `engines/gpt-image-gen/references/数据仪表盘风.md` | KPI dashboards, BI reports |
| 3 | 手绘白板风 | `engines/gpt-image-gen/references/手绘白板风.md` | Teaching, brainstorming |
| 4 | 手绘技术解释风 | `engines/gpt-image-gen/references/手绘技术解释风.md` | Technical explanations |
| 5 | 清爽专业风 | `engines/gpt-image-gen/references/清爽专业风.md` | Clean professional presentations |
| 6 | 创意杂志风 | `engines/gpt-image-gen/references/创意杂志风.md` | Creative editorial |
| 7 | 科研答辩风 | `engines/gpt-image-gen/references/科研答辩风.md` | Academic defense |
| 8 | 教学课件风 | `engines/gpt-image-gen/references/教学课件风.md` | Teaching courseware |
| 9 | 党政红风格 | `engines/gpt-image-gen/references/党政红风格.md` | Government, official reports |
| 10 | 复古扁平插画风 | `engines/gpt-image-gen/references/复古扁平插画风.md` | Retro flat illustrations |
| 11 | 温暖手工风 | `engines/gpt-image-gen/references/温暖手工风.md` | Warm handmade, craft |
| 12 | 电子墨水杂志风 | `engines/gpt-image-gen/references/电子墨水杂志风.md` | E-ink magazine |
| 13 | 强电信风格 | `engines/gpt-image-gen/references/强电信风格.md` | China Telecom corporate brand decks |
| 14 | 天翼数字生活风格 | `engines/gpt-image-gen/references/天翼数字生活风格.md` | TYSZ decks — pairs with `engines/tysz-ppt` |
