#!/usr/bin/env bash
# Build the vendored drawio MCP server.
# Outputs to engines/drawio-mcp-server/dist/index.js
# Run from chart-toolkit root: bash engines/drawio-mcp-server/build.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

# Check node
if ! command -v node &>/dev/null; then
  echo "✖ node.js not found — install from https://nodejs.org/" >&2
  exit 1
fi
NODE_MAJOR=$(node -v | sed 's/v\([0-9]*\)\..*/\1/')
if [ "$NODE_MAJOR" -lt 18 ]; then
  echo "✖ node.js ≥18 required (found $(node -v))" >&2
  exit 1
fi

# Install deps if needed
if [ ! -d node_modules ]; then
  echo "Installing drawio MCP server dependencies..."
  npm install --omit=dev --no-audit --no-fund 2>&1 | tail -5
fi

# Build
echo "Building drawio MCP server..."
npm run build 2>&1 | tail -10

if [ -f dist/index.js ]; then
  echo "✔ Built: dist/index.js ($(du -h dist/index.js | cut -f1))"
else
  echo "✖ Build failed — dist/index.js not found" >&2
  exit 1
fi