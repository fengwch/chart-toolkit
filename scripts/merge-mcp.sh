#!/usr/bin/env bash
# Merge Drawio MCP configuration into Claude Code / Codex MCP config
set -euo pipefail

DRAWIO_ENTRY='"drawio":{"command":"npx","args":["@next-ai-drawio/mcp-server@latest"]}'

merge_into() {
  local config_file="$1"
  local agent_name="$2"

  if [ ! -f "$config_file" ]; then
    echo "ℹ $agent_name: no mcp.json found at $config_file — creating..."
    mkdir -p "$(dirname "$config_file")"
    cat > "$config_file" <<EOF
{
  "mcpServers": {
    $DRAWIO_ENTRY
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

  # Robust merge: parse existing JSON, inject drawio entry, write back atomically
  if python3 -c "import json" 2>/dev/null; then
    local tmp_file="${config_file}.tmp.$$"
    if python3 <<PY - "$config_file" "$tmp_file"
import json, sys
config_path = sys.argv[1]
out_path = sys.argv[2]
with open(config_path, 'r') as f:
    data = json.load(f)
servers = data.setdefault('mcpServers', {})
servers['drawio'] = {'command': 'npx', 'args': ['@next-ai-drawio/mcp-server@latest']}
with open(out_path, 'w') as f:
    json.dump(data, f, indent=2)
    f.write('\n')
PY
    then
      mv "$tmp_file" "$config_file"
      echo "✔ $agent_name: Drawio MCP merged into $config_file"
      return
    else
      rm -f "$tmp_file"
      echo "⚠ $agent_name: failed to merge automatically"
    fi
  fi

  echo "⚠ $agent_name: Drawio MCP not found in config."
  echo "  Add manually to $config_file:"
  echo ""
  echo "  \"mcpServers\": {"
  echo "    $DRAWIO_ENTRY"
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