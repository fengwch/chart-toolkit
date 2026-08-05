#!/usr/bin/env bash
# Install all dependencies on macOS
set -euo pipefail

echo "Installing Chart Toolkit dependencies for macOS..."
echo ""

# Homebrew
if ! command -v brew &>/dev/null; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# System packages
brew install git node librsvg 2>/dev/null || true

# Python packages
pip3 install --upgrade pip
pip3 install cairosvg

echo ""
echo "✔ macOS dependencies ready."