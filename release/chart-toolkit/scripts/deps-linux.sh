#!/usr/bin/env bash
# Install all dependencies on Linux (apt-based)
set -euo pipefail

echo "Installing Chart Toolkit dependencies for Linux (apt)..."
echo ""

sudo apt-get update -qq
sudo apt-get install -y git python3 python3-pip nodejs npm librsvg2-bin

pip3 install --upgrade pip
pip3 install cairosvg

echo ""
echo "✔ Linux dependencies ready."