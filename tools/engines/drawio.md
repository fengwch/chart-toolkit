# Engine: Drawio (via MCP)

Real-time browser editing via `@next-ai-drawio/mcp-server`.

## Tool prereqs

| Tool | Why | Check |
|---|---|---|
| `node` (≥18) | runs `npx @next-ai-drawio/mcp-server@latest` | `node --version` |
| Drawio MCP entry in `~/.claude/mcp.json` | agent must have `mcp__drawio__*` tools | see below |

## Check

```bash
bash tools/check.sh drawio
# OK     :: drawio         # node + .mcp.json entry present
# NEED   :: drawio :: node # missing prereq
```

## Setup

```bash
# Ensure node + MCP entry are configured:
bash tools/check.sh drawio --fix

# Then verify in your Agent session:
# `mcp__drawio__*` tools should appear; if missing restart the agent.
```

## Notes

- 13 MCP tools: `start_session`, `create_new_diagram`, `edit_diagram`, `get_diagram`, `export_diagram`, `list_pages`, `add_page`, `rename_page`, `delete_page`, `load_diagram`, …
- Output: `.drawio`, `.png`, `.svg`
