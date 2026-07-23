#!/usr/bin/env bash
# Detect all installed Agents and install chart-toolkit for each
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
INSTALLED=0

echo "Detecting installed Agents..."

# Claude Code
if [ -d "$HOME/.claude" ]; then
  echo "  → Claude Code detected"
  bash "$SCRIPT_DIR/install-claude.sh"
  INSTALLED=$((INSTALLED + 1))
fi

# Codex
if [ -d "$HOME/.agents" ]; then
  echo "  → Codex detected"
  bash "$SCRIPT_DIR/install-codex.sh"
  INSTALLED=$((INSTALLED + 1))
fi

# Hermes (v1.1 pending)
if [ -d "$HOME/.hermes" ]; then
  echo "  → Hermes detected (integration coming in v1.1)"
fi

# Claw (v1.1 pending)
if [ -d "$HOME/.claw" ]; then
  echo "  → Claw detected (integration coming in v1.1)"
fi

# QCoder (v1.1 pending)
if [ -d "$HOME/.qcoder" ]; then
  echo "  → QCoder detected (integration coming in v1.1)"
fi

if [ $INSTALLED -eq 0 ]; then
  echo ""
  echo "⚠ No supported Agent detected."
  echo "Manual install: symlink or copy chart-toolkit/ to your Agent's skills directory."
  echo "Or use: @path/to/chart-toolkit/chart-toolkit.md in your Agent."
else
  echo ""
  echo "✔ Installed for $INSTALLED Agent(s). Restart your Agent to load chart-toolkit."
fi