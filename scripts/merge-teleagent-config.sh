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
    const data = { drawio: { command: ['npx', '@next-ai-drawio/mcp-server@latest'], enabled: true, type: 'local' } };
    fs.writeFileSync('$CONFIG', JSON.stringify(data, null, 2) + '\n');
  "
  echo "✔ $AGENT_LABEL: created $CONFIG with drawio entry"
  echo "  → restart TeleAgent for MCP tools to load"
  exit 0
fi

# Merge into existing config
node -e "
const fs = require('fs');
const path = '$CONFIG';
const raw = fs.readFileSync(path, 'utf8');

let data;
try { data = JSON.parse(raw); }
catch (e) {
  console.error('✖ $AGENT_LABEL: TeleAgent.jsonc is not valid JSON — manual edit required');
  console.error('  File: ' + path);
  console.error('  Append this object at root level (after the last field, before closing brace):');
  console.error('    \"drawio\": { \"command\": [\"npx\", \"@next-ai-drawio/mcp-server@latest\"], \"enabled\": true, \"type\": \"local\" }');
  process.exit(1);
}

if (data.drawio) {
  console.log('✔ $AGENT_LABEL: drawio MCP already configured');
  process.exit(0);
}

data.drawio = {
  command: ['npx', '@next-ai-drawio/mcp-server@latest'],
  enabled: true,
  type: 'local'
};

// Preserve trailing newline
const endsWithNewline = raw.endsWith('\n');
fs.writeFileSync(path, JSON.stringify(data, null, 2) + (endsWithNewline ? '\n' : ''));
console.log('✔ $AGENT_LABEL: drawio MCP appended to ' + path);
console.log('  → restart TeleAgent for MCP tools to load');
"