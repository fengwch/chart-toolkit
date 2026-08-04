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
| 18 | AI-Generated Visual | gpt-image | fireworks | PNG/JPEG/WebP | Creative visuals, quick prototypes, artistic diagrams |

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
