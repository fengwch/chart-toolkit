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
- Python 3.9+ with `cairosvg` (`pip install cairosvg`) — preferred on macOS/Linux
- OR `rsvg-convert` (`brew install librsvg` / `apt install librsvg2-bin`) — macOS/Linux only
- OR `playwright` / `sharp` / `puppeteer` (Node.js 18+) — Windows fallback (cairosvg needs Cairo C library, unavailable on Windows)

## Execution

1. **Load the upstream skill**: Read `engines/fireworks-tech-graph/SKILL.md`
2. **Follow its Workflow**:
   a. Classify diagram type (see Diagram Types section)
   b. Extract structure — layers, nodes, edges, flows
   c. Plan layout — apply layout rules for the type
   d. Load style reference — `engines/fireworks-tech-graph/references/style-1-flat-icon.md` (or the matching style file)
   e. Map nodes to shapes — use Shape Vocabulary
   f. Check icon needs — `engines/fireworks-tech-graph/references/icons.md`
   g. Write SVG
   h. Validate: `python3 -c "import xml.etree.ElementTree as ET; ET.parse('file.svg')"`
   i. Export PNG: `cairosvg file.svg -o file.png` (or rsvg-convert)
3. **Report** the generated file paths

## Style Quick Reference
| Style # | File | Name | Best For |
|---|---|---|---|
| 1 | `style-1-flat-icon.md` | Flat Icon | General architecture (default) |
| 2 | `style-2-dark-terminal.md` | Dark Terminal | AI/Agent workflows, dev tools |
| 3 | `style-3-blueprint.md` | Blueprint | Microservices, complex systems |
| 4 | `style-4-notion-clean.md` | Notion Clean | Simple overviews |
| 5 | `style-5-glassmorphism.md` | Glassmorphism | Multi-agent, dashboards |
| 6 | `style-6-claude-official.md` | Claude Official | System architecture |
| 7 | `style-7-openai.md` | OpenAI Official | API flows |
| 8 | (in SKILL.md) | Dark Luxury | Premium presentations |
| 9 | (in SKILL.md) | C4 Canvas | Architecture review |
| 10 | (in SKILL.md) | Cloud Fabric | Multi-region deployment |
| 11 | (in SKILL.md) | Event Transit | Event-driven systems |
| 12 | (in SKILL.md) | Ops Pulse | SRE, monitoring |

## PNG Export Commands

### macOS / Linux (preferred: cairosvg)
```bash
python3 -c "import cairosvg; cairosvg.svg2png(url='file.svg', write_to='file.png', output_width=1920)"

# Fallback: rsvg-convert
rsvg-convert -w 1920 -o file.png file.svg
```

### Windows (cairosvg unavailable — needs Cairo C library)
```bash
# SVG→PNG conversion requires svg-to-png.js from the **full release package**
# (omitted in -secure builds). With the full release:
#   node engines/fireworks-tech-graph/scripts/svg-to-png.js file.svg file.png 1920
# Download: https://github.com/fengwch/chart-toolkit/releases

# If no renderer installed:
npm install playwright && npx playwright install chromium   # self-contained (recommended)
# or
npm install sharp                                          # lightweight (libvips, no browser)
```

### Any platform with node
```bash
# Same as above — requires svg-to-png.js from the full release package.
# Download: https://github.com/fengwch/chart-toolkit/releases
```