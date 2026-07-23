#!/usr/bin/env bash
# Detect all installed Agents and install chart-toolkit for each
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
INSTALLED=0
FAILED=0

echo "Detecting installed Agents..."

# Claude Code
if [ -d "$HOME/.claude" ]; then
  echo "  → Claude Code detected"
  if bash "$SCRIPT_DIR/install-claude.sh"; then
    INSTALLED=$((INSTALLED + 1))
  else
    echo "  ✖ Claude Code install failed"
    FAILED=$((FAILED + 1))
  fi
fi

# Codex
if [ -d "$HOME/.agents" ]; then
  echo "  → Codex detected"
  if bash "$SCRIPT_DIR/install-codex.sh"; then
    INSTALLED=$((INSTALLED + 1))
  else
    echo "  ✖ Codex install failed"
    FAILED=$((FAILED + 1))
  fi
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

if [ $INSTALLED -eq 0 ] && [ $FAILED -eq 0 ]; then
  echo ""
  echo "⚠ No supported Agent detected."
  echo "Manual install: symlink or copy chart-toolkit/ to your Agent's skills directory."
  echo "Or use: @path/to/chart-toolkit/SKILL.md in your Agent."
  exit 0
fi

echo ""
if [ $FAILED -gt 0 ]; then
  echo "⚠ Installed for $INSTALLED Agent(s), $FAILED failed. Check errors above."
  exit 1
else
  echo "✔ Installed for $INSTALLED Agent(s). Restart your Agent to load chart-toolkit."
fi