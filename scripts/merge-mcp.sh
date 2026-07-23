#!/usr/bin/env bash
# Merge Drawio MCP configuration into Claude Code / Codex MCP config
set -euo pipefail

DRAWIO_CONFIG='"drawio":{"command":"npx","args":["@next-ai-drawio/mcp-server@latest"]}'

merge_into() {
  local config_file="$1"
  local agent_name="$2"

  if [ ! -f "$config_file" ]; then
    echo "ℹ $agent_name: no mcp.json found at $config_file — creating..."
    mkdir -p "$(dirname "$config_file")"
    cat > "$config_file" <<EOF
{
  "mcpServers": {
    $DRAWIO_CONFIG
  }
}
EOF
    echo "✔ $agent_name: Drawio MCP configured"
    return
  fi

  if grep -q '"drawio"' "$config_file" 2>/dev/null; then
    echo "✔ $agent_name: Drawio MCP already configured"
    return
  fi

  # Simple merge: insert before the closing } of mcpServers
  # More robust merging left as future improvement
  echo "⚠ $agent_name: Drawio MCP not found in config."
  echo "  Add manually to $config_file:"
  echo ""
  echo "  \"mcpServers\": {"
  echo "    $DRAWIO_CONFIG"
  echo "  }"
  echo ""
}

echo "Checking Drawio MCP configuration..."
echo ""

merge_into "$HOME/.claude/mcp.json" "Claude Code"
merge_into "$HOME/.agents/mcp.json" "Codex"
# Hermes/Claw/QCoder paths to be added in v1.1

echo ""
echo "ℹ If Drawio MCP was not auto-configured, run manually:"
echo "  claude mcp add drawio -- npx @next-ai-drawio/mcp-server@latest"