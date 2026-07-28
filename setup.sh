#!/usr/bin/env bash
set -euo pipefail

# ─── Chart Toolkit Setup ───
# One-command installer for macOS and Linux.
# Usage: ./setup.sh   or   curl -fsSL <url> | bash

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'
TOOLKIT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Load engine versions from config (engines.json), with env-var overrides
_load_version() {
  local engine="$1" field="$2" env_var="$3" default="$4"
  if [ -n "${!env_var:-}" ]; then
    echo "${!env_var}"
  elif command -v python3 &>/dev/null && [ -f "$TOOLKIT_DIR/engines.json" ]; then
    python3 -c "import json,sys; v=json.load(open('$TOOLKIT_DIR/engines.json')); print(v['engines']['$engine']['$field'])" 2>/dev/null || echo "$default"
  else
    echo "$default"
  fi
}

FIRECRACKER_TAG=$(_load_version "fireworks-tech-graph" "tag" "FIRECRACKER_TAG" "v1.0.4")
AXTON_TAG=$(_load_version "axton-visual-skills" "tag" "AXTON_TAG" "main")
DRAWIO_TAG=$(_load_version "drawio" "version" "DRAWIO_TAG" "0.2.3")
FIREWORKS_REPO=$(_load_version "fireworks-tech-graph" "repo" "FIREWORKS_REPO" "")
FIREWORKS_FALLBACK=$(_load_version "fireworks-tech-graph" "fallback" "FIREWORKS_FALLBACK" "")
AXTON_REPO=$(_load_version "axton-visual-skills" "repo" "AXTON_REPO" "")
AXTON_FALLBACK=$(_load_version "axton-visual-skills" "fallback" "AXTON_FALLBACK" "")
DRAWIO_BUILD_CMD=$(_load_version "drawio" "build_command" "DRAWIO_BUILD_CMD" "bash engines/drawio-mcp-server/build.sh")

log()  { printf "${GREEN}✔${NC} %s\n" "$1"; }
warn() { printf "${YELLOW}⚠${NC} %s\n" "$1"; }
err()  { printf "${RED}✖${NC} %s\n" "$1"; exit 1; }
info() { printf "${CYAN}ℹ${NC} %s\n" "$1"; }

header() {
  echo ""
  printf "${CYAN}╔══════════════════════════════════════╗${NC}\n"
  printf "${CYAN}║      Chart Toolkit Setup             ║${NC}\n"
  printf "${CYAN}╚══════════════════════════════════════╝${NC}\n"
  echo ""
}

header

# ─── Step 1: Detect Platform ───
info "Step 1/8: Detecting platform..."
case "$(uname -s)" in
  Darwin)  PLATFORM="macos" ;;
  Linux)   PLATFORM="linux" ;;
  *)       err "Unsupported platform: $(uname -s)" ;;
esac
log "Platform: $PLATFORM"

# ─── Step 2: Check Prerequisites ───
info "Step 2/8: Checking prerequisites..."
for cmd in git python3 node; do
  if command -v "$cmd" &>/dev/null; then
    log "$cmd found: $(command -v $cmd)"
  else
    warn "$cmd not found — will attempt to install"
  fi
done

# ─── Step 3: Install System Dependencies ───
info "Step 3/8: Installing system dependencies..."
if [ "$PLATFORM" = "macos" ]; then
  if ! command -v brew &>/dev/null; then
    warn "Homebrew not found. Install from https://brew.sh"
  else
    command -v git &>/dev/null || brew install git
    command -v node &>/dev/null || brew install node
  fi
  # cairosvg
  if ! python3 -c "import cairosvg" 2>/dev/null; then
    info "Installing cairosvg..."
    pip3 install cairosvg || warn "cairosvg install failed; rsvg-convert will be used as fallback"
  else
    log "cairosvg already installed"
  fi
  # rsvg-convert (fallback)
  if ! command -v rsvg-convert &>/dev/null; then
    info "Installing librsvg (rsvg-convert)..."
    brew install librsvg || warn "librsvg install failed"
  else
    log "rsvg-convert already installed"
  fi
elif [ "$PLATFORM" = "linux" ]; then
  if command -v apt-get &>/dev/null; then
    sudo apt-get update -qq
    command -v git &>/dev/null || sudo apt-get install -y git
    command -v node &>/dev/null || sudo apt-get install -y nodejs npm
    command -v rsvg-convert &>/dev/null || sudo apt-get install -y librsvg2-bin
    python3 -c "import cairosvg" 2>/dev/null || pip3 install cairosvg
  elif command -v yum &>/dev/null; then
    sudo yum install -y git nodejs librsvg2-tools
    python3 -c "import cairosvg" 2>/dev/null || pip3 install cairosvg
  else
    warn "No supported package manager found. Install git, node, python3, and cairosvg manually."
  fi
fi
log "Dependencies installed"

# ─── Step 4: Clone Engines ───
info "Step 4/8: Cloning upstream engines..."
ENGINES_DIR="$TOOLKIT_DIR/engines"
mkdir -p "$ENGINES_DIR"

# Network sanity check
if ! curl -fsSL -I https://github.com >/dev/null 2>&1; then
  warn "No internet connection detected. Engine cloning may fail."
fi

# Helper: clone with fallback (mirror first, then original upstream)
_clone_engine() {
  local name="$1" primary="$2" fallback="$3" tag="$4" dest="$5"
  info "Cloning $name@$tag..."
  rm -rf "$dest"
  if [ -n "$primary" ] && git clone --depth 1 -b "$tag" "$primary" "$dest" 2>/dev/null; then
    return 0
  elif [ -n "$fallback" ] && git clone --depth 1 -b "$tag" "$fallback" "$dest" 2>/dev/null; then
    return 0
  elif [ -n "$primary" ] && git clone --depth 1 "$primary" "$dest" 2>/dev/null; then
    return 0
  elif [ -n "$fallback" ] && git clone --depth 1 "$fallback" "$dest" 2>/dev/null; then
    return 0
  else
    err "Failed to clone $name (tried mirror and fallback)"
  fi
}

# Fireworks Tech Graph
if [ ! -d "$ENGINES_DIR/fireworks-tech-graph/.git" ]; then
  _clone_engine "fireworks-tech-graph" \
    "$FIREWORKS_REPO" "$FIREWORKS_FALLBACK" \
    "$FIRECRACKER_TAG" "$ENGINES_DIR/fireworks-tech-graph"
  log "fireworks-tech-graph cloned"
else
  log "fireworks-tech-graph already exists (skipping)"
fi

# Axton Obsidian Visual Skills (extract subdirectories)
if [ ! -d "$ENGINES_DIR/mermaid-visualizer/.git" ]; then
  TMP_AXTON=$(mktemp -d)
  rm -rf "$ENGINES_DIR/mermaid-visualizer" "$ENGINES_DIR/excalidraw-diagram" "$ENGINES_DIR/canvas-creator"
  _clone_engine "axton-visual-skills" \
    "$AXTON_REPO" "$AXTON_FALLBACK" \
    "$AXTON_TAG" "$TMP_AXTON"

  for subdir in mermaid-visualizer excalidraw-diagram obsidian-canvas-creator; do
    if [ ! -d "$TMP_AXTON/$subdir" ]; then
      err "Expected subdirectory '$subdir' not found in axton-obsidian-visual-skills repo"
    fi
  done

  cp -r "$TMP_AXTON/mermaid-visualizer" "$ENGINES_DIR/"
  cp -r "$TMP_AXTON/excalidraw-diagram" "$ENGINES_DIR/"
  cp -r "$TMP_AXTON/obsidian-canvas-creator" "$ENGINES_DIR/canvas-creator"
  rm -rf "$TMP_AXTON"
  log "mermaid-visualizer, excalidraw-diagram, canvas-creator cloned"
else
  log "axton engines already exist (skipping)"
fi

# Build vendored drawio MCP server (avoids GitHub/npm network dependency)
DRAWIO_MCP_DIR="$ENGINES_DIR/../engines/drawio-mcp-server"
if [ -d "$DRAWIO_MCP_DIR" ] && [ ! -f "$DRAWIO_MCP_DIR/dist/index.js" ]; then
  info "Building drawio MCP server (from local source)..."
  if bash "$DRAWIO_MCP_DIR/build.sh"; then
    log "drawio MCP server built"
  else
    warn "drawio MCP build failed — will use npx fallback"
  fi
elif [ -f "$DRAWIO_MCP_DIR/dist/index.js" ]; then
  log "drawio MCP server already built (skipping)"
fi

# ─── Step 5: Link to Agents ───
info "Step 5/8: Linking to detected Agents..."
if [ -f "$TOOLKIT_DIR/agents/install-all.sh" ]; then
  bash "$TOOLKIT_DIR/agents/install-all.sh"
else
  warn "agents/install-all.sh not found"
fi

# ─── Step 6: Merge MCP Configuration ───
# Drawio MCP is configured per-agent by agents/install-*.sh (called in Step 5).
# To configure manually for an agent: scripts/merge-mcp.sh <mcp_config_path> <label>
info "Step 6/8: Drawio MCP configured by agent installers (see Step 5)"

# ─── Step 7: Verify ───
info "Step 7/8: Running doctor check..."
if [ -f "$TOOLKIT_DIR/scripts/doctor.sh" ]; then
  bash "$TOOLKIT_DIR/scripts/doctor.sh"
else
  warn "scripts/doctor.sh not found"
fi

# ─── Step 8: Report ───
echo ""
printf "${GREEN}╔══════════════════════════════════════╗${NC}\n"
printf "${GREEN}║   Chart Toolkit Setup Complete!      ║${NC}\n"
printf "${GREEN}╚══════════════════════════════════════╝${NC}\n"
echo ""
echo "What's next:"
echo "  1. Restart your Agent (Claude Code / Codex)"
echo "  2. Say: '画一个系统架构图' or 'Create a flowchart'"
echo "  3. The toolkit will guide you interactively"
echo ""
echo "Toolkit location: $TOOLKIT_DIR"
echo "Installed engines:"
for engine in "$ENGINES_DIR"/*/; do
  [ -d "$engine" ] && echo "  - $(basename "$engine")"
done
echo ""
echo "To update engines later: ./setup.sh"
echo ""