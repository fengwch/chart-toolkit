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