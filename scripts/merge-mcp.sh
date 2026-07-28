#!/usr/bin/env bash
# Merge Drawio MCP configuration into an agent's MCP config file.
# Agent-agnostic — call from each agent's installer with its config path.
#
# Prefers the locally-built MCP server (engines/drawio-mcp-server/dist/index.js)
# to avoid GitHub/npm network dependency at runtime. Falls back to npx + npm
# registry if local build is missing.
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
read_drawio_version() {
  if command -v node &>/dev/null && [ -f "$TOOLKIT_DIR/engines.json" ]; then
    node -e 'try{process.stdout.write(require(process.argv[1]).engines.drawio.version)}catch(e){process.stdout.write("latest")}' \
      "$TOOLKIT_DIR/engines.json" 2>/dev/null || echo "latest"
  else
    echo "latest"
  fi
}

DRAWIO_VERSION="$(read_drawio_version)"
DRAWIO_LOCAL_ENTRY="$TOOLKIT_DIR/engines/drawio-mcp-server/dist/index.js"
DRAWIO_NPM_PACKAGE="@next-ai-drawio/mcp-server@${DRAWIO_VERSION}"

# ---- pick the right MCP server command ----
resolve_drawio_cmd() {
  if [ -f "$DRAWIO_LOCAL_ENTRY" ]; then
    # Use local build (no network needed at runtime)
    echo "node|$DRAWIO_LOCAL_ENTRY"
    return
  fi
  # Try to build it now if source is available
  if [ -f "$TOOLKIT_DIR/engines/drawio-mcp-server/build.sh" ]; then
    echo "⚠ $AGENT_LABEL: building local drawio MCP server..." >&2
    if bash "$TOOLKIT_DIR/engines/drawio-mcp-server/build.sh" >/dev/null 2>&1 && [ -f "$DRAWIO_LOCAL_ENTRY" ]; then
      echo "node|$DRAWIO_LOCAL_ENTRY"
      return
    fi
    echo "⚠ $AGENT_LABEL: local build failed, falling back to npm" >&2
  fi
  # Fallback to npx (requires network to fetch from npm)
  echo "npx|$DRAWIO_NPM_PACKAGE"
}

CMD_PIPE="$(resolve_drawio_cmd)"
DRAWIO_CMD="${CMD_PIPE%%|*}"
DRAWIO_ARG="${CMD_PIPE#*|}"

if [ "$DRAWIO_CMD" = "node" ]; then
  echo "ℹ $AGENT_LABEL: drawio MCP using local build → $DRAWIO_ARG"
else
  echo "ℹ $AGENT_LABEL: drawio MCP using npm fallback → $DRAWIO_ARG"
fi

# ---- merge drawio entry into an MCP config file ----
merge_drawio() {
  local cfg="$1" label="$2"

  mkdir -p "$(dirname "$cfg")"

  # Already configured? (compare against current install method)
  if [ -f "$cfg" ] && grep -q '"drawio"' "$cfg" 2>/dev/null; then
    echo "✔ $label: Drawio MCP already configured"
    return 0
  fi

  # Need node.js for JSON manipulation
  if ! command -v node &>/dev/null; then
    echo "⚠ $label: node.js not found — cannot configure Drawio MCP"
    return 1
  fi

  local tmp="${cfg}.tmp.$$"

  if [ ! -f "$cfg" ]; then
    # Create new config from scratch
    node -e "
      var o = {mcpServers:{drawio:{command:'$DRAWIO_CMD',args:['$DRAWIO_ARG']}}};
      require('fs').writeFileSync('$cfg', JSON.stringify(o,null,2)+'\n');
    " && echo "✔ $label: Drawio MCP configured (created $cfg)" && return 0
  fi

  # Merge into existing config
  node -e "
    var fs=require('fs'), cfg=JSON.parse(fs.readFileSync('$cfg','utf8'));
    cfg.mcpServers = cfg.mcpServers || {};
    cfg.mcpServers.drawio = {command:'$DRAWIO_CMD', args:['$DRAWIO_ARG']};
    fs.writeFileSync('$tmp', JSON.stringify(cfg,null,2)+'\n');
  " && mv "$tmp" "$cfg" && echo "✔ $label: Drawio MCP merged into $cfg" && return 0

  rm -f "$tmp"
  echo "⚠ $label: failed to merge Drawio MCP"
  return 1
}

merge_drawio "$CONFIG_FILE" "$AGENT_LABEL"