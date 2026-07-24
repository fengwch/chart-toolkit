#!/usr/bin/env bash
# Install chart-toolkit for TeleAgent
# Creates a symlink from ~/.config/TeleAgent/skills/chart-toolkit → toolkit directory
set -euo pipefail

TOOLKIT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TA_CONFIG="$HOME/.config/TeleAgent"
TA_SKILLS="$TA_CONFIG/skills"
TARGET="$TA_SKILLS/chart-toolkit"

mkdir -p "$TA_SKILLS"

if [ -L "$TARGET" ]; then
  CURRENT_LINK="$(readlink "$TARGET" || true)"
  if [ "$CURRENT_LINK" = "$TOOLKIT_DIR" ]; then
    echo "✔ TeleAgent: chart-toolkit already linked at $TARGET"
  else
    echo "⚠ TeleAgent: existing link points elsewhere ($CURRENT_LINK). Replacing..."
    rm "$TARGET"
    ln -s "$TOOLKIT_DIR" "$TARGET"
    echo "✔ TeleAgent: linked $TARGET → $TOOLKIT_DIR"
  fi
elif [ -d "$TARGET" ]; then
  echo "⚠ TeleAgent: $TARGET already exists as a directory (not a symlink). Skipping."
else
  ln -s "$TOOLKIT_DIR" "$TARGET"
  echo "✔ TeleAgent: linked $TARGET → $TOOLKIT_DIR"
fi

echo "Usage in TeleAgent: just say '画一个架构图' or 'create a flowchart'"

# Drawio MCP
if [ -f "$TOOLKIT_DIR/scripts/merge-mcp.sh" ]; then
  bash "$TOOLKIT_DIR/scripts/merge-mcp.sh" "$TA_CONFIG/mcp.json" "TeleAgent"
fi
