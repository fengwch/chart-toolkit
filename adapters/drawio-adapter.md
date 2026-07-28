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
2. **Create the diagram first, start session last:**
   - First call: `create_new_diagram` with generated XML — this is the only safe
     initial call (no parameters required beyond the XML). Returns a session URL.
   - **Do NOT call `start_session` until you have a session URL from
     `create_new_diagram` or `load_diagram`.** Calling `start_session` with no
     arguments raises "No arguments provided" and the host platform may flag
     the tool call as high-risk behaviour, aborting the task.
   - For editing an existing file: `load_diagram` (path → returns session URL)
3. **Open browser preview** — once you have a session URL, call `start_session`
   with it to open the browser window. Skip this step entirely if the agent is
   running in a headless / non-interactive context (CI, batch jobs) — the
   generated `.drawio` file is the deliverable.
4. **Iterate**: Use `edit_diagram` for modifications (natural language → XML operations)
5. **Export**: `export_diagram` to save as .drawio, .png, or .svg
6. **Report**: file path + (if session was started) note that browser preview is live

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