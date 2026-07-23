#!/usr/bin/env bash
# Install chart-toolkit for OpenAI Codex CLI
# Creates a symlink from ~/.agents/skills/chart-toolkit → toolkit directory
set -euo pipefail

TOOLKIT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
CODEX_SKILLS="$HOME/.agents/skills"
TARGET="$CODEX_SKILLS/chart-toolkit"

mkdir -p "$CODEX_SKILLS"

if [ -L "$TARGET" ] || [ -d "$TARGET" ]; then
  echo "✔ Codex: chart-toolkit already linked at $TARGET"
else
  ln -s "$TOOLKIT_DIR" "$TARGET"
  echo "✔ Codex: linked $TARGET → $TOOLKIT_DIR"
fi

echo "Usage in Codex: say 'draw an architecture diagram' or '画一个架构图'"