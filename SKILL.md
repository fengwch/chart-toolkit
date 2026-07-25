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

## Language Rule (Applies to ALL Phases)

**Detect the language of the user's FIRST input message:**

- **If the input contains only English characters, numbers, and punctuation** → use
  **English** for all reasoning, summaries, questions, labels, and outputs.
- **Otherwise** (contains any Chinese, mixed CJK, or non-ASCII text) → use **中文**
  for all reasoning, summaries, questions, labels, and outputs.

**How to apply this rule:**
1. After reading the user's message, decide `LANGUAGE=en` or `LANGUAGE=zh`.
2. **All subsequent thinking, analysis, questions, and generated artifacts must
   follow `LANGUAGE`.**
3. This rule overrides any other language cue. Do NOT switch languages mid-flow.
4. Chart type names and engine names may stay as-is (e.g., "Mermaid", "fireworks")
   because they are proper nouns, but surrounding explanations must follow
   `LANGUAGE`.

## Hard Rules (DO NOT SKIP)

0. **ALWAYS run Phase 0 (Environment Check) first.** If no engines are
   installed, stop and guide the user to run setup. Do NOT proceed to Phase 1.
1. **ALWAYS complete Phase 2 (Chart Proposal) before any generation.** Never
   jump straight to drawing. The user must see options and choose.
2. **Present 3-5 chart type options**, each with: name, recommended tool,
   output format, and one-line use case. Rank best option first (marked ⭐).
3. **Wait for user selection** before proceeding to Phase 3. If user says
   "continue", "随便", "你决定", or similar, re-ask explicitly: "Please pick
   A/B/C/D so I know which engine and format to use."
4. **Deep Interview (4 questions) comes BEFORE Standard 4 Questions.** Ask
   one question at a time, adapt based on the selected chart type.
5. **Load adapters on demand** — only load the adapter for the engine the user
   selected. Do not load all adapters at once.
6. **Do NOT convert between formats.** Each engine produces its own best
   format. If the user wants two formats, run two engines.
7. **If the user did not provide source content** (e.g., just says "画一个架构图"),
   ask for it in Phase 1/2 before proposing chart types.

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
2. **Load** decision tree from `knowledge/decision-tree.md` to narrow options
3. **Check** the user's current context (Obsidian vault? git repo? writing docs?)
4. **Identify missing source content** — if the user only gave a topic without
   details, note that you will need to ask for it in Phase 2

Output a brief analysis summary before Phase 2, in the chosen `LANGUAGE`.

---

## Phase 2: Chart Proposal (MANDATORY — DO NOT SKIP)

**All text in this phase must follow `LANGUAGE`.**

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

**If source content is missing**, ask for it here before or alongside the proposal:
- EN: "To draw this architecture diagram, please paste the component list or describe the system."
- 中文："要画这个架构图，请先粘贴组件列表或描述一下系统。"
- EN: "What data should the dashboard display?"
- 中文："这个看板要展示哪些数据？"
- EN: "Please share the article/text you want turned into a mind map."
- 中文："请分享你想转成思维导图的文章或文本。"

**Reference examples** in `knowledge/examples.md` if needed.

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
2. **Load the corresponding adapter**: read `adapters/<engine>-adapter.md`
3. **Engine was already verified in Phase 0.** If somehow missing now (e.g.,
   user deleted it mid-session), tell the user to re-run setup and stop.

### Step 2: Runtime Environment Check (MANDATORY — DO NOT SKIP)

**After the adapter is loaded but BEFORE generating anything**, check whether
the current system has the runtime prerequisites for the selected engine.

Use `command -v <tool>` (macOS/Linux) or `Get-Command <tool>` (PowerShell) to
verify CLI tools. For Python packages, use `python3 -c "import <module>"`.
For MCP, check whether the corresponding `mcp__*` tools appear in your tool list.

#### Runtime Prerequisites Matrix

| Engine | CLI Tools | Python / Node | MCP Server | Script Deps |
|---|---|---|---|---|
| **fireworks** | `python3` | `cairosvg` (pip) | — | OR `rsvg-convert` |
| **Mermaid** | — | — | — | None (platform-rendered) |
| **Excalidraw** | — | — | — | None (JSON output) |
| **Canvas** | — | — | — | None (JSON output) |
| **Drawio** | `node` (≥18) | — | `mcp__drawio__*` | `@next-ai-drawio/mcp-server` |
| **Dataviz** | — | — | — | None (methodology-based) |

#### Check Procedure (per engine)

**fireworks:**
```bash
# Check python3
command -v python3 || echo "MISSING: python3"

# Check SVG→PNG converter (need at least one)
python3 -c "import cairosvg" 2>/dev/null && echo "OK: cairosvg" || echo "MISSING: cairosvg"
command -v rsvg-convert 2>/dev/null && echo "OK: rsvg-convert" || echo "MISSING: rsvg-convert"
```
Auto-fix (safe — run without asking):
```bash
pip3 install cairosvg 2>/dev/null || true
# Fallback on macOS:
# brew install librsvg
# Fallback on Linux:
# sudo apt-get install -y librsvg2-bin
```
If both `cairosvg` AND `rsvg-convert` are missing → warn user but continue
(generation still works; only PNG export will fail).

**Drawio:**
```bash
# Check node.js
command -v node && node -v || echo "MISSING: node"

# Check MCP: scan your tool list for any mcp__drawio__* tool
# If absent → the MCP server is not configured
```
Auto-fix guidance:
- EN: "Drawio MCP is not configured. Run `./scripts/merge-mcp.sh ~/.claude/mcp.json` in the chart-toolkit directory, or run `./setup.sh` which does this automatically."
- 中文："Drawio MCP 未配置。在 chart-toolkit 目录下运行 `./scripts/merge-mcp.sh ~/.claude/mcp.json`，或运行 `./setup.sh` 自动配置。"

**Mermaid / Excalidraw / Canvas / Dataviz:**
No runtime check needed. Proceed directly to generation.

#### What to Do on Failure

| Severity | Condition | Action |
|---|---|---|
| **BLOCKER** | `node` missing for Drawio | Stop. Tell user to install Node.js 18+. |
| **BLOCKER** | Drawio MCP tools not in your tool list | Stop. Tell user to configure MCP, then restart agent. |
| **WARNING** | `cairosvg` + `rsvg-convert` both missing | Warn that PNG export won't work, offer to install. Continue with SVG-only. |
| **WARNING** | `python3` missing for fireworks | Warn that fireworks needs Python 3. Offer to install. |

#### Report Format

After the check, report in `LANGUAGE`:

```
🔍 Runtime Check: <Engine Name>
   ✔ python3: /usr/bin/python3
   ✔ cairosvg: installed
   ⚠ rsvg-convert: not installed (PNG fallback unavailable)
   → Result: READY (SVG only; run `pip3 install cairosvg` for PNG)
```

### Step 3: Generate

4. **Follow the adapter's execution instructions** — each adapter documents
   exactly how to load and run its upstream engine
5. **Generate** the diagram following the upstream engine's original workflow
6. **Report** output file paths and usage instructions

### Adapter Loading Table

| Selected Engine | Engine Directory | Load This Adapter | Upstream Source |
|---|---|---|---|
| fireworks | `engines/fireworks-tech-graph/` | `adapters/fireworks-adapter.md` | `engines/fireworks-tech-graph/SKILL.md` |
| Mermaid | `engines/mermaid-visualizer/` | `adapters/mermaid-adapter.md` | `engines/mermaid-visualizer/SKILL.md` |
| Excalidraw | `engines/excalidraw-diagram/` | `adapters/excalidraw-adapter.md` | `engines/excalidraw-diagram/SKILL.md` |
| Canvas | `engines/canvas-creator/` | `adapters/canvas-adapter.md` | `engines/canvas-creator/SKILL.md` |
| Drawio | (MCP) | `adapters/drawio-adapter.md` | MCP tools (mcp__drawio__*) |
| Dataviz | (built-in) | `adapters/dataviz-adapter.md` | Built-in `dataviz` Skill |

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

For the full 17-type matrix, see `knowledge/capability-matrix.md`.