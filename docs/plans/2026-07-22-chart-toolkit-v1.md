# Chart Toolkit v1.0 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a cross-Agent, cross-platform unified chart generation Skill that integrates 6 backend engines (Drawio, Fireworks, Mermaid, Excalidraw, Canvas, Dataviz) into one intelligent entry point.

**Architecture:** Pure Markdown prompt routing with adapters wrapping upstream engines. `chart-toolkit.md` is the soul — an Agent-agnostic prompt that performs intent analysis → chart proposal → deep interview → orchestration. Shell scripts handle one-command setup across macOS/Linux/Windows.

**Tech Stack:** Bash/Shell (POSIX), PowerShell (.ps1), Markdown (prompts). No compiled code. Upstream engines via `git clone --depth 1 -b <tag>`.

## Global Constraints

- All prompt files MUST be pure Markdown, Agent-agnostic (no Claude-specific tool references in core files)
- Platform support: macOS, Linux (setup.sh), Windows (setup.ps1/setup.bat + Git Bash)
- Engine versions locked by git tag: fireworks@v1.0.4, axton-obsidian-visual-skills@main
- `chart-toolkit.md` MUST stay under ~300 lines; detailed knowledge in knowledge/ directory
- Installation MUST work as `./setup.sh` (no arguments) or `curl ... | bash`
- Cross-Agent: Claude Code, Codex supported in v1.0; Hermes/Claw/QCoder deferred to v1.1
- MIT License

---

### Task 1: Project Scaffolding

**Files:**
- Create: `chart-toolkit/.gitignore`
- Create: `chart-toolkit/LICENSE`
- Create: empty directories

**Interfaces:**
- Produces: Project root with all empty directories ready for subsequent tasks

- [ ] **Step 1: Create all directories**

```bash
cd /Users/fengwanchang/Documents/Obsidian/06-AI工具/chart-toolkit
mkdir -p engines adapters knowledge agents scripts docs
```

- [ ] **Step 2: Write .gitignore**

```gitignore
# Engines - cloned at setup time, not committed
engines/

# OS
.DS_Store
Thumbs.db

# Python
__pycache__/
*.pyc
*.egg-info/

# IDE
.vscode/
.idea/

# Output files (users generate diagrams into their working dir)
*.svg
*.png
*.drawio
*.excalidraw
*.canvas
!docs/**/*.svg
!docs/**/*.png
```

- [ ] **Step 3: Write LICENSE (MIT)**

```
MIT License

Copyright (c) 2026 Chart Toolkit Contributors

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

- [ ] **Step 4: Verify directory structure**

```bash
cd /Users/fengwanchang/Documents/Obsidian/06-AI工具/chart-toolkit
find . -type d | sort
# Expected: ./adapters, ./agents, ./docs, ./docs/plans, ./engines, ./knowledge, ./scripts
ls -la .gitignore LICENSE
```

- [ ] **Step 5: Commit**

```bash
cd /Users/fengwanchang/Documents/Obsidian/06-AI工具/chart-toolkit
git init
git add -A
git commit -m "chore: scaffold chart-toolkit project structure"
```

---

### Task 2: Knowledge Base — capability-matrix.md

**Files:**
- Create: `chart-toolkit/knowledge/capability-matrix.md`

**Interfaces:**
- Consumes: (none)
- Produces: Capability matrix used by `chart-toolkit.md` Phase 2 (Chart Proposal)

- [ ] **Step 1: Write capability-matrix.md**

```markdown
# Chart Capability Matrix

This is the master mapping: **chart type → best engine → output format**. Loaded by chart-toolkit during Phase 2 (Chart Proposal) to recommend 3-5 options to the user.

## Matrix

| # | Chart Type | Best Engine | Alt Engine | Output | Best For |
|---|---|---|---|---|---|
| 1 | System Architecture | fireworks (Style1/2/3/6) | Drawio | SVG+PNG / .drawio | Technical docs, design docs |
| 2 | C4 Container Review | fireworks (Style9) | Drawio | SVG+PNG / .drawio | Architecture review meetings |
| 3 | Cloud Deployment | fireworks (Style10) | Drawio | SVG+PNG / .drawio | Infrastructure docs |
| 4 | Data Flow Diagram | fireworks (Style1/2) | Mermaid | SVG+PNG / .md | API docs, data pipeline docs |
| 5 | Flowchart / Process | Mermaid (graph) | Drawio / fireworks | .md / .drawio / SVG | README, wiki, onboarding |
| 6 | Sequence Diagram | Mermaid (sequence) | fireworks | .md / SVG+PNG | API docs, interaction design |
| 7 | State Machine | Mermaid (state) | fireworks | .md / SVG+PNG | Lifecycle docs, status flows |
| 8 | Class Diagram (UML) | fireworks (UML) | Mermaid | SVG+PNG / .md | Code architecture docs |
| 9 | ER Diagram | fireworks (UML) | Mermaid | SVG+PNG / .md | Database design docs |
| 10 | Gantt / Timeline | Mermaid (gantt) | fireworks | .md / SVG+PNG | Project plans, roadmaps |
| 11 | Mind Map | Canvas (MindMap) | Excalidraw | .canvas / .md | Brainstorming, knowledge organization |
| 12 | Concept Map | Canvas (Freeform) | Excalidraw | .canvas / .md | Freeform exploration |
| 13 | Hand-drawn Diagram | Excalidraw | — | .md (Obsidian) / .excalidraw | Personal notes, Obsidian vault |
| 14 | Presentation Diagram | Drawio | fireworks | .drawio / SVG+PNG | Slides, collaboration |
| 15 | Data Visualization | Dataviz | — | HTML/SVG/PNG | Dashboards, reports, analytics |
| 16 | Event Stream / Metro | fireworks (Style11) | Mermaid | SVG+PNG / .md | Event-driven architecture docs |
| 17 | Reliability / SRE | fireworks (Style12) | Drawio | SVG+PNG / .drawio | Incident reviews, SLO docs |

## Decision Priority (when multiple engines match)

1. **Quality-first**: Prefer fireworks for technical accuracy, Mermaid for quick iteration
2. **Editability**: If user needs to edit later → Drawio or Excalidraw
3. **Embedding context**: In Obsidian → Excalidraw/Canvas; In GitHub → Mermaid; In docs → fireworks SVG+PNG
4. **Collaboration**: Drawio > Excalidraw > SVG
5. **Chinese text**: Excalidraw (hand-drawn CJK) > fireworks (SVG text) > Mermaid (limited)

## Engine Capability Boundaries

| Engine | What It CANNOT Do | Fallback |
|---|---|---|
| fireworks | Interactive editing, real-time collab | Drawio |
| Mermaid | Pixel-perfect layout, rich styling | fireworks |
| Excalidraw | UML precision, data viz | fireworks, Dataviz |
| Canvas | Print-ready export, animations | Excalidraw, fireworks |
| Drawio | Batch generation, programmatic | fireworks |
| Dataviz | Architecture diagrams, flowcharts | fireworks, Mermaid |
```

- [ ] **Step 2: Commit**

```bash
cd /Users/fengwanchang/Documents/Obsidian/06-AI工具/chart-toolkit
git add knowledge/capability-matrix.md
git commit -m "feat(knowledge): add capability matrix mapping 17 chart types to 6 engines"
```

---

### Task 3: Knowledge Base — decision-tree.md

**Files:**
- Create: `chart-toolkit/knowledge/decision-tree.md`

- [ ] **Step 1: Write decision-tree.md**

```markdown
# Decision Tree: Scene → Tool

This decision tree helps the intent analyzer (Phase 1) narrow down which chart types to propose. It is NOT used to auto-select — the user always gets a choice list. It's used to rank and filter the capability matrix results.

## Step 1: Identify the Output Medium

| If user is working in... | Bias toward... | Reason |
|---|---|---|
| Obsidian vault | Excalidraw, Canvas, Mermaid | Native embedding, interactive |
| GitHub / GitLab README | Mermaid, SVG (embedded) | Native Mermaid renderer |
| Technical document / Paper | fireworks SVG+PNG | High resolution, precise |
| Presentation / Slides | Drawio, fireworks PNG | Editable, high quality |
| Dashboard / Report | Dataviz | Data visualization focus |
| Whiteboard / Brainstorm | Canvas (MindMap), Excalidraw | Freeform, spatial |
| API Documentation | Mermaid (sequence), fireworks | Clear message flows |

## Step 2: Identify the Content Type

| If user describes... | Propose chart types... | Priority order |
|---|---|---|
| Components, services, layers | Architecture, C4, Cloud Deployment | 1→2→3→5 |
| Data flowing between systems | Data Flow, Sequence, Event Stream | 4→6→9 |
| Steps, stages, decisions | Flowchart, State Machine | 5→7 |
| Time-based progress | Gantt, Timeline, Sequence | 10→6 |
| Hierarchical knowledge | Mind Map, Concept Map | 11→12 |
| Code structure, classes | Class Diagram, ER | 8→9 |
| Numbers, statistics, KPIs | Data Visualization | 15 |
| "Just sketch it" / casual | Hand-drawn, Concept Map | 13→12 |
| Events, messaging, streaming | Event Stream, Data Flow | 16→4 |
| Reliability, SLO, monitoring | Reliability Pulse, Architecture | 17→1 |

## Step 3: Identify the Complexity Level

| Complexity | Signal | Recommended style |
|---|---|---|
| Simple (≤5 nodes) | "simple", "quick", "just show" | fireworks Style4 (Notion), Mermaid simple |
| Medium (5-15 nodes) | (default) | fireworks Style1 (Flat), Mermaid standard |
| Complex (15+ nodes) | "detailed", "comprehensive" | fireworks Style3 (Blueprint), Drawio |
| Multi-layer / Multi-region | "global", "multi-region", "layered" | fireworks Style10 (Cloud), Style9 (C4) |

## Step 4: Identify the Audience

| Audience | Style preference | Detail level |
|---|---|---|
| Engineers / Architects | fireworks Style2 (Dark), Style3 (Blueprint) | detailed |
| Management / PM | fireworks Style4 (Notion), Mermaid simple | simple |
| Public / Blog readers | fireworks Style6 (Claude), Style7 (OpenAI) | standard |
| Personal notes | Excalidraw, Canvas | any |
| Clients / External | fireworks Style8 (Dark Luxury), Drawio | standard |

## Conflict Resolution

When signals conflict, use this priority:
**Output Medium > Content Type > Complexity > Audience**
```

- [ ] **Step 2: Commit**

```bash
cd /Users/fengwanchang/Documents/Obsidian/06-AI工具/chart-toolkit
git add knowledge/decision-tree.md
git commit -m "feat(knowledge): add scene-to-tool decision tree"
```

---

### Task 4: Knowledge Base — style-catalog.md and examples.md

**Files:**
- Create: `chart-toolkit/knowledge/style-catalog.md`
- Create: `chart-toolkit/knowledge/examples.md`

- [ ] **Step 1: Write style-catalog.md**

```markdown
# Style Catalog

Complete inventory of all available visual styles across all engines.

## Fireworks Tech Graph (12 styles)

| # | Name | Best For | Color Palette | Key Visual |
|---|---|---|---|---|
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
```

- [ ] **Step 2: Write examples.md**

```markdown
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
```

- [ ] **Step 3: Commit**

```bash
cd /Users/fengwanchang/Documents/Obsidian/06-AI工具/chart-toolkit
git add knowledge/style-catalog.md knowledge/examples.md
git commit -m "feat(knowledge): add style catalog and usage examples"
```

---

### Task 5: Core Prompt — chart-toolkit.md

**Files:**
- Create: `chart-toolkit/chart-toolkit.md`

**Interfaces:**
- Consumes: `knowledge/capability-matrix.md`, `knowledge/decision-tree.md`, `knowledge/style-catalog.md`, `knowledge/examples.md`, `adapters/*.md`
- Produces: The main skill prompt that any Agent loads. Orchestrates all 4 phases.

- [ ] **Step 1: Write chart-toolkit.md**

```markdown
---
name: chart-toolkit
description: >-
  Unified chart generation entry point. Automatically analyzes user intent,
  proposes 3-5 chart types with tool recommendations, conducts interactive deep
  interviews, and orchestrates the best backend engine. Supports architecture
  diagrams, flowcharts, sequence diagrams, mind maps, hand-drawn sketches, data
  visualization, and all 17 chart types. Cross-Agent (Claude Code, Codex, any
  Markdown-skill Agent). Triggers on: "画图" "画架构图" "画流程图" "画思维导图"
  "可视化" "生成图表" "帮我画" "draw diagram" "create chart" "generate diagram"
  "visualize" "chart" "diagram" "architecture diagram" "flowchart" "mind map".
---

# Chart Toolkit

Unified chart generation — describe what you need, get a curated list of chart
types, choose, then receive a polished diagram from the best backend engine.

## Hard Rules (DO NOT SKIP)

1. **ALWAYS complete Phase 2 (Chart Proposal) before any generation.** Never
   jump straight to drawing. The user must see options and choose.
2. **Present 3-5 chart type options**, each with: name, recommended tool,
   output format, and one-line use case. Rank best option first (marked ⭐).
3. **Wait for user selection** before proceeding to Phase 3.
4. **Deep Interview (4 questions) comes BEFORE Standard 4 Questions.** Ask
   one question at a time, adapt based on the selected chart type.
5. **Load adapters on demand** — only load the adapter for the engine the user
   selected. Do not load all adapters at once.
6. **Do NOT convert between formats.** Each engine produces its own best
   format. If the user wants two formats, run two engines.

---

## Phase 1: Intent Analysis

Before proposing anything, silently analyze the user's request:

1. **Extract** — domain, complexity, audience, output medium
2. **Load** decision tree from `knowledge/decision-tree.md` to narrow options
3. **Check** the user's current context (Obsidian vault? git repo? writing docs?)

Output a brief analysis summary before Phase 2.

---

## Phase 2: Chart Proposal (MANDATORY — DO NOT SKIP)

**Load `knowledge/capability-matrix.md`** to build the proposal.

For each proposed chart type, include:

```
N. [⭐ if best match] Chart Type Name
   → Engine: EngineName + Style/Subtype
   → Output: format(s)
   → Best for: one-line scenario description
```

Present 3-5 options. Ask the user to choose one or more (e.g., "A", "B+D", "A+C").
Do NOT proceed until the user selects.

**Reference examples** in `knowledge/examples.md` if needed.

---

## Phase 3: Interactive Deep Interview

After user selection, ask **4 deep questions** (one at a time), tailored to the
selected chart type(s):

**Deep Questions (adapt per chart type):**

| If architecture/flow/data | If mind map/concept | If data viz |
|---|---|---|
| Q1: Who is the audience? | Q1: What's the central topic? | Q1: What metrics to highlight? |
| Q2: What key components? | Q2: How many levels deep? | Q2: Time range / comparison? |
| Q3: Preferred layout direction? | Q3: Color coding preference? | Q3: Static or interactive? |
| Q4: Level of detail needed? | Q4: Any specific grouping? | Q4: Embed in doc or standalone? |

**Then 4 standard questions:**

1. Output format preference? (list available formats for selected engine)
2. Style preference? (load `knowledge/style-catalog.md` for engine-specific options)
3. Need animation / motion? (if relevant)
4. Any special requirements? (branding, labels, specific icons)

---

## Phase 4: Orchestration

For each chart type the user selected:

1. **Identify the engine** from Phase 2 selection
2. **Load the corresponding adapter**: read `adapters/<engine>-adapter.md`
3. **Follow the adapter's execution instructions** — each adapter documents
   exactly how to load and run its upstream engine
4. **Generate** the diagram following the upstream engine's original workflow
5. **Report** output file paths and usage instructions

### Adapter Loading Table

| Selected Engine | Load This Adapter | Upstream Source |
|---|---|---|
| fireworks | `adapters/fireworks-adapter.md` | `engines/fireworks-tech-graph/SKILL.md` |
| Mermaid | `adapters/mermaid-adapter.md` | `engines/mermaid-visualizer/SKILL.md` |
| Excalidraw | `adapters/excalidraw-adapter.md` | `engines/excalidraw-diagram/SKILL.md` |
| Canvas | `adapters/canvas-adapter.md` | `engines/canvas-creator/SKILL.md` |
| Drawio | `adapters/drawio-adapter.md` | MCP tools (mcp__drawio__*) |
| Dataviz | `adapters/dataviz-adapter.md` | Built-in `dataviz` Skill |

---

## Capability Overview (Quick Reference)

| Need | Best Engine | Output |
|---|---|---|
| Architecture / system design | fireworks | SVG+PNG |
| Flowchart / workflow | Mermaid | .md code block |
| Sequence / API interaction | Mermaid | .md / SVG |
| Mind map / brainstorming | Canvas (MindMap) | .canvas |
| Hand-drawn sketch | Excalidraw | .md (Obsidian) |
| Data dashboard/chart | Dataviz | HTML/SVG/PNG |
| Editable diagram | Drawio | .drawio |
| UML / ER / Class | fireworks | SVG+PNG |
| Event stream / messaging | fireworks Style11 | SVG+PNG |
| SRE / reliability | fireworks Style12 | SVG+PNG |

For the full 17-type matrix, see `knowledge/capability-matrix.md`.
```

- [ ] **Step 2: Commit**

```bash
cd /Users/fengwanchang/Documents/Obsidian/06-AI工具/chart-toolkit
git add chart-toolkit.md
git commit -m "feat(core): add unified chart-toolkit prompt — 4-phase intent routing"
```

---

### Task 6: Adapters — fireworks, mermaid, excalidraw, canvas

**Files:**
- Create: `chart-toolkit/adapters/fireworks-adapter.md`
- Create: `chart-toolkit/adapters/mermaid-adapter.md`
- Create: `chart-toolkit/adapters/excalidraw-adapter.md`
- Create: `chart-toolkit/adapters/canvas-adapter.md`

- [ ] **Step 1: Write fireworks-adapter.md**

```markdown
# Fireworks Tech Graph Adapter

## Engine
`engines/fireworks-tech-graph/SKILL.md` — yizhiyanhua-ai/fireworks-tech-graph (MIT)

## Capabilities
- All technical diagrams: architecture, data flow, flowchart, sequence, UML (14 types), ER, mind map, Gantt
- 12 visual styles (Style1 Flat, Style2 Dark, Style3 Blueprint, Style4 Notion, Style5 Glass, Style6 Claude, Style7 OpenAI, Style8 Dark Luxury, Style9 C4, Style10 Cloud, Style11 Event, Style12 Ops)
- Semantic arrow system (write/read/async/loop via color + dash pattern)
- 40+ product icons (OpenAI, Anthropic, Pinecone, Kafka, PostgreSQL...)

## Output
- `.svg` (editable vector, pure inline, no external fonts)
- `.png` (1920px, via cairosvg or rsvg-convert)
- Offline interactive HTML (zoom, theme toggle, export)

## Prerequisites
- Python 3.9+ with `cairosvg` (`pip install cairosvg`) — recommended
- OR `rsvg-convert` (`brew install librsvg` / `apt install librsvg2-bin`)
- OR `puppeteer` (Node.js 18+) — fallback

## Execution

1. **Load the upstream skill**: Read `engines/fireworks-tech-graph/SKILL.md`
2. **Follow its Workflow**:
   a. Classify diagram type (see Diagram Types section)
   b. Extract structure — layers, nodes, edges, flows
   c. Plan layout — apply layout rules for the type
   d. Load style reference — `engines/fireworks-tech-graph/references/style-N.md`
   e. Map nodes to shapes — use Shape Vocabulary
   f. Check icon needs — `engines/fireworks-tech-graph/references/icons.md`
   g. Write SVG
   h. Validate: `python3 -c "import xml.etree.ElementTree as ET; ET.parse('file.svg')"`
   i. Export PNG: `cairosvg file.svg -o file.png` (or rsvg-convert)
3. **Report** the generated file paths

## Style Quick Reference
| Style | Name | Best For |
|---|---|---|
| 1 | Flat Icon | General architecture (default) |
| 2 | Dark Terminal | AI/Agent workflows, dev tools |
| 3 | Blueprint | Microservices, complex systems |
| 4 | Notion Minimal | Simple overviews |
| 5 | Glass Card | Multi-agent, dashboards |
| 6 | Claude Official | System architecture |
| 7 | OpenAI Official | API flows |
| 8 | Dark Luxury | Premium presentations |
| 9 | C4 Canvas | Architecture review |
| 10 | Cloud Fabric | Multi-region deployment |
| 11 | Event Transit | Event-driven systems |
| 12 | Ops Pulse | SRE, monitoring |

## PNG Export Commands

```bash
# Preferred: cairosvg
python3 -c "import cairosvg; cairosvg.svg2png(url='file.svg', write_to='file.png', output_width=1920)"

# Fallback: rsvg-convert
rsvg-convert -w 1920 -o file.png file.svg
```
```

- [ ] **Step 2: Write mermaid-adapter.md**

```markdown
# Mermaid Visualizer Adapter

## Engine
`engines/mermaid-visualizer/SKILL.md` — axtonliu/axton-obsidian-visual-skills (MIT)

## Capabilities
- Process Flow (graph TB/LR) — workflows, decision trees
- Circular Flow — cyclic processes, feedback loops
- Comparison Diagram — A vs B, before/after
- Mindmap — hierarchical knowledge
- Sequence Diagram — API calls, message flows
- State Diagram — lifecycle, status transitions
- Class Diagram, ER Diagram, Gantt Chart

## Output
- `.md` with ````mermaid` code fence — rendered natively by Obsidian, GitHub, GitLab, Notion
- Configurable: layout, detail level, color scheme

## Prerequisites
- None. Mermaid is rendered by the platform (Obsidian/GitHub), not locally.
- The output `.md` file IS the diagram.

## Execution

1. **Load the upstream skill**: Read `engines/mermaid-visualizer/SKILL.md`
2. **Follow its Workflow**:
   a. Analyze content — identify concepts, relationships, hierarchy
   b. Select diagram type from Mermaid's supported types
   c. Choose configuration — layout direction, detail level, color scheme
   d. Generate Mermaid code — follow Critical Syntax Rules strictly
   e. Quality checklist before output:
      - [ ] No "number. space" patterns in node text (use circled numbers ①②③ or `[Step N:]` prefix)
      - [ ] All subgraphs use `subgraph id["Display Name"]` format
      - [ ] All node references use IDs, not display names
      - [ ] Special chars: `"` → `『』`, `()` → `「」`
      - [ ] No Emoji in node text
      - [ ] Colors from the standard palette
3. **Output** wrapped in ````mermaid` code fence with brief explanation
4. **Report** file path and rendering platforms (Obsidian, GitHub, etc.)

## Critical Syntax Rules (from upstream)

1. Node text: NO `1. ` patterns → use `[1.Perception]` or `[① Perception]`
2. Subgraph: ALWAYS `subgraph id["Label"]` NOT `subgraph Label`
3. Arrows: `-->` solid, `-.->` dashed, `==>` thick, `~~~` invisible
4. Quotes for text with spaces: `["text with spaces"]`
```

- [ ] **Step 3: Write excalidraw-adapter.md**

```markdown
# Excalidraw Diagram Adapter

## Engine
`engines/excalidraw-diagram/SKILL.md` — axtonliu/axton-obsidian-visual-skills (MIT)

## Capabilities
- Hand-drawn style diagrams (fontFamily: 5 = Excalifont)
- 8 diagram types: Flowchart, Mind Map, Hierarchy, Relationship, Comparison, Timeline, Matrix, Freeform
- Three output modes: Obsidian (.md), Standard (.excalidraw), Animated (.excalidraw + animation order)

## Output
| Mode | File | Use |
|---|---|---|
| Obsidian (default) | `.md` | Open in Obsidian with Excalidraw plugin |
| Standard | `.excalidraw` | Open/edit/share on excalidraw.com |
| Animated | `.excalidraw` | Load in excalidraw-animate for GIF/WebM |

## Prerequisites
- None for generation
- To view: Obsidian + Excalidraw plugin (for .md), or excalidraw.com (for .excalidraw)

## Execution

1. **Load the upstream skill**: Read `engines/excalidraw-diagram/SKILL.md`
2. **Determine output mode** from user context:
   - Default = Obsidian mode (.md) unless user explicitly requests Standard or Animated
3. **Analyze content** — identify concepts, relationships, hierarchy
4. **Choose diagram type** from 8 supported types
5. **Generate Excalidraw JSON** following upstream schema:
   - All text elements: `fontFamily: 5` (Excalifont)
   - Text escaping: `"` → `『』`, `()` → `「」`
   - Valid JSON, unique element IDs, `appState` + `files: {}` included
   - If Animated: add animation order to elements
6. **Output** in the correct format
7. **Report** file path + viewing instructions

## Mode-Specific Output Format

### Obsidian Mode (default)
Frontmatter: `excalidraw-plugin: parsed`, `tags: [excalidraw]`
Warning text: `==⚠ Switch to EXCALIDRAW VIEW...`
JSON inside `%%` markers, `.md` extension

### Standard Mode
Pure JSON file, `"type": "excalidraw"`, `"version": 2`
`.excalidraw` extension

### Animated Mode
Same as Standard + `animationOrder` on elements
`.excalidraw` extension
```

- [ ] **Step 4: Write canvas-adapter.md**

```markdown
# Obsidian Canvas Creator Adapter

## Engine
`engines/canvas-creator/SKILL.md` — axtonliu/axton-obsidian-visual-skills (MIT)

## Capabilities
- MindMap layout — radial hierarchy from center
- Freeform layout — custom positioning, flexible connections
- Smart node sizing, auto edge creation, color-coded nodes (6 presets + custom hex)

## Output
- `.canvas` file — valid JSON Canvas format, directly openable in Obsidian

## Prerequisites
- None. The .canvas file opens natively in Obsidian (no plugin needed).

## Execution

1. **Load the upstream skill**: Read `engines/canvas-creator/SKILL.md`
2. **Determine layout type** — MindMap (hierarchical) or Freeform (flexible)
3. **Analyze content**:
   - For MindMap: identify central concept → primary branches → secondary branches → leaf nodes
   - For Freeform: group related concepts → identify connection patterns → plan spatial zones
4. **Generate Canvas JSON** following upstream rules:
   - Unique 8-12 char hex IDs for all nodes and edges
   - Node sizing based on content length (short=220×100, medium=260×120, long=320×140)
   - Minimum spacing: 320px horizontal, 200px vertical between node centers
   - MindMap: root at (0,0), primary nodes radial, secondary nodes offset 30-45°
   - Color presets: "1"=Red, "2"=Orange, "3"=Yellow, "4"=Green, "5"=Cyan, "6"=Purple
   - Text escaping: `"` → `『』`, `'` → `「」`
   - No Emoji in node text
5. **Validate**: all IDs unique, no coordinate overlaps, edges reference valid node IDs
6. **Output** complete JSON Canvas file (no extra explanation text)
7. **Report** file path: "Open this file in Obsidian to see the interactive canvas"
```

- [ ] **Step 5: Commit**

```bash
cd /Users/fengwanchang/Documents/Obsidian/06-AI工具/chart-toolkit
git add adapters/fireworks-adapter.md adapters/mermaid-adapter.md adapters/excalidraw-adapter.md adapters/canvas-adapter.md
git commit -m "feat(adapters): add fireworks, mermaid, excalidraw, canvas adapters"
```

---

### Task 7: Adapters — drawio, dataviz

**Files:**
- Create: `chart-toolkit/adapters/drawio-adapter.md`
- Create: `chart-toolkit/adapters/dataviz-adapter.md`

- [ ] **Step 1: Write drawio-adapter.md**

```markdown
# Drawio MCP Adapter

## Engine
`@next-ai-drawio/mcp-server` (npm) — DayuanJiang/next-ai-draw-io (Apache-2.0, 33.7k stars)

## Capabilities
- Full draw.io diagram creation and editing via natural language
- Real-time browser preview
- Multi-page support (tabs)
- Export: .drawio, .png, .svg
- Version history with visual thumbnails

## Output
| Format | Use |
|---|---|
| `.drawio` | Editable, shareable, can re-open in draw.io |
| `.png` | Embed in docs, slides |
| `.svg` | Vector embedding |

## Prerequisites
- Drawio MCP Server configured in MCP config file (claude mcp add or manual JSON)
- Node.js 18+ (for npx)
- Browser for real-time preview

## Available Tools (MCP)

| Tool | Purpose |
|---|---|
| `start_session` | Open browser with live preview |
| `create_new_diagram` | Create from XML |
| `edit_diagram` | Add/update/delete cells by ID |
| `get_diagram` | Read current XML |
| `export_diagram` | Save .drawio/.png/.svg |
| `list_pages` | List all tabs |
| `add_page` | Add new tab |
| `rename_page` | Rename tab |
| `delete_page` | Delete tab |
| `load_diagram` | Open .drawio from disk |

## Execution

1. **Check MCP availability**: If `mcp__drawio__*` tools are not available, inform user to run setup
2. **If first call in session**: use `start_session` to open browser preview
3. **Create diagram**: 
   - For new: `create_new_diagram` with generated XML
   - For editing existing: `load_diagram` then `edit_diagram`
4. **Iterate**: Use `edit_diagram` for modifications (natural language → XML operations)
5. **Export**: `export_diagram` to save as .drawio, .png, or .svg
6. **Report**: file path + note that browser preview is live

## XML Generation Notes

- Cell IDs must start from "2" (0 and 1 are reserved root sentinels)
- All shapes need `parent="1"` (top-level) or parent cell ID
- ViewBox constraint: keep elements within 0-800 x 0-600
- Space shapes 150-200px apart for readability

## Fallback

If Drawio MCP is unavailable:
- Offer Fireworks Tech Graph as an alternative for static diagrams
- Offer Excalidraw for hand-drawn style editable diagrams
```

- [ ] **Step 2: Write dataviz-adapter.md**

```markdown
# Dataviz Adapter

## Engine
Built-in Claude Code `dataviz` Skill — no upstream repo to clone.

## Capabilities
- Data visualization design system methodology
- Charts: bar, line, scatter, pie, heatmap, area, radar
- Dashboards: KPI cards, stat tiles, sparklines
- Interactive HTML, React components, inline SVG, PNG
- Dark/light mode compatible
- Library support: Plotly, D3, Recharts, Matplotlib

## Output
- HTML/React artifacts — interactive dashboards
- Inline SVG — for embedding
- PNG — via rendering
- Plotting code — matplotlib, plotly, d3, recharts

## Prerequisites
- None (methodology-based, not tool-dependent)
- If generating code: Python/Node.js per chosen library

## Execution

1. **Invoke the `dataviz` Skill** (built-in, no file to load)
2. **Apply its methodology**:
   - Form heuristic: automatically select chart type from data shape
   - Color formula: use the validated palette from `references/palette.md`
   - Mark specs: consistent legend, axis, tooltip rules
   - Dark mode: test readability in both themes
3. **Choose output medium** based on user's context:
   - For dashboards: interactive HTML
   - For embedding: inline SVG
   - For presentations: high-res PNG
   - For developers: code (matplotlib/plotly/d3/recharts)
4. **Generate** following the dataviz design system
5. **Report** output with viewing instructions

## When to Use This Adapter
- User mentions: chart, graph, plot, dashboard, analytics, KPI, metrics, statistics
- User has numerical data to visualize
- NOT for: architecture diagrams, flowcharts, mind maps (route to other adapters)
```

- [ ] **Step 3: Commit**

```bash
cd /Users/fengwanchang/Documents/Obsidian/06-AI工具/chart-toolkit
git add adapters/drawio-adapter.md adapters/dataviz-adapter.md
git commit -m "feat(adapters): add drawio and dataviz adapters"
```

---

### Task 8: Setup Scripts — setup.sh, setup.ps1, setup.bat

**Files:**
- Create: `chart-toolkit/setup.sh`
- Create: `chart-toolkit/setup.ps1`
- Create: `chart-toolkit/setup.bat`

- [ ] **Step 1: Write setup.sh (macOS/Linux)**

```bash
#!/usr/bin/env bash
set -euo pipefail

# ─── Chart Toolkit Setup ───
# One-command installer for macOS and Linux.
# Usage: ./setup.sh   or   curl -fsSL <url> | bash

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'
TOOLKIT_DIR="$(cd "$(dirname "$0")" && pwd)"
FIRECRACKER_TAG="${FIRECRACKER_TAG:-v1.0.4}"
AXTON_TAG="${AXTON_TAG:-main}"

log()  { printf "${GREEN}✔${NC} %s\n" "$1"; }
warn() { printf "${YELLOW}⚠${NC} %s\n" "$1"; }
err()  { printf "${RED}✖${NC} %s\n" "$1"; exit 1; }
info() { printf "${CYAN}ℹ${NC} %s\n" "$1"; }

header() {
  echo ""
  printf "${CYAN}╔══════════════════════════════════════╗${NC}\n"
  printf "${CYAN}║      Chart Toolkit Setup             ║${NC}\n"
  printf "${CYAN}╚══════════════════════════════════════╝${NC}\n"
  echo ""
}

header

# ─── Step 1: Detect Platform ───
info "Step 1/8: Detecting platform..."
case "$(uname -s)" in
  Darwin)  PLATFORM="macos" ;;
  Linux)   PLATFORM="linux" ;;
  *)       err "Unsupported platform: $(uname -s)" ;;
esac
log "Platform: $PLATFORM"

# ─── Step 2: Check Prerequisites ───
info "Step 2/8: Checking prerequisites..."
for cmd in git python3 node; do
  if command -v "$cmd" &>/dev/null; then
    log "$cmd found: $(command -v $cmd)"
  else
    warn "$cmd not found — will attempt to install"
  fi
done

# ─── Step 3: Install System Dependencies ───
info "Step 3/8: Installing system dependencies..."
if [ "$PLATFORM" = "macos" ]; then
  if ! command -v brew &>/dev/null; then
    warn "Homebrew not found. Install from https://brew.sh"
  else
    command -v git &>/dev/null || brew install git
    command -v node &>/dev/null || brew install node
  fi
  # cairosvg
  if ! python3 -c "import cairosvg" 2>/dev/null; then
    info "Installing cairosvg..."
    pip3 install cairosvg || warn "cairosvg install failed; rsvg-convert will be used as fallback"
  else
    log "cairosvg already installed"
  fi
  # rsvg-convert (fallback)
  if ! command -v rsvg-convert &>/dev/null; then
    info "Installing librsvg (rsvg-convert)..."
    brew install librsvg || warn "librsvg install failed"
  else
    log "rsvg-convert already installed"
  fi
elif [ "$PLATFORM" = "linux" ]; then
  if command -v apt-get &>/dev/null; then
    sudo apt-get update -qq
    command -v git &>/dev/null || sudo apt-get install -y git
    command -v node &>/dev/null || sudo apt-get install -y nodejs npm
    command -v rsvg-convert &>/dev/null || sudo apt-get install -y librsvg2-bin
    python3 -c "import cairosvg" 2>/dev/null || pip3 install cairosvg
  elif command -v yum &>/dev/null; then
    sudo yum install -y git nodejs librsvg2-tools
    python3 -c "import cairosvg" 2>/dev/null || pip3 install cairosvg
  else
    warn "No supported package manager found. Install git, node, python3, and cairosvg manually."
  fi
fi
log "Dependencies installed"

# ─── Step 4: Clone Engines ───
info "Step 4/8: Cloning upstream engines..."
ENGINES_DIR="$TOOLKIT_DIR/engines"
mkdir -p "$ENGINES_DIR"

# Fireworks Tech Graph
if [ ! -d "$ENGINES_DIR/fireworks-tech-graph" ]; then
  info "Cloning fireworks-tech-graph@$FIRECRACKER_TAG..."
  git clone --depth 1 -b "$FIRECRACKER_TAG" \
    https://github.com/yizhiyanhua-ai/fireworks-tech-graph.git \
    "$ENGINES_DIR/fireworks-tech-graph" 2>/dev/null || \
    git clone --depth 1 \
    https://github.com/yizhiyanhua-ai/fireworks-tech-graph.git \
    "$ENGINES_DIR/fireworks-tech-graph"
  log "fireworks-tech-graph cloned"
else
  log "fireworks-tech-graph already exists (skipping)"
fi

# Axton Obsidian Visual Skills (extract subdirectories)
if [ ! -d "$ENGINES_DIR/mermaid-visualizer" ]; then
  info "Cloning axton-obsidian-visual-skills@$AXTON_TAG..."
  TMP_AXTON=$(mktemp -d)
  git clone --depth 1 -b "$AXTON_TAG" \
    https://github.com/axtonliu/axton-obsidian-visual-skills.git \
    "$TMP_AXTON" 2>/dev/null
  cp -r "$TMP_AXTON/mermaid-visualizer" "$ENGINES_DIR/"
  cp -r "$TMP_AXTON/excalidraw-diagram" "$ENGINES_DIR/"
  cp -r "$TMP_AXTON/obsidian-canvas-creator" "$ENGINES_DIR/canvas-creator"
  rm -rf "$TMP_AXTON"
  log "mermaid-visualizer, excalidraw-diagram, canvas-creator cloned"
else
  log "axton engines already exist (skipping)"
fi

# ─── Step 5: Link to Agents ───
info "Step 5/8: Linking to detected Agents..."
if [ -f "$TOOLKIT_DIR/agents/install-all.sh" ]; then
  bash "$TOOLKIT_DIR/agents/install-all.sh"
else
  warn "agents/install-all.sh not found"
fi

# ─── Step 6: Merge MCP Configuration ───
info "Step 6/8: Checking Drawio MCP configuration..."
if [ -f "$TOOLKIT_DIR/scripts/merge-mcp.sh" ]; then
  bash "$TOOLKIT_DIR/scripts/merge-mcp.sh"
else
  warn "scripts/merge-mcp.sh not found — run 'claude mcp add drawio -- npx @next-ai-drawio/mcp-server@latest' manually"
fi

# ─── Step 7: Verify ───
info "Step 7/8: Running doctor check..."
if [ -f "$TOOLKIT_DIR/scripts/doctor.sh" ]; then
  bash "$TOOLKIT_DIR/scripts/doctor.sh"
else
  warn "scripts/doctor.sh not found"
fi

# ─── Step 8: Report ───
echo ""
printf "${GREEN}╔══════════════════════════════════════╗${NC}\n"
printf "${GREEN}║   Chart Toolkit Setup Complete!      ║${NC}\n"
printf "${GREEN}╚══════════════════════════════════════╝${NC}\n"
echo ""
echo "What's next:"
echo "  1. Restart your Agent (Claude Code / Codex)"
echo "  2. Say: '画一个系统架构图' or 'Create a flowchart'"
echo "  3. The toolkit will guide you interactively"
echo ""
echo "Toolkit location: $TOOLKIT_DIR"
echo "Installed engines:"
for engine in "$ENGINES_DIR"/*/; do
  [ -d "$engine" ] && echo "  - $(basename "$engine")"
done
echo ""
echo "To update engines later: ./setup.sh"
echo ""
```

- [ ] **Step 2: Write setup.ps1 (Windows PowerShell)**

```powershell
# Chart Toolkit Setup — Windows PowerShell
# Usage: .\setup.ps1   or   iwr -useb <url> | iex

$ErrorActionPreference = "Stop"
$TOOLKIT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$FIRECRACKER_TAG = if ($env:FIRECRACKER_TAG) { $env:FIRECRACKER_TAG } else { "v1.0.4" }
$AXTON_TAG = if ($env:AXTON_TAG) { $env:AXTON_TAG } else { "main" }

Write-Host ""
Write-Host "╔══════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║      Chart Toolkit Setup (Windows)    ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Step 1: Check Prerequisites
Write-Host "Step 1/7: Checking prerequisites..." -ForegroundColor Cyan
$missing = @()
@("git", "python", "node") | ForEach-Object {
    if (Get-Command $_ -ErrorAction SilentlyContinue) {
        Write-Host "✔ $_ found" -ForegroundColor Green
    } else {
        Write-Host "⚠ $_ not found" -ForegroundColor Yellow
        $missing += $_
    }
}
if ($missing.Count -gt 0) {
    Write-Host "Missing: $($missing -join ', '). Please install manually." -ForegroundColor Red
    Write-Host "  git: https://git-scm.com/download/win"
    Write-Host "  python: https://www.python.org/downloads/"
    Write-Host "  node: https://nodejs.org/"
}

# Step 2: Install Python deps
Write-Host "Step 2/7: Installing Python dependencies..." -ForegroundColor Cyan
try {
    pip install cairosvg
    Write-Host "✔ cairosvg installed" -ForegroundColor Green
} catch {
    Write-Host "⚠ cairosvg install failed" -ForegroundColor Yellow
}

# Step 3: Clone Engines
Write-Host "Step 3/7: Cloning upstream engines..." -ForegroundColor Cyan
$ENGINES_DIR = Join-Path $TOOLKIT_DIR "engines"
New-Item -ItemType Directory -Force -Path $ENGINES_DIR | Out-Null

if (-not (Test-Path "$ENGINES_DIR/fireworks-tech-graph")) {
    git clone --depth 1 -b $FIRECRACKER_TAG https://github.com/yizhiyanhua-ai/fireworks-tech-graph.git "$ENGINES_DIR/fireworks-tech-graph"
    Write-Host "✔ fireworks-tech-graph cloned" -ForegroundColor Green
}

if (-not (Test-Path "$ENGINES_DIR/mermaid-visualizer")) {
    $TMP = Join-Path $env:TEMP "axton-$([Guid]::NewGuid())"
    git clone --depth 1 -b $AXTON_TAG https://github.com/axtonliu/axton-obsidian-visual-skills.git $TMP
    Copy-Item -Recurse "$TMP/mermaid-visualizer" "$ENGINES_DIR/"
    Copy-Item -Recurse "$TMP/excalidraw-diagram" "$ENGINES_DIR/"
    Copy-Item -Recurse "$TMP/obsidian-canvas-creator" "$ENGINES_DIR/canvas-creator"
    Remove-Item -Recurse -Force $TMP
    Write-Host "✔ axton engines cloned" -ForegroundColor Green
}

# Step 4: Link Agents
Write-Host "Step 4/7: Linking to detected Agents..." -ForegroundColor Cyan
$SKILLS_DIR = "$TOOLKIT_DIR"
if (Test-Path "$env:USERPROFILE/.claude/skills") {
    $target = "$env:USERPROFILE/.claude/skills/chart-toolkit"
    if (-not (Test-Path $target)) {
        New-Item -ItemType Junction -Path $target -Target $SKILLS_DIR -ErrorAction SilentlyContinue
        if (-not (Test-Path $target)) {
            Copy-Item -Recurse $SKILLS_DIR $target
        }
        Write-Host "✔ Linked to Claude Code" -ForegroundColor Green
    } else {
        Write-Host "✔ Claude Code link exists" -ForegroundColor Green
    }
}
if (Test-Path "$env:USERPROFILE/.agents/skills") {
    $target = "$env:USERPROFILE/.agents/skills/chart-toolkit"
    if (-not (Test-Path $target)) {
        New-Item -ItemType Junction -Path $target -Target $SKILLS_DIR -ErrorAction SilentlyContinue
        if (-not (Test-Path $target)) {
            Copy-Item -Recurse $SKILLS_DIR $target
        }
        Write-Host "✔ Linked to Codex" -ForegroundColor Green
    }
}

# Step 5: Drawio MCP
Write-Host "Step 5/7: Drawio MCP setup..." -ForegroundColor Cyan
Write-Host "ℹ To enable Drawio, run in terminal: claude mcp add drawio -- npx @next-ai-drawio/mcp-server@latest"

# Step 6: Doctor
Write-Host "Step 6/7: Running doctor check..." -ForegroundColor Cyan
$DOCTOR = Join-Path $TOOLKIT_DIR "scripts/doctor.ps1"
if (Test-Path $DOCTOR) {
    & $DOCTOR
}

# Step 7: Report
Write-Host ""
Write-Host "╔══════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║   Chart Toolkit Setup Complete!      ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "Toolkit location: $TOOLKIT_DIR"
Write-Host "Next: Restart your Agent and say 'Create a flowchart' or '画一个架构图'"
```

- [ ] **Step 3: Write setup.bat (Windows CMD fallback)**

```batch
@echo off
echo.
echo ========================================
echo   Chart Toolkit Setup (Windows CMD)
echo ========================================
echo.
echo This is a stub launcher. For full setup, use PowerShell:
echo   powershell -ExecutionPolicy Bypass -File setup.ps1
echo.
echo Or use Git Bash / WSL and run:
echo   bash setup.sh
echo.
pause
```

- [ ] **Step 4: Make setup.sh executable**

```bash
chmod +x /Users/fengwanchang/Documents/Obsidian/06-AI工具/chart-toolkit/setup.sh
```

- [ ] **Step 5: Commit**

```bash
cd /Users/fengwanchang/Documents/Obsidian/06-AI工具/chart-toolkit
git add setup.sh setup.ps1 setup.bat
git commit -m "feat(setup): add cross-platform install scripts (sh/ps1/bat)"
```

---

### Task 9: Agent Integration Scripts

**Files:**
- Create: `chart-toolkit/agents/install-claude.sh`
- Create: `chart-toolkit/agents/install-codex.sh`
- Create: `chart-toolkit/agents/install-all.sh`

- [ ] **Step 1: Write install-claude.sh**

```bash
#!/usr/bin/env bash
# Install chart-toolkit for Claude Code
# Creates a symlink from ~/.claude/skills/chart-toolkit → toolkit directory
set -euo pipefail

TOOLKIT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
CLAUDE_SKILLS="$HOME/.claude/skills"
TARGET="$CLAUDE_SKILLS/chart-toolkit"

mkdir -p "$CLAUDE_SKILLS"

if [ -L "$TARGET" ] || [ -d "$TARGET" ]; then
  echo "✔ Claude Code: chart-toolkit already linked at $TARGET"
else
  ln -s "$TOOLKIT_DIR" "$TARGET"
  echo "✔ Claude Code: linked $TARGET → $TOOLKIT_DIR"
fi

echo "Usage in Claude Code: just say '画一个架构图' or 'create a flowchart'"
```

- [ ] **Step 2: Write install-codex.sh**

```bash
#!/usr/bin/env bash
# Install chart-toolkit for OpenAI Codex CLI
# Creates a symlink from ~/.agents/skills/chart-toolkit → toolkit directory
set -euo pipefail

TOOLKIT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
CODEX_SKILLS="$HOME/.agents/skills"
TARGET="$CODEX_SKILLS/chart-toolkit"

mkdir -p "$CODEX_SKILLS"

if [ -L "$TARGET" ] || [ -d "$TARGET" ]; then
  echo "✔ Codex: chart-toolkit already linked at $TARGET"
else
  ln -s "$TOOLKIT_DIR" "$TARGET"
  echo "✔ Codex: linked $TARGET → $TOOLKIT_DIR"
fi

echo "Usage in Codex: say 'draw an architecture diagram' or '画一个架构图'"
```

- [ ] **Step 3: Write install-all.sh**

```bash
#!/usr/bin/env bash
# Detect all installed Agents and install chart-toolkit for each
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
INSTALLED=0

echo "Detecting installed Agents..."

# Claude Code
if [ -d "$HOME/.claude" ]; then
  echo "  → Claude Code detected"
  bash "$SCRIPT_DIR/install-claude.sh"
  INSTALLED=$((INSTALLED + 1))
fi

# Codex
if [ -d "$HOME/.agents" ]; then
  echo "  → Codex detected"
  bash "$SCRIPT_DIR/install-codex.sh"
  INSTALLED=$((INSTALLED + 1))
fi

# Hermes (v1.1 pending)
if [ -d "$HOME/.hermes" ]; then
  echo "  → Hermes detected (integration coming in v1.1)"
fi

# Claw (v1.1 pending)
if [ -d "$HOME/.claw" ]; then
  echo "  → Claw detected (integration coming in v1.1)"
fi

# QCoder (v1.1 pending)
if [ -d "$HOME/.qcoder" ]; then
  echo "  → QCoder detected (integration coming in v1.1)"
fi

if [ $INSTALLED -eq 0 ]; then
  echo ""
  echo "⚠ No supported Agent detected."
  echo "Manual install: symlink or copy chart-toolkit/ to your Agent's skills directory."
  echo "Or use: @path/to/chart-toolkit/chart-toolkit.md in your Agent."
else
  echo ""
  echo "✔ Installed for $INSTALLED Agent(s). Restart your Agent to load chart-toolkit."
fi
```

- [ ] **Step 4: Make scripts executable**

```bash
chmod +x /Users/fengwanchang/Documents/Obsidian/06-AI工具/chart-toolkit/agents/install-claude.sh
chmod +x /Users/fengwanchang/Documents/Obsidian/06-AI工具/chart-toolkit/agents/install-codex.sh
chmod +x /Users/fengwanchang/Documents/Obsidian/06-AI工具/chart-toolkit/agents/install-all.sh
```

- [ ] **Step 5: Commit**

```bash
cd /Users/fengwanchang/Documents/Obsidian/06-AI工具/chart-toolkit
git add agents/
git commit -m "feat(agents): add Claude Code and Codex integration scripts"
```

---

### Task 10: Helper Scripts — doctor.sh, deps scripts

**Files:**
- Create: `chart-toolkit/scripts/doctor.sh`
- Create: `chart-toolkit/scripts/doctor.ps1`
- Create: `chart-toolkit/scripts/deps-macos.sh`
- Create: `chart-toolkit/scripts/deps-linux.sh`
- Create: `chart-toolkit/scripts/deps-windows.ps1`

- [ ] **Step 1: Write doctor.sh**

```bash
#!/usr/bin/env bash
# Doctor — check all dependencies and report status
set -euo pipefail

GREEN='\033[0;32m'; RED='\033[0;31m'; YELLOW='\033[1;33m'; NC='\033[0m'
PASS=0; FAIL=0; WARN=0

check_cmd() {
  if command -v "$1" &>/dev/null; then
    printf "${GREEN}✔${NC} %-25s %s\n" "$1" "$(command -v "$1")"
    PASS=$((PASS + 1))
  else
    printf "${RED}✖${NC} %-25s not found\n" "$1"
    FAIL=$((FAIL + 1))
  fi
}

check_python_mod() {
  if python3 -c "import $1" 2>/dev/null; then
    printf "${GREEN}✔${NC} %-25s installed\n" "python:$1"
    PASS=$((PASS + 1))
  else
    printf "${YELLOW}⚠${NC} %-25s not installed (pip install $1)\n" "python:$1"
    WARN=$((WARN + 1))
  fi
}

check_dir() {
  if [ -d "$1" ]; then
    printf "${GREEN}✔${NC} %-25s exists\n" "$(basename "$1")"
    PASS=$((PASS + 1))
  else
    printf "${YELLOW}⚠${NC} %-25s missing (run setup.sh)\n" "$(basename "$1")"
    WARN=$((WARN + 1))
  fi
}

echo ""
echo "Chart Toolkit Doctor"
echo "===================="
echo ""
echo "—— System ——"
check_cmd git
check_cmd python3
check_cmd node
check_cmd npx

echo ""
echo "—— Python ——"
check_python_mod cairosvg

echo ""
echo "—— SVG → PNG ——"
if command -v cairosvg &>/dev/null || python3 -c "import cairosvg" 2>/dev/null; then
  printf "${GREEN}✔${NC} %-25s available\n" "cairosvg (preferred)"
elif command -v rsvg-convert &>/dev/null; then
  printf "${GREEN}✔${NC} %-25s %s\n" "rsvg-convert" "$(command -v rsvg-convert)"
else
  printf "${YELLOW}⚠${NC} %-25s neither cairosvg nor rsvg-convert found\n" "SVG→PNG"
  WARN=$((WARN + 1))
fi

echo ""
echo "—— Engines ——"
TOOLKIT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
check_dir "$TOOLKIT_DIR/engines/fireworks-tech-graph"
check_dir "$TOOLKIT_DIR/engines/mermaid-visualizer"
check_dir "$TOOLKIT_DIR/engines/excalidraw-diagram"
check_dir "$TOOLKIT_DIR/engines/canvas-creator"

echo ""
echo "—— Agent Links ——"
[ -L "$HOME/.claude/skills/chart-toolkit" ] && printf "${GREEN}✔${NC} %-25s linked\n" "Claude Code" && PASS=$((PASS + 1)) || printf "${YELLOW}⚠${NC} %-25s not linked\n" "Claude Code"
[ -L "$HOME/.agents/skills/chart-toolkit" ] && printf "${GREEN}✔${NC} %-25s linked\n" "Codex" && PASS=$((PASS + 1)) || printf "${YELLOW}⚠${NC} %-25s not linked\n" "Codex"

echo ""
echo "—— MCP (Drawio) ——"
# Check common MCP config locations
MCP_FOUND=0
for f in "$HOME/.claude/mcp.json" "$HOME/.claude/.mcp.json" "$HOME/.cursor/mcp.json"; do
  if [ -f "$f" ] && grep -q "drawio\|@next-ai-drawio" "$f" 2>/dev/null; then
    printf "${GREEN}✔${NC} %-25s configured in %s\n" "Drawio MCP" "$f"
    MCP_FOUND=1
    break
  fi
done
[ $MCP_FOUND -eq 0 ] && printf "${YELLOW}⚠${NC} %-25s not configured (run: claude mcp add drawio -- npx @next-ai-drawio/mcp-server@latest)\n" "Drawio MCP"

echo ""
echo "─────────────────────────"
printf "Results: ${GREEN}%d pass${NC}, ${YELLOW}%d warn${NC}, ${RED}%d fail${NC}\n" $PASS $WARN $FAIL
echo ""
```

- [ ] **Step 2: Write doctor.ps1**

```powershell
# Chart Toolkit Doctor — Windows PowerShell
Write-Host ""
Write-Host "Chart Toolkit Doctor (Windows)" -ForegroundColor Cyan
Write-Host "==============================" -ForegroundColor Cyan
Write-Host ""

$TOOLKIT_DIR = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)

Write-Host "—— System ——" -ForegroundColor Yellow
@("git", "python", "node", "npx") | ForEach-Object {
    if (Get-Command $_ -ErrorAction SilentlyContinue) {
        Write-Host "✔ $_" -ForegroundColor Green
    } else {
        Write-Host "✖ $_ not found" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "—— Python ——" -ForegroundColor Yellow
try { python -c "import cairosvg"; Write-Host "✔ cairosvg" -ForegroundColor Green }
catch { Write-Host "⚠ cairosvg not installed (pip install cairosvg)" -ForegroundColor Yellow }

Write-Host ""
Write-Host "—— Engines ——" -ForegroundColor Yellow
@("fireworks-tech-graph", "mermaid-visualizer", "excalidraw-diagram", "canvas-creator") | ForEach-Object {
    if (Test-Path "$TOOLKIT_DIR/engines/$_") {
        Write-Host "✔ $_" -ForegroundColor Green
    } else {
        Write-Host "⚠ $_ missing (run setup.ps1)" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "—— MCP (Drawio) ——" -ForegroundColor Yellow
Write-Host "ℹ To check manually: claude mcp list"
```

- [ ] **Step 3: Write deps-macos.sh**

```bash
#!/usr/bin/env bash
# Install all dependencies on macOS
set -euo pipefail

echo "Installing Chart Toolkit dependencies for macOS..."
echo ""

# Homebrew
if ! command -v brew &>/dev/null; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# System packages
brew install git node librsvg 2>/dev/null || true

# Python packages
pip3 install --upgrade pip
pip3 install cairosvg

echo ""
echo "✔ macOS dependencies ready."
```

- [ ] **Step 4: Write deps-linux.sh**

```bash
#!/usr/bin/env bash
# Install all dependencies on Linux (apt-based)
set -euo pipefail

echo "Installing Chart Toolkit dependencies for Linux (apt)..."
echo ""

sudo apt-get update -qq
sudo apt-get install -y git python3 python3-pip nodejs npm librsvg2-bin

pip3 install --upgrade pip
pip3 install cairosvg

echo ""
echo "✔ Linux dependencies ready."
```

- [ ] **Step 5: Write deps-windows.ps1**

```powershell
# Install all dependencies on Windows
Write-Host "Installing Chart Toolkit dependencies for Windows..." -ForegroundColor Cyan
Write-Host ""

Write-Host "Please ensure these are installed manually if missing:" -ForegroundColor Yellow
Write-Host "  Git:        https://git-scm.com/download/win"
Write-Host "  Python 3:   https://www.python.org/downloads/"
Write-Host "  Node.js:    https://nodejs.org/"
Write-Host ""

pip install --upgrade pip
pip install cairosvg

Write-Host "✔ Python dependencies installed." -ForegroundColor Green
Write-Host "ℹ rsvg-convert is not available on native Windows. Use cairosvg (just installed) for SVG→PNG conversion." -ForegroundColor Cyan
```

- [ ] **Step 6: Make scripts executable and commit**

```bash
chmod +x /Users/fengwanchang/Documents/Obsidian/06-AI工具/chart-toolkit/scripts/*.sh
cd /Users/fengwanchang/Documents/Obsidian/06-AI工具/chart-toolkit
git add scripts/
git commit -m "feat(scripts): add doctor and deps helpers for all platforms"
```

---

### Task 11: MCP Merge Script

**Files:**
- Create: `chart-toolkit/scripts/merge-mcp.sh`

- [ ] **Step 1: Write merge-mcp.sh**

```bash
#!/usr/bin/env bash
# Merge Drawio MCP configuration into Claude Code / Codex MCP config
set -euo pipefail

DRAWIO_CONFIG='"drawio":{"command":"npx","args":["@next-ai-drawio/mcp-server@latest"]}'

merge_into() {
  local config_file="$1"
  local agent_name="$2"

  if [ ! -f "$config_file" ]; then
    echo "ℹ $agent_name: no mcp.json found at $config_file — creating..."
    mkdir -p "$(dirname "$config_file")"
    cat > "$config_file" <<EOF
{
  "mcpServers": {
    $DRAWIO_CONFIG
  }
}
EOF
    echo "✔ $agent_name: Drawio MCP configured"
    return
  fi

  if grep -q '"drawio"' "$config_file" 2>/dev/null; then
    echo "✔ $agent_name: Drawio MCP already configured"
    return
  fi

  # Simple merge: insert before the closing } of mcpServers
  # More robust merging left as future improvement
  echo "⚠ $agent_name: Drawio MCP not found in config."
  echo "  Add manually to $config_file:"
  echo ""
  echo "  \"mcpServers\": {"
  echo "    $DRAWIO_CONFIG"
  echo "  }"
  echo ""
}

echo "Checking Drawio MCP configuration..."
echo ""

merge_into "$HOME/.claude/mcp.json" "Claude Code"
merge_into "$HOME/.agents/mcp.json" "Codex"
# Hermes/Claw/QCoder paths to be added in v1.1

echo ""
echo "ℹ If Drawio MCP was not auto-configured, run manually:"
echo "  claude mcp add drawio -- npx @next-ai-drawio/mcp-server@latest"
```

- [ ] **Step 2: Commit**

```bash
chmod +x /Users/fengwanchang/Documents/Obsidian/06-AI工具/chart-toolkit/scripts/merge-mcp.sh
cd /Users/fengwanchang/Documents/Obsidian/06-AI工具/chart-toolkit
git add scripts/merge-mcp.sh
git commit -m "feat(scripts): add MCP config merge helper for Drawio"
```

---

### Task 12: Documentation

**Files:**
- Create: `chart-toolkit/docs/README.md`
- Create: `chart-toolkit/docs/README.zh.md`
- Create: `chart-toolkit/docs/install.md`
- Create: `chart-toolkit/docs/usage.md`

- [ ] **Step 1: Write docs/README.md**

```markdown
# Chart Toolkit

> One prompt. Six engines. Any diagram.

Chart Toolkit is a cross-Agent, cross-platform Skill that turns natural language into polished diagrams. Describe what you need — the toolkit analyzes your intent, proposes the best chart types, asks a few clarifying questions, and produces the diagram from the optimal backend engine.

## Supported Engines

| Engine | Best For | Output |
|---|---|---|
| **Fireworks Tech Graph** | Architecture, UML, ER, data flow | SVG + PNG (1920px) |
| **Mermaid** | Flowcharts, sequences, Gantt | .md (GitHub/Obsidian native) |
| **Excalidraw** | Hand-drawn sketches | .md / .excalidraw |
| **Obsidian Canvas** | Mind maps, concept maps | .canvas |
| **Drawio** | Editable diagrams, collaboration | .drawio / .png / .svg |
| **Dataviz** | Dashboards, charts, KPIs | HTML / SVG / PNG |

## Supported Agents

- Claude Code (verified)
- OpenAI Codex CLI (verified)
- Any Agent that supports Markdown Skill files (manual install)

## Quick Install

```bash
# Clone and install
git clone https://github.com/<org>/chart-toolkit.git
cd chart-toolkit
./setup.sh

# Or one-liner
curl -fsSL https://raw.github.com/<org>/chart-toolkit/main/setup.sh | bash
```

## Quick Start

After install, restart your Agent and say:

```
"画一个微服务架构图"
"Create a flowchart for our CI/CD pipeline"
"Turn this article into a mind map"
"Make a data dashboard for Q2 sales"
```

The toolkit will guide you interactively.

## How It Works

```
Your request
    → Intent Analysis (what domain? what complexity?)
    → Chart Proposal (3-5 best-fit chart types for you to choose)
    → Deep Interview (clarifying questions)
    → Generation (best engine produces the diagram)
    → Output (SVG/PNG/.md/.drawio/.canvas)
```

## Project Structure

```
chart-toolkit/
├── chart-toolkit.md          ← The soul — main prompt
├── adapters/                 ← Engine wrappers
├── knowledge/                ← Decision guides
├── engines/                  ← Upstream tools (cloned at setup)
├── scripts/                  ← Doctor, deps, MCP merge
├── agents/                   ← Agent-specific installers
└── docs/                     ← You are here
```

## License

MIT
```

- [ ] **Step 2: Write docs/README.zh.md**

```markdown
# Chart Toolkit 图表工具箱

> 一句话描述需求，自动推荐最佳图表方案，交互式引导生成专业图表。

跨 Agent、跨平台的图表生成统一入口。支持架构图、流程图、时序图、思维导图、手绘草图、数据可视化等 17 种图表类型。

## 支持引擎

| 引擎 | 最擅长 | 输出格式 |
|---|---|---|
| Fireworks Tech Graph | 架构图、UML、ER、数据流 | SVG + PNG (1920px) |
| Mermaid | 流程图、时序图、甘特图 | .md (GitHub/Obsidian 原生渲染) |
| Excalidraw | 手绘风格图 | .md / .excalidraw |
| Obsidian Canvas | 思维导图、概念图 | .canvas |
| Drawio | 可编辑图表、协作 | .drawio / .png / .svg |
| Dataviz | 数据看板、图表、KPI | HTML / SVG / PNG |

## 一条命令安装

```bash
git clone https://github.com/<org>/chart-toolkit.git
cd chart-toolkit && ./setup.sh
```

## 使用方法

重启 Agent 后说：

```
画一个微服务架构图
生成 CI/CD 流程图
把这篇文档整理成思维导图
做一个 Q2 销售数据看板
```

工具会自动分析意图、列举可选方案、引导式问答、最终生成图表。

## 架构

```
用户输入 → 意图分析 → 图表建议清单 → 深度访谈 → 工具编排 → 输出
```

## 许可

MIT
```

- [ ] **Step 3: Write docs/install.md**

```markdown
# Installation Guide

## Prerequisites

- **git** (for cloning engines)
- **Python 3.9+** (for fireworks SVG→PNG conversion)
- **Node.js 18+** (for Drawio MCP, optional)
- **pip** (for cairosvg)

## Platform-Specific

### macOS

```bash
# Install prerequisites
brew install git python3 node librsvg

# Install chart-toolkit
git clone https://github.com/<org>/chart-toolkit.git
cd chart-toolkit
./setup.sh
```

### Linux (Ubuntu/Debian)

```bash
sudo apt-get update
sudo apt-get install -y git python3 python3-pip nodejs npm librsvg2-bin

git clone https://github.com/<org>/chart-toolkit.git
cd chart-toolkit
./setup.sh
```

### Windows

**Option A: PowerShell**
```powershell
git clone https://github.com/<org>/chart-toolkit.git
cd chart-toolkit
.\setup.ps1
```

**Option B: Git Bash / WSL**
```bash
git clone https://github.com/<org>/chart-toolkit.git
cd chart-toolkit
./setup.sh
```

## What setup.sh Does

1. Detects platform (macOS/Linux)
2. Checks prerequisites (git, python3, node)
3. Installs missing dependencies (cairosvg, rsvg-convert)
4. Clones 4 upstream engines into `engines/`
5. Creates symlinks in your Agent's skills directory
6. Checks/Merges Drawio MCP configuration
7. Runs doctor check
8. Prints success report

## Manual Install (Any Agent)

If your Agent doesn't have auto-detection:

1. Clone the repo anywhere
2. Symlink or copy `chart-toolkit/` to your Agent's skills directory
3. Or reference directly: `@/path/to/chart-toolkit/chart-toolkit.md`

## Verifying Installation

```bash
./scripts/doctor.sh
```

Expected output: all green checkmarks (✔) for installed components.

## Updating

```bash
cd chart-toolkit
./setup.sh  # Re-runs engine clone and dependency checks
```

To update individual engines:
```bash
cd engines/fireworks-tech-graph && git pull
```

## Uninstalling

```bash
# Remove symlinks
rm ~/.claude/skills/chart-toolkit
rm ~/.agents/skills/chart-toolkit

# Remove toolkit directory
rm -rf /path/to/chart-toolkit
```
```

- [ ] **Step 4: Write docs/usage.md**

```markdown
# Usage Guide

## Basic Usage

Once installed, just describe what you want to draw. The toolkit handles the rest.

### Examples

```
画一个电商系统的微服务架构图
```

The toolkit will:
1. Analyze: domain=e-commerce, type=architecture, complexity=medium-high
2. Propose 3-5 chart types you can choose from
3. Ask clarifying questions (audience, components, style, etc.)
4. Generate SVG+PNG from the best engine

## Interactive Flow

Every request goes through 4 phases:

### Phase 1: Intent Analysis (automatic)
The toolkit silently analyzes your request to understand:
- What domain? (architecture, data flow, timeline, ...)
- What complexity? (simple, medium, complex)
- Who is the audience? (engineers, management, public)
- What's the output medium? (docs, slides, README, Obsidian)

### Phase 2: Chart Proposal (YOU choose)
The toolkit presents 3-5 chart type options. Each includes:
- Chart type name
- Recommended engine + style
- Output format
- Best-for description

You pick one or more (e.g., "A", "B+C", "A+D").

### Phase 3: Deep Interview (interactive)
4 deep questions tailored to your selection, then 4 standard questions.

### Phase 4: Generation (automatic)
The toolkit loads the right engine and generates your diagram.

## Trigger Words

The toolkit auto-activates on these keywords (Chinese and English):

| Chinese | English |
|---|---|
| 画图, 帮我画, 生成图, 做个图 | draw, create, generate, make |
| 架构图, 流程图, 思维导图 | architecture diagram, flowchart, mind map |
| 可视化, 可视化一下, 出图 | visualize, diagram, chart |
| 数据看板, 报表 | dashboard, data viz, report |
| 时序图, 类图, ER图 | sequence diagram, class diagram, ER |

## Picking the Right Tool (Manual)

If you know which engine you want, you can specify directly:

| Say this... | To use... |
|---|---|
| "用 fireworks 画..." | Fireworks Tech Graph (SVG+PNG) |
| "用 Mermaid 画..." | Mermaid (.md code block) |
| "用 Excalidraw 画..." | Excalidraw (hand-drawn) |
| "用 Canvas 做思维导图" | Obsidian Canvas (.canvas) |
| "用 Drawio 画..." | Drawio (browser editing) |
| "做数据可视化" | Dataviz |

## Tips

1. **Be specific**: "电商微服务架构图" is better than "画图"
2. **Mention the audience**: "给老板看的" vs "技术文档用" → different styles
3. **Mention the output medium**: "放 README 里" → Mermaid; "放 PPT 里" → fireworks PNG
4. **You can combine**: "既是架构图又想要 Mermaid 代码块" → two engines run

## Troubleshooting

| Problem | Solution |
|---|---|
| "cairosvg not found" | `pip install cairosvg` or toolkit falls back to rsvg-convert |
| "Drawio MCP not available" | Run `claude mcp add drawio -- npx @next-ai-drawio/mcp-server@latest` |
| "Engine not found" | Run `./setup.sh` to clone engines |
| "Symbolic link failed" (Windows) | Run setup.ps1 (uses Junction or copy fallback) |
| Chart quality not good | Be more specific in Phase 3 interview; try a different style |
```

- [ ] **Step 5: Commit**

```bash
cd /Users/fengwanchang/Documents/Obsidian/06-AI工具/chart-toolkit
git add docs/README.md docs/README.zh.md docs/install.md docs/usage.md
git commit -m "docs: add README (EN/CN), install guide, and usage guide"
```

---

### Task 13: Final Integration & Push

**Files:**
- Verify: all files exist and are committed
- Push to GitHub remote

- [ ] **Step 1: Verify all files**

```bash
cd /Users/fengwanchang/Documents/Obsidian/06-AI工具/chart-toolkit
find . -type f -not -path './.git/*' -not -path './engines/*' | sort
# Expected output:
# ./agents/install-all.sh
# ./agents/install-claude.sh
# ./agents/install-codex.sh
# ./adapters/canvas-adapter.md
# ./adapters/dataviz-adapter.md
# ./adapters/drawio-adapter.md
# ./adapters/excalidraw-adapter.md
# ./adapters/fireworks-adapter.md
# ./adapters/mermaid-adapter.md
# ./chart-toolkit.md
# ./docs/DESIGN.md
# ./docs/README.md
# ./docs/README.zh.md
# ./docs/install.md
# ./docs/plans/2026-07-22-chart-toolkit-v1.md
# ./docs/usage.md
# ./knowledge/capability-matrix.md
# ./knowledge/decision-tree.md
# ./knowledge/examples.md
# ./knowledge/style-catalog.md
# ./scripts/deps-linux.sh
# ./scripts/deps-macos.sh
# ./scripts/deps-windows.ps1
# ./scripts/doctor.ps1
# ./scripts/doctor.sh
# ./scripts/merge-mcp.sh
# ./setup.bat
# ./setup.ps1
# ./setup.sh
```

- [ ] **Step 2: Run doctor check**

```bash
cd /Users/fengwanchang/Documents/Obsidian/06-AI工具/chart-toolkit
bash scripts/doctor.sh
```

- [ ] **Step 3: Create GitHub repository and push**

```bash
cd /Users/fengwanchang/Documents/Obsidian/06-AI工具/chart-toolkit
# Ensure engines/ is in .gitignore (not committed)
grep 'engines/' .gitignore

# Add GitHub remote (replace with actual repo URL)
git remote add origin https://github.com/<your-username>/chart-toolkit.git

# Push
git branch -M main
git push -u origin main
```

- [ ] **Step 4: Final commit to capture all changes**

```bash
cd /Users/fengwanchang/Documents/Obsidian/06-AI工具/chart-toolkit
git add -A
git status
# Should show clean working tree (engines/ excluded by .gitignore)
```
