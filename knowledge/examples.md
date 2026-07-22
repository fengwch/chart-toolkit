# Example Prompts & Case Studies

Use these as reference when guiding users through interactive generation.

## Example 1: Architecture Diagram

**User says:** "画一个微服务架构图，文档用"

**Toolkit response (Phase 2):**
```
分析结果：微服务架构 | 复杂度: 中高 | 输出: 技术文档

推荐图表方案:

A. ⭐ 系统架构图 — fireworks Style3 蓝图风
   → SVG+PNG, 1920px 高分辨率
   → 最适合技术文档

B. C4 Container 评审图 — fireworks Style9
   → SVG+PNG, 单一抽象层级
   → 适合架构评审会议

C. 可编辑架构图 — Drawio
   → .drawio, 浏览器实时编辑
   → 适合需要团队协作修改

D. 架构代码块 — Mermaid
   → .md, GitHub/README 原生渲染
   → 适合轻量文档嵌入

请选择 1 个或多个方案 (A/B/C/D)：
```

## Example 2: Flowchart for README

**User says:** "make a flowchart for my CI/CD pipeline in README"

**Toolkit response (Phase 2):**
```
Analysis: CI/CD pipeline | Complexity: medium | Output: GitHub README

Proposed chart types:

A. ⭐ Mermaid Flowchart — .md code block
   → GitHub-native rendering, no image hosting needed
   → Best for README

B. Fireworks Flowchart — SVG+PNG
   → Higher visual quality
   → Requires image hosting (raw.githubusercontent.com)

C. Drawio Editable — .drawio
   → Browser editing, export as PNG for README
   → Good if you need to hand-adjust later

Pick one or more (A/B/C):
```

## Example 3: Mind Map for Study Notes

**User says:** "帮我把这篇关于 Transformer 的文章整理成思维导图"

**Toolkit response (Phase 2):**
```
分析结果：知识整理 | 层级结构 | 个人笔记 | Obsidian 环境

推荐图表方案:

A. ⭐ Canvas 思维导图 — Obsidian Canvas
   → .canvas, 原生 Obsidian 渲染
   → 可以拖拽调整、折叠展开

B. 手绘思维导图 — Excalidraw
   → .md, Excalidraw 手绘风格
   → 更有"笔记感"

C. Mermaid Mindmap — .md 代码块
   → 纯文本，可版本控制
   → 便于后续修改

请选择方案 (A/B/C)：
```

## Example 4: Data Dashboard

**User says:** "show me a dashboard of our Q2 sales data"

**Toolkit response (Phase 2):**
```
Analysis: Data visualization | Sales metrics | Dashboard format

Proposed chart types:

A. ⭐ Dataviz Dashboard — HTML + SVG
   → Interactive, KPI cards, dark/light mode
   → Best for business review

B. Fireworks Comparison — SVG+PNG
   → Static side-by-side comparison
   → Good for embedding in slides

C. Mermaid Gantt — .md
   → Timeline of quarterly milestones
   → Complementary to the dashboard

Pick one or more (A/B/C):
```
