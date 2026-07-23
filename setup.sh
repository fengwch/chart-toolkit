#!/usr/bin/env bash
set -euo pipefail

# ─── Chart Toolkit Setup ───
# One-command installer for macOS and Linux.
# Usage: ./setup.sh   or   curl -fsSL <url> | bash

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'
TOOLKIT_DIR="$(cd "$(dirname "$0")" && pwd)"
FIRECRACKER_TAG="${FIRECRACKER_TAG:-v1.0.4}"
AXTON_TAG="${AXTON_TAG:-main}"

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

# Fireworks Tech Graph
if [ ! -d "$ENGINES_DIR/fireworks-tech-graph/.git" ]; then
  info "Cloning fireworks-tech-graph@$FIRECRACKER_TAG..."
  rm -rf "$ENGINES_DIR/fireworks-tech-graph"
  git clone --depth 1 -b "$FIRECRACKER_TAG" \
    https://github.com/yizhiyanhua-ai/fireworks-tech-graph.git \
    "$ENGINES_DIR/fireworks-tech-graph" 2>/dev/null || \
    git clone --depth 1 \
    https://github.com/yizhiyanhua-ai/fireworks-tech-graph.git \
    "$ENGINES_DIR/fireworks-tech-graph"
  log "fireworks-tech-graph cloned"
else
  log "fireworks-tech-graph already exists (skipping)"
fi

# Axton Obsidian Visual Skills (extract subdirectories)
if [ ! -d "$ENGINES_DIR/mermaid-visualizer/.git" ]; then
  info "Cloning axton-obsidian-visual-skills@$AXTON_TAG..."
  TMP_AXTON=$(mktemp -d)
  rm -rf "$ENGINES_DIR/mermaid-visualizer" "$ENGINES_DIR/excalidraw-diagram" "$ENGINES_DIR/canvas-creator"
  git clone --depth 1 -b "$AXTON_TAG" \
    https://github.com/axtonliu/axton-obsidian-visual-skills.git \
    "$TMP_AXTON" 2>/dev/null

  # Verify expected subdirectories exist before copying
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

# ─── Step 5: Link to Agents ───
info "Step 5/8: Linking to detected Agents..."
if [ -f "$TOOLKIT_DIR/agents/install-all.sh" ]; then
  bash "$TOOLKIT_DIR/agents/install-all.sh"
else
  warn "agents/install-all.sh not found"
fi

# ─── Step 6: Merge MCP Configuration ───
info "Step 6/8: Checking Drawio MCP configuration..."
if [ -f "$TOOLKIT_DIR/scripts/merge-mcp.sh" ]; then
  bash "$TOOLKIT_DIR/scripts/merge-mcp.sh"
else
  warn "scripts/merge-mcp.sh not found — run 'claude mcp add drawio -- npx @next-ai-drawio/mcp-server@latest' manually"
fi

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