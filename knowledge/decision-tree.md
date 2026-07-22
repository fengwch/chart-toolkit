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
