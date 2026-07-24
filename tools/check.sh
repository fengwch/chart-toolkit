#!/usr/bin/env bash
# tools/check.sh — engine tool environment check / auto-install
#
# Usage:
#   bash tools/check.sh                  # check all engines (status only)
#   bash tools/check.sh fireworks        # check one engine
#   bash tools/check.sh fireworks --fix  # try to install missing
#   bash tools/check.sh --list           # list engines
#
# Output (compressed):
#   OK     :: <engine>
#   NEED   :: <engine> :: <tool[,tool]>
#   BAD    :: <engine> :: reason
#   FIXED  :: <engine>
#   MANUAL :: <engine> :: tools/deps/<tool>.md
#
# One line per engine. Designed for Agent context (small footprint).

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck disable=SC1091
. "$SCRIPT_DIR/_lib.sh"

# ---- engine tool definitions (additive) ----
# Each engine has a list of checks; each check returns missing tool or empty.
engines_def_fireworks() {
  local miss=""
  tool_has_cmd git || miss="${miss} git"
  tool_has_cmd node || miss="${miss} node"
  if tool_has_cmd python3; then
    if ! tool_has_pymod cairosvg && ! tool_has_cmd rsvg-convert; then
      miss="${miss} cairosvg|rsvg-convert"
    fi
  else
    miss="${miss} python3"
  fi
  echo "$miss" | tr -s ' '
}
engines_def_mermaid()      { echo ""; }      # rendered by the platform
engines_def_excalidraw()   { echo ""; }      # rendered by Obsidian / excalidraw.com
engines_def_canvas()       { echo ""; }      # rendered by Obsidian
engines_def_drawio()       {
  # Drawio MCP requires Node.js (npx) and config in mcp.json.
  local miss=""
  tool_has_cmd node || miss="${miss} node"
  # MCP config is mcp.json side-effect; check.sh just reports prereqs.
  echo "$miss" | tr -s ' '
}
engines_def_dataviz()      { echo ""; }      # built-in Skill, no external deps

# ---- per-engine status printer ----
report_engine() {
  local engine="$1" miss fix="$2"
  if [ -z "$miss" ]; then
    printf "OK     :: %s\n" "$engine"
    return 0
  fi
  printf "NEED   :: %s :: %s\n" "$engine" "$miss"
  return 1
}

# ---- single-engine --fix (one installation attempt) ----
fix_engine() {
  local engine="$1"
  case "$engine" in
    fireworks)
      local miss
      miss=$(engines_def_fireworks)
      [ -z "$miss" ] && { printf "OK     :: %s\n" "$engine"; return 0; }
      for t in $miss; do
        case "$t" in
          git|node)               tool_install "$t" ;;
          cairosvg)               tool_install cairosvg ;;
          rsvg-convert|cairosvg|rsvg-convert)
            tool_install cairosvg || tool_install rsvg-convert ;;
        esac
      done
      ;;
    drawio) tool_install node ;;
    *)      printf "MANUAL :: %s :: tools/deps/<tool>.md\n" "$engine" ;;
  esac
  miss=$(engines_def_$engine 2>/dev/null || echo "config")
  if [ -z "$miss" ] || [ "$miss" = "config" ]; then
    printf "FIXED  :: %s\n" "$engine"
  else
    printf "MANUAL :: %s :: tools/deps/<tool>.md\n" "$engine"
  fi
}

# ---- main ----
main() {
  local target="${1:-all}"
  shift || true
  local fix=""
  while [ $# -gt 0 ]; do
    case "$1" in
      --fix) fix=1 ;;
      *) err "unknown flag: $1" ;;
    esac
    shift
  done

  case "$target" in
    --list)
      printf "%s\n" fireworks mermaid excalidraw canvas drawio dataviz ;;
    --help|-h) sed -n '2,12p' "$0" ;;
    all)
      local rc=0
      for e in fireworks mermaid excalidraw canvas drawio dataviz; do
        if [ -n "$fix" ]; then fix_engine "$e" || rc=1; \
        else report_engine "$e" "$(engines_def_$e)" || rc=1; fi
      done
      exit $rc
      ;;
    fireworks|mermaid|excalidraw|canvas|drawio|dataviz)
      if [ -n "$fix" ]; then
        fix_engine "$target"
      else
        report_engine "$target" "$(engines_def_$target)"
      fi
      ;;
    *)
      printf "unknown engine: %s\n" "$target" >&2
      printf "run: bash %s --list\n" "$0"
      exit 2
      ;;
  esac
}

main "$@"