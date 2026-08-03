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

## Language Rule

Detect the language of the user's FIRST input. All subsequent output follows.
→ 详见 `references/language-rule.md`

## Hard Rules

0. ALWAYS run Phase 0 first.
1. ALWAYS complete Phase 2 before generation.
2. Present 3-5 chart type options.
3. Wait for user selection.
4. Deep Interview before Standard 4 Questions.
5. Load adapters on demand.
6. Do NOT convert between formats.
7. If user didn't provide source content, ask for it.
→ 详见 `references/hard-rules.md`

---

## Phase 0: Environment Check (RUN FIRST)

**Before any analysis or proposal**, scan the `engines/` directory to see which
engines are actually installed. Use `ls engines/*/SKILL.md` or equivalent to
discover available backends.

### Engine → Directory Mapping

| Engine | Required Path | Install Source |
|---|---|---|
| fireworks | `engines/fireworks-tech-graph/SKILL.md` | `./setup.sh` / `.\setup.ps1` (clones from GitHub) |
| Mermaid | `engines/mermaid-visualizer/SKILL.md` | `./setup.sh` / `.\setup.ps1` (extracted from axton) |
| Excalidraw | `engines/excalidraw-diagram/SKILL.md` | `./setup.sh` / `.\setup.ps1` (extracted from axton) |
| Canvas | `engines/canvas-creator/SKILL.md` | `./setup.sh` / `.\setup.ps1` (extracted from axton) |
| Drawio | (MCP runtime) | `./setup.sh` / `.\setup.ps1` (npm MCP, per-agent) |
| Dataviz | (built-in) | Always available — no external deps |

### If ZERO engines are installed

Stop immediately and guide the user to run setup. Do NOT proceed to Phase 1.

**macOS / Linux:**
```bash
cd "$(dirname "$(readlink -f ~/.claude/skills/chart-toolkit/SKILL.md 2>/dev/null || echo ".")")" && ./setup.sh
```

**Windows (PowerShell):**
```powershell
cd "$env:USERPROFILE\.claude\skills\chart-toolkit"; .\setup.ps1
# Or for Codex:
cd "$env:USERPROFILE\.agents\skills\chart-toolkit"; .\setup.ps1
```

If you cannot determine the toolkit path, tell the user:
- 中文："chart-toolkit 引擎还未安装。请在终端中进入 chart-toolkit 目录，运行 `./setup.sh`（macOS/Linux）或 `.\setup.ps1`（Windows），安装完成后重新对我说'画图'即可。"
- EN: "Chart Toolkit engines are not installed yet. Please run `./setup.sh` (macOS/Linux) or `.\setup.ps1` (Windows) in the chart-toolkit directory, then come back and say 'draw a diagram'."

### If SOME engines are installed

Note which engines are available and which are missing. During Phase 2 (Chart
Proposal), **only propose chart types whose engine is installed**. If the user's
request naturally maps to a missing engine, mention it but offer the available
alternative:

- 中文："⚠ fireworks 引擎未安装（运行 `./setup.sh` 即可安装），当前可用引擎：Mermaid、Dataviz。建议先用 Mermaid 画流程图，或先安装 fireworks 画出更精美的架构图。"
- EN: "⚠ fireworks engine is not installed (run `./setup.sh` to install). Available engines: Mermaid, Dataviz. I can draw a flowchart with Mermaid now, or you can install fireworks first for a polished architecture diagram."

---

## Phase 1: Intent Analysis

**Use the `LANGUAGE` decided by the Language Rule above.**

Before proposing anything, silently analyze the user's request:

1. **Extract** — domain, complexity, audience, output medium
2. **Load** decision tree from `references/decision-tree.md` to narrow options
3. **Check** the user's current context (Obsidian vault? git repo? writing docs?)
4. **Identify missing source content** — if the user only gave a topic without
   details, note that you will need to ask for it in Phase 2

Output a brief analysis summary before Phase 2, in the chosen `LANGUAGE`.

---

## Phase 2: Chart Proposal (MANDATORY — DO NOT SKIP)

**All text in this phase must follow `LANGUAGE`.**

**Load `references/capability-matrix.md`** to build the proposal.

For each proposed chart type, include:

```
N. [⭐ if best match] Chart Type Name
   → Engine: EngineName + Style/Subtype
   → Output: format(s)
   → Best for: one-line scenario description
```

Present 3-5 options. Ask the user to choose one or more (e.g., "A", "B+D", "A+C").
Do NOT proceed until the user selects.

**If source content is missing**, ask for it here before or alongside the proposal:
- EN: "To draw this architecture diagram, please paste the component list or describe the system."
- 中文："要画这个架构图，请先粘贴组件列表或描述一下系统。"
- EN: "What data should the dashboard display?"
- 中文："这个看板要展示哪些数据？"
- EN: "Please share the article/text you want turned into a mind map."
- 中文："请分享你想转成思维导图的文章或文本。"

**Reference examples** in `references/examples.md` if needed.

---

## Phase 3: Interactive Deep Interview

**Ask every question in `LANGUAGE`.**

After user selection, ask **4 deep questions** (one at a time), tailored to the
selected chart type(s):

**Deep Questions (adapt per chart type):**

| If architecture/flow/data | If mind map/concept | If data viz |
|---|---|---|
| Q1: 受众是谁？ / Who is the audience? | Q1: 中心主题是什么？ / What's the central topic? | Q1: 要突出哪些指标？ / What metrics to highlight? |
| Q2: 有哪些关键组件？ / What key components? | Q2: 分几层？ / How many levels deep? | Q2: 时间范围/对比对象？ / Time range / comparison? |
| Q3: 布局方向偏好？ / Preferred layout direction? | Q3: 颜色编码偏好？ / Color coding preference? | Q3: 静态还是交互？ / Static or interactive? |
| Q4: 需要多少细节？ / Level of detail needed? | Q4: 是否有特定分组？ / Any specific grouping? | Q4: 嵌入文档还是独立？ / Embed in doc or standalone? |

**Then 4 standard questions:**

1. Output format preference? / 输出格式偏好？
2. Style preference? / 风格偏好？
3. Need animation / motion? / 是否需要动画？
4. Any special requirements? / 还有什么特殊要求？

---

## Phase 4: Orchestration

**All reports and instructions in this phase must follow `LANGUAGE`.**

For each chart type the user selected:

### Step 1: Identify Engine + Load Adapter

1. **Identify the engine** from Phase 2 selection
2. **Load the corresponding adapter**: read `references/<engine>-adapter.md`
3. **Engine was already verified in Phase 0.** If somehow missing now (e.g.,
   user deleted it mid-session), tell the user to re-run setup and stop.

### Step 2: Runtime Environment Check (MANDATORY — DO NOT SKIP)

Check runtime prerequisites before generating.
→ 详细检查步骤和 auto-fix 命令见 `references/runtime-check.md`

### Step 3: Generate

4. **Follow the adapter's execution instructions** — each adapter documents
   exactly how to load and run its upstream engine
5. **Generate** the diagram following the upstream engine's original workflow
6. **Report** output file paths and usage instructions

### Adapter Loading Table

| Selected Engine | Engine Directory | Load This Adapter | Upstream Source |
|---|---|---|---|
| fireworks | `engines/fireworks-tech-graph/` | `references/fireworks-adapter.md` | `engines/fireworks-tech-graph/SKILL.md` |
| Mermaid | `engines/mermaid-visualizer/` | `references/mermaid-adapter.md` | `engines/mermaid-visualizer/SKILL.md` |
| Excalidraw | `engines/excalidraw-diagram/` | `references/excalidraw-adapter.md` | `engines/excalidraw-diagram/SKILL.md` |
| Canvas | `engines/canvas-creator/` | `references/canvas-adapter.md` | `engines/canvas-creator/SKILL.md` |
| Drawio | (MCP) | `references/drawio-adapter.md` | MCP tools (mcp__drawio__*) |
| Dataviz | (built-in) | `references/dataviz-adapter.md` | Built-in `dataviz` Skill |

### Output File Naming Convention

Use kebab-case descriptive names based on the topic:
- `microservices-architecture.svg` + `.png`
- `ci-cd-pipeline.mermaid.md`
- `transformer-overview.canvas`
- `q2-sales-dashboard.html`

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

For the full 17-type matrix, see `references/capability-matrix.md`.