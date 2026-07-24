#!/usr/bin/env bash
# Install chart-toolkit for OpenAI Codex CLI
# Creates a symlink from ~/.agents/skills/chart-toolkit → toolkit directory
set -euo pipefail

TOOLKIT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
CODEX_SKILLS="$HOME/.agents/skills"
TARGET="$CODEX_SKILLS/chart-toolkit"

mkdir -p "$CODEX_SKILLS"

if [ -L "$TARGET" ]; then
  CURRENT_LINK="$(readlink "$TARGET" || true)"
  if [ "$CURRENT_LINK" = "$TOOLKIT_DIR" ]; then
    echo "✔ Codex: chart-toolkit already linked at $TARGET"
  else
    echo "⚠ Codex: existing link points elsewhere ($CURRENT_LINK). Replacing..."
    rm "$TARGET"
    ln -s "$TOOLKIT_DIR" "$TARGET"
    echo "✔ Codex: linked $TARGET → $TOOLKIT_DIR"
  fi
elif [ -d "$TARGET" ]; then
  echo "⚠ Codex: $TARGET already exists as a directory (not a symlink). Skipping."
else
  ln -s "$TOOLKIT_DIR" "$TARGET"
  echo "✔ Codex: linked $TARGET → $TOOLKIT_DIR"
fi

echo "Usage in Codex: say 'draw an architecture diagram' or '画一个架构图'"

# Drawio MCP
if [ -f "$TOOLKIT_DIR/scripts/merge-mcp.sh" ]; then
  bash "$TOOLKIT_DIR/scripts/merge-mcp.sh" "$HOME/.agents/mcp.json" "Codex"
fi