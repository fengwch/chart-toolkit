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