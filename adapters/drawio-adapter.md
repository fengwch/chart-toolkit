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

1. **Runtime Check** — verify `mcp__drawio__*` tools are present in this agent's tool list.
   If missing, STOP and tell the user to install manually following their AI Agent
   platform's docs (see SKILL.md Phase 4 Drawio section for the manual-install message).
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

If Drawio MCP is unavailable after the 3-tier check AND auto-fix:
- Offer Fireworks Tech Graph as an alternative for static diagrams (SVG+PNG)
- Offer Excalidraw for hand-drawn style editable diagrams (.excalidraw)
- Last resort: Write raw Drawio XML directly to a `.drawio` file — it's valid
  draw.io XML that can be opened at https://app.diagrams.net (Free Edition).