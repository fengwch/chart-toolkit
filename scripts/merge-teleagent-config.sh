#!/usr/bin/env bash
# Append drawio MCP entry to TeleAgent's config file.
# TeleAgent uses TeleAgent.jsonc with a different schema than mcp.json:
#   "drawio": { "command": ["npx", "@next-ai-drawio/mcp-server@latest"], "enabled": true, "type": "local" }
#
# Usage: merge-teleagent-config.sh [agent_label]
# Reads path from $TELEAGENT_CONFIG env var if set, otherwise defaults to:
#   Linux/macOS:  $HOME/.config/TeleAgent/TeleAgent.jsonc
#   Windows:      %USERPROFILE%\.config\TeleAgent\TeleAgent.jsonc   (via $USERPROFILE)

set -euo pipefail

AGENT_LABEL="${1:-TeleAgent}"

# Resolve config path
if [ -n "${TELEAGENT_CONFIG:-}" ]; then
  CONFIG="$TELEAGENT_CONFIG"
elif [ -n "${USERPROFILE:-}" ]; then
  # Windows (Git Bash / WSL): USERPROFILE set, HOME may differ
  CONFIG="$USERPROFILE/.config/TeleAgent/TeleAgent.jsonc"
elif [ -n "${HOME:-}" ]; then
  CONFIG="$HOME/.config/TeleAgent/TeleAgent.jsonc"
else
  echo "✖ Cannot resolve TeleAgent config path (set TELEAGENT_CONFIG or HOME)" >&2
  exit 1
fi

if [ ! -d "$(dirname "$CONFIG")" ]; then
  echo "⊘ $AGENT_LABEL not installed — skipping ($CONFIG)"
  exit 0
fi

# Drawio entry to append (uses argv array, not string)
DRAWIO_ENTRY='  "drawio": {
    "command": [
      "npx",
      "@next-ai-drawio/mcp-server@latest"
    ],
    "enabled": true,
    "type": "local"
  }'

# Already configured?
if [ -f "$CONFIG" ] && grep -q '"drawio"' "$CONFIG" 2>/dev/null; then
  echo "✔ $AGENT_LABEL: drawio MCP already in $CONFIG"
  exit 0
fi

# Create from scratch if missing — write valid JSON via node (safer than sed)
if [ ! -f "$CONFIG" ]; then
  node -e "
    const fs = require('fs');
    // Use compact 2-space-indent format (NOT 4-space, which PowerShell emits)
    const data = { drawio: { command: ['npx', '@next-ai-drawio/mcp-server@latest'], enabled: true, type: 'local' } };
    fs.writeFileSync('$CONFIG', JSON.stringify(data, null, 2) + '\n');
  "
  echo "✔ $AGENT_LABEL: created $CONFIG with drawio entry"
  echo "  → restart TeleAgent for MCP tools to load"
  exit 0
fi

# Merge into existing config — append in compact format, NOT round-trip JSON.
# Reason: re-serializing with JSON.stringify(..., null, 2) may re-indent
# existing fields in a style that TeleAgent's JSONC parser rejects. We
# instead splice the block in literally, matching TeleAgent's expected
# indentation (2 spaces, 1 element per line for nested arrays).
node -e "
const fs = require('fs');
const path = '$CONFIG';
let raw = fs.readFileSync(path, 'utf8');
if (raw.charCodeAt(0) === 0xFEFF) raw = raw.slice(1); // strip UTF-8 BOM

const BLOCK = [
  '  \"drawio\": {',
  '    \"command\": [',
  '      \"npx\",',
  '      \"@next-ai-drawio/mcp-server@latest\"',
  '    ],',
  '    \"enabled\": true,',
  '    \"type\": \"local\"',
  '  }'
].join('\n');

let data;
try { data = JSON.parse(raw); }
catch (e) {
  console.error('✖ $AGENT_LABEL: TeleAgent.jsonc is not valid JSON — manual edit required');
  console.error('  File: ' + path);
  console.error('  Append this object at root level:');
  console.error('    \"drawio\": { \"command\": [\"npx\", \"@next-ai-drawio/mcp-server@latest\"], \"enabled\": true, \"type\": \"local\" }');
  process.exit(1);
}

if (data.drawio) {
  console.log('✔ $AGENT_LABEL: drawio MCP already configured');
  process.exit(0);
}

// Find last '}' and splice BLOCK + comma before it
const idx = raw.lastIndexOf('}');
if (idx < 0) { console.error('✖ malformed file'); process.exit(1); }

const before = raw.substring(0, idx).replace(/\s+\$/, '');
const endsWithComma = /,\s*\$/.test(before);
const insertion = (endsWithComma ? '\n' : ',\n') + BLOCK + '\n';
const newContent = before + insertion + raw.substring(idx);

fs.writeFileSync(path, newContent);
console.log('✔ $AGENT_LABEL: drawio MCP appended to ' + path);
console.log('  → restart TeleAgent for MCP tools to load');
"