#!/usr/bin/env bash
# Doctor — check all dependencies and report status
set -euo pipefail

GREEN='\033[0;32m'; RED='\033[0;31m'; YELLOW='\033[1;33m'; NC='\033[0m'
PASS=0; FAIL=0; WARN=0

check_cmd() {
  if command -v "$1" &>/dev/null; then
    printf "${GREEN}✔${NC} %-25s %s\n" "$1" "$(command -v "$1")"
    PASS=$((PASS + 1))
  else
    printf "${RED}✖${NC} %-25s not found\n" "$1"
    FAIL=$((FAIL + 1))
  fi
}

check_python_mod() {
  if python3 -c "import $1" 2>/dev/null; then
    printf "${GREEN}✔${NC} %-25s installed\n" "python:$1"
    PASS=$((PASS + 1))
  else
    printf "${YELLOW}⚠${NC} %-25s not installed (pip install $1)\n" "python:$1"
    WARN=$((WARN + 1))
  fi
}

check_dir() {
  if [ -d "$1" ]; then
    printf "${GREEN}✔${NC} %-25s exists\n" "$(basename "$1")"
    PASS=$((PASS + 1))
  else
    printf "${YELLOW}⚠${NC} %-25s missing (run setup.sh)\n" "$(basename "$1")"
    WARN=$((WARN + 1))
  fi
}

echo ""
echo "Chart Toolkit Doctor"
echo "===================="
echo ""
echo "—— System ——"
check_cmd git
check_cmd python3
check_cmd node
check_cmd npx

echo ""
echo "—— Python ——"
check_python_mod cairosvg

echo ""
echo "—— SVG → PNG ——"
if command -v cairosvg &>/dev/null || python3 -c "import cairosvg" 2>/dev/null; then
  printf "${GREEN}✔${NC} %-25s available\n" "cairosvg (preferred)"
elif command -v rsvg-convert &>/dev/null; then
  printf "${GREEN}✔${NC} %-25s %s\n" "rsvg-convert" "$(command -v rsvg-convert)"
else
  printf "${YELLOW}⚠${NC} %-25s neither cairosvg nor rsvg-convert found\n" "SVG→PNG"
  WARN=$((WARN + 1))
fi

echo ""
echo "—— Engines ——"
TOOLKIT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
check_dir "$TOOLKIT_DIR/engines/fireworks-tech-graph"
check_dir "$TOOLKIT_DIR/engines/mermaid-visualizer"
check_dir "$TOOLKIT_DIR/engines/excalidraw-diagram"
check_dir "$TOOLKIT_DIR/engines/canvas-creator"

echo ""
echo "—— Agent Links ——"
[ -L "$HOME/.claude/skills/chart-toolkit" ] && printf "${GREEN}✔${NC} %-25s linked\n" "Claude Code" && PASS=$((PASS + 1)) || printf "${YELLOW}⚠${NC} %-25s not linked\n" "Claude Code"
[ -L "$HOME/.agents/skills/chart-toolkit" ] && printf "${GREEN}✔${NC} %-25s linked\n" "Codex" && PASS=$((PASS + 1)) || printf "${YELLOW}⚠${NC} %-25s not linked\n" "Codex"

echo ""
echo "—— MCP (Drawio) ——"
# Check common MCP config locations
MCP_FOUND=0
for f in "$HOME/.claude/mcp.json" "$HOME/.claude/.mcp.json" "$HOME/.cursor/mcp.json"; do
  if [ -f "$f" ] && grep -q "drawio\|@next-ai-drawio" "$f" 2>/dev/null; then
    printf "${GREEN}✔${NC} %-25s configured in %s\n" "Drawio MCP" "$f"
    MCP_FOUND=1
    break
  fi
done
[ $MCP_FOUND -eq 0 ] && printf "${YELLOW}⚠${NC} %-25s not configured (run: claude mcp add drawio -- npx @next-ai-drawio/mcp-server@latest)\n" "Drawio MCP"

echo ""
echo "─────────────────────────"
printf "Results: ${GREEN}%d pass${NC}, ${YELLOW}%d warn${NC}, ${RED}%d fail${NC}\n" $PASS $WARN $FAIL
echo ""