#!/usr/bin/env bash
# Install chart-toolkit for Claude Code
# Creates a symlink from ~/.claude/skills/chart-toolkit → toolkit directory
set -euo pipefail

TOOLKIT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
CLAUDE_SKILLS="$HOME/.claude/skills"
TARGET="$CLAUDE_SKILLS/chart-toolkit"

mkdir -p "$CLAUDE_SKILLS"

if [ -L "$TARGET" ]; then
  CURRENT_LINK="$(readlink "$TARGET" || true)"
  if [ "$CURRENT_LINK" = "$TOOLKIT_DIR" ]; then
    echo "✔ Claude Code: chart-toolkit already linked at $TARGET"
  else
    echo "⚠ Claude Code: existing link points elsewhere ($CURRENT_LINK). Replacing..."
    rm "$TARGET"
    ln -s "$TOOLKIT_DIR" "$TARGET"
    echo "✔ Claude Code: linked $TARGET → $TOOLKIT_DIR"
  fi
elif [ -d "$TARGET" ]; then
  echo "⚠ Claude Code: $TARGET already exists as a directory (not a symlink). Skipping."
else
  ln -s "$TOOLKIT_DIR" "$TARGET"
  echo "✔ Claude Code: linked $TARGET → $TOOLKIT_DIR"
fi

echo "Usage in Claude Code: just say '画一个架构图' or 'create a flowchart'"

# Drawio MCP
if [ -f "$TOOLKIT_DIR/scripts/merge-mcp.sh" ]; then
  bash "$TOOLKIT_DIR/scripts/merge-mcp.sh" "$HOME/.claude/mcp.json" "Claude Code"
fi