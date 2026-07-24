# tools/_lib.sh
# Shared helpers for engine / tool detection.
# Source this from tools/check.sh — do not invoke directly.
#
# Output philosophy: keep stdout TINY. Each helper prints at most one line.
# Anything verbose goes to a separate human-readable doc under tools/deps/.

# ---- platform ----
tool_platform() {
  case "$(uname -s 2>/dev/null)" in
    Darwin) echo macos ;;
    Linux)  echo linux ;;
    MINGW*|CYGWIN*|MSYS*) echo windows ;;
    *) echo unknown ;;
  esac
}

# ---- package manager probe (no output) ----
tool_has_brew()  { command -v brew >/dev/null 2>&1; }
tool_has_apt()   { command -v apt-get >/dev/null 2>&1; }
tool_has_yum()   { command -v yum >/dev/null 2>&1; }
tool_has_choco() { command -v choco >/dev/null 2>&1; }
tool_has_scoop() { command -v scoop >/dev/null 2>&1; }

# ---- single command check ----
tool_has_cmd() { command -v "$1" >/dev/null 2>&1; }

# ---- single python module check ----
tool_has_pymod() { python3 -c "import $1" >/dev/null 2>&1; }

# ---- compressed install ----
#   tool_install <logical-tool-name>
# Returns 0 on success, 1 on failure.
# Prints compact: "INSTALL :: <tool> :: <result>"
tool_install() {
  local tool="$1" plat
  plat=$(tool_platform)
  case "$tool:$plat" in
    brew:macos)        tool_has_brew && return 0 ;;
    python3:macos)     return 0 ;;   # shipped with macOS / cmd line tools
    python3:linux)     return 0 ;;
    python3:windows)   return 0 ;;
    git:macos)         tool_has_brew && brew install git >/dev/null 2>&1 ;;
    git:linux)         tool_has_apt  && sudo apt-get install -y git >/dev/null 2>&1 ;;
    node:macos)        tool_has_brew && brew install node >/dev/null 2>&1 ;;
    node:linux)        tool_has_apt  && sudo apt-get install -y nodejs npm >/dev/null 2>&1 ;;
    rsvg-convert:macos) tool_has_brew && brew install librsvg >/dev/null 2>&1 ;;
    rsvg-convert:linux)
      tool_has_apt && sudo apt-get install -y librsvg2-bin >/dev/null 2>&1 \
      || (tool_has_yum && sudo yum install -y librsvg2-tools >/dev/null 2>&1) ;;
    cairosvg:macos)    python3 -m pip install --quiet cairosvg >/dev/null 2>&1 ;;
    cairosvg:linux)    python3 -m pip install --quiet cairosvg >/dev/null 2>&1 ;;
    cairosvg:windows)  python3 -m pip install --quiet cairosvg >/dev/null 2>&1 ;;
    *)                 return 2 ;;
  esac
  tool_has_cmd "$tool" || tool_has_pymod "$tool" \
    || { command -v librsvg >/dev/null 2>&1; }   # rsvg-convert alias
}