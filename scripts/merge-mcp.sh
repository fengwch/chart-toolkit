#!/usr/bin/env bash
# Merge Drawio MCP configuration into an agent's MCP config file.
# Agent-agnostic — call from each agent's installer with its config path.
#
# Usage: merge-mcp.sh <mcp_config_path> [agent_label]

set -euo pipefail

TOOLKIT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
CONFIG_FILE="${1:-}"
AGENT_LABEL="${2:-$(basename "$(dirname "$CONFIG_FILE")")}"

if [ -z "$CONFIG_FILE" ]; then
  echo "Usage: $(basename "$0") <mcp_config_path> [agent_label]"
  exit 1
fi

# ---- read drawio version from engines.json ----
# node.js is already required by drawio (npx); no extra dep needed.
read_drawio_version() {
  if command -v node &>/dev/null && [ -f "$TOOLKIT_DIR/engines.json" ]; then
    node -e 'try{process.stdout.write(require(process.argv[1]).engines.drawio.version)}catch(e){process.stdout.write("latest")}' \
      "$TOOLKIT_DIR/engines.json" 2>/dev/null || echo "latest"
  else
    echo "latest"
  fi
}

DRAWIO_VERSION="$(read_drawio_version)"
DRAWIO_PACKAGE="@next-ai-drawio/mcp-server@${DRAWIO_VERSION}"

# ---- merge drawio entry into an MCP config file ----
merge_drawio() {
  local cfg="$1" label="$2"

  mkdir -p "$(dirname "$cfg")"

  # Already configured?
  if [ -f "$cfg" ] && grep -q '"drawio"' "$cfg" 2>/dev/null; then
    echo "✔ $label: Drawio MCP already configured"
    return 0
  fi

  # Need node.js for JSON manipulation
  if ! command -v node &>/dev/null; then
    echo "⚠ $label: node.js not found — cannot configure Drawio MCP"
    echo "  Install node.js, then run: claude mcp add drawio -- npx $DRAWIO_PACKAGE"
    return 1
  fi

  local tmp="${cfg}.tmp.$$"

  if [ ! -f "$cfg" ]; then
    # Create new config from scratch
    node -e "
      var o = {mcpServers:{drawio:{command:'npx',args:['$DRAWIO_PACKAGE']}}};
      require('fs').writeFileSync('$cfg', JSON.stringify(o,null,2)+'\n');
    " && echo "✔ $label: Drawio MCP configured (created $cfg)" && return 0
  fi

  # Merge into existing config
  node -e "
    var fs=require('fs'), cfg=JSON.parse(fs.readFileSync('$cfg','utf8'));
    cfg.mcpServers = cfg.mcpServers || {};
    cfg.mcpServers.drawio = {command:'npx', args:['$DRAWIO_PACKAGE']};
    fs.writeFileSync('$tmp', JSON.stringify(cfg,null,2)+'\n');
  " && mv "$tmp" "$cfg" && echo "✔ $label: Drawio MCP merged into $cfg" && return 0

  rm -f "$tmp"
  echo "⚠ $label: failed to merge Drawio MCP"
  return 1
}

merge_drawio "$CONFIG_FILE" "$AGENT_LABEL"