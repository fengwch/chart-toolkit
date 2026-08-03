# Runtime Environment Check

**After the adapter is loaded but BEFORE generating anything**, check whether
the current system has the runtime prerequisites for the selected engine.

Use `command -v <tool>` (macOS/Linux) or `Get-Command <tool>` (PowerShell) to
verify CLI tools. For Python packages, use `python3 -c "import <module>"`.
For MCP, check whether the corresponding `mcp__*` tools appear in your tool list.

## Runtime Prerequisites Matrix

| Engine | CLI Tools | Python / Node | MCP Server | Script Deps |
|---|---|---|---|---|
| **fireworks** | `python3` | `cairosvg` (pip) | — | OR `rsvg-convert`, OR Node.js + playwright/sharp |
| **Mermaid** | — | — | — | None (platform-rendered) |
| **Excalidraw** | — | — | — | None (JSON output) |
| **Canvas** | — | — | — | None (JSON output) |
| **Drawio** | `node` (≥18), `npx` | — | `mcp__drawio__*` | `@next-ai-drawio/mcp-server@latest` (via npx) |
| **Dataviz** | — | — | — | None (methodology-based) |

## Check Procedure (per engine)

### fireworks

```bash
# Check python3
command -v python3 || echo "MISSING: python3"

# Check SVG→PNG converter (need at least one)
python3 -c "import cairosvg" 2>/dev/null && echo "OK: cairosvg" || echo "MISSING: cairosvg"
command -v rsvg-convert 2>/dev/null && echo "OK: rsvg-convert" || echo "MISSING: rsvg-convert"

# Browser-based fallback (Windows: cairosvg/rsvg-convert often unavailable)
command -v node && node -e "try{require('playwright');console.log('OK: playwright')}catch(e){console.log('MISSING: playwright')}" 2>/dev/null
command -v node && node -e "try{require('sharp');console.log('OK: sharp')}catch(e){console.log('MISSING: sharp')}" 2>/dev/null
```

Auto-fix (safe — run without asking):

```bash
# macOS / Linux: pip-based (fastest, no browser needed)
pip3 install cairosvg 2>/dev/null || true
# Fallback on macOS:
# brew install librsvg
# Fallback on Linux:
# sudo apt-get install -y librsvg2-bin

# Windows: use browser-based renderer (cairosvg needs Cairo C library — unavailable)
# The fireworks engine has a built-in multi-tier converter:
#   node engines/fireworks-tech-graph/scripts/svg-to-png.js file.svg file.png 1920
# It tries: playwright → puppeteer-core (system Chrome) → puppeteer → sharp
npm install playwright 2>/dev/null || true   # self-contained, recommended
npx playwright install chromium 2>/dev/null || true
npm install sharp 2>/dev/null || true        # lightweight alternative (libvips, no browser)
```

If `cairosvg` AND `rsvg-convert` AND `node+playwright/sharp` are all missing → warn user
but continue (generation still works; only PNG export will fail).

### Drawio

**Step A — check environment**

```bash
command -v node && node -v || echo "MISSING: node"
command -v npx && npx --version || echo "MISSING: npx"
```

**Step B — check whether MCP tools are loaded in this agent**

- Scan your current tool list for any `mcp__drawio__*` tool (e.g. `mcp__drawio__start_session`).
- If found → MCP is working, proceed to Step C.
- If not found → attempt Step B.1 (auto-config for known agents). If still missing after that, show the manual-install message.

**Step B.1 — auto-configure MCP for TeleAgent (and other known agents)**

`setup.{sh,ps1}` already writes `~/.claude/mcp.json` and `~/.agents/mcp.json`
during install. If those `mcp__drawio__*` tools still aren't showing, the
most likely cause is the agent hasn't been restarted since the config was
written. Tell the user to **restart the agent**.

For **TeleAgent**, the config format is different (not `mcp.json`):
`~/.config/TeleAgent/TeleAgent.jsonc`. Append this entry:

```jsonc
"drawio": {
  "command": [
    "npx",
    "@next-ai-drawio/mcp-server@latest"
  ],
  "enabled": true,
  "type": "local"
}
```

**File location by agent:**

| Agent | Config file path |
|---|---|
| Claude Code | `~/.claude/mcp.json` (already written by setup) |
| Codex | `~/.agents/mcp.json` (already written by setup) |
| **TeleAgent** | `~/.config/TeleAgent/TeleAgent.jsonc` (Windows: `%USERPROFILE%\.config\TeleAgent\TeleAgent.jsonc`) — **append `drawio` entry above** |

**TeleAgent merge helper:** `scripts/merge-teleagent-config.sh` (bash) or
`scripts/merge-teleagent-config.ps1` (PowerShell) appends the JSONC entry
atomically (idempotent — skips if `drawio` entry already exists).

After running the helper, **restart TeleAgent** so it picks up the new config.

**Step C — proceed with `mcp__drawio__*` tools (safe call order)**

**Important:** Some hosts (e.g. TeleAgent) abort a task when `mcp__drawio__*` is
called with no arguments or out of order. Always call in this order:

1. `create_new_diagram` (with generated XML) — establishes the session
2. `start_session` (with the URL returned above) — opens browser preview
3. `edit_diagram` — iterate on the diagram
4. `export_diagram` — save to .drawio / .png / .svg

Never call `start_session` first or with no arguments — it returns
"No arguments provided" and may trigger host safety aborts.

Full procedure in `references/drawio-adapter.md`.

### Mermaid / Excalidraw / Canvas / Dataviz

No runtime check needed. Proceed directly to generation.

## What to Do on Failure

| Severity | Condition | Action |
|---|---|---|
| **BLOCKER** | `node` missing for Drawio | Stop. Tell user to install Node.js 18+. |
| **BLOCKER** | Drawio MCP tools not in your tool list after Tier-3 check | Stop. Tell user to configure MCP, then restart agent. |
| **WARNING** | `cairosvg` + `rsvg-convert` + playwright/sharp all missing | Warn that PNG export won't work, offer to install. Continue with SVG-only. |
| **WARNING** | `python3` missing for fireworks | Warn that fireworks needs Python 3. Offer to install. |

## Report Format

After the check, report in `LANGUAGE`:

```
🔍 Runtime Check: fireworks
   ✔ python3: /usr/bin/python3
   ✔ cairosvg: installed
   ⚠ rsvg-convert: not installed (PNG fallback unavailable)
   → Result: READY (SVG + PNG via cairosvg)

🔍 Runtime Check: fireworks (Windows)
   ✔ python3: C:\Python311\python.exe
   ⚠ cairosvg: not installed (Cairo C library unavailable on Windows)
   ✔ playwright: installed
   → Result: READY (SVG + PNG via svg-to-png.js / playwright)

🔍 Runtime Check: Drawio
   ✔ node: v20.11.0
   ✔ npx: 10.5.2
   ✔ drawio package: @next-ai-drawio/mcp-server@latest (cached)
   ✔ mcp.json: drawio entry found at ~/.claude/mcp.json
   ⚠ mcp__drawio__* tools: NOT in tool list
   → Result: BLOCKED — restart Agent to load MCP server

🔍 Runtime Check: Drawio (after restart)
   ✔ node: v20.11.0
   ✔ npx: 10.5.2
   ✔ mcp.json: drawio entry found
   ✔ mcp__drawio__* tools: 8 tools available (start_session, edit_diagram, …)
   → Result: READY
```
