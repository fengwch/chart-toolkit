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