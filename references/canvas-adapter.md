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