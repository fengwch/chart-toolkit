# `tools/` — engine environment management

The main `SKILL.md` should **not** contain platform-specific install commands for
individual tools (rsvg-convert, cairosvg, brew, choco, ...). All of that lives here.

This keeps the Agent context small — the toolkit can scan the system in one short
shell call and decide what to install.

## Layout

```
tools/
├── README.md                      ← this file
├── check.sh / check.ps1            ← main entry points
├── _lib.sh                         ← shared bash helpers
├── engines/                        ← per-engine "what tools do I need?"
│   ├── fireworks.md
│   ├── mermaid.md
│   ├── excalidraw.md
│   ├── canvas.md
│   ├── drawio.md
│   └── dataviz.md
└── deps/                           ← per-tool install instructions (human-readable)
    ├── rsvg-convert.md
    ├── cairosvg.md
    ├── git.md
    ├── node.md
    ├── python3.md
    ├── homebrew.md
    └── chocolatey.md
```

## Usage

```bash
# Quick scan — compressed output (Agent context-friendly)
bash tools/check.sh                 # all engines
bash tools/check.sh fireworks       # one engine
bash tools/check.sh --list

# Auto-fix when possible (macOS/Linux, sudo if needed)
bash tools/check.sh fireworks --fix

# Windows
powershell -File tools/check.ps1
powershell -File tools/check.ps1 fireworks -Fix
```

## Output format (compressed)

Each line tells the Agent exactly what to do next:

```
OK     :: <engine>                          # ready to draw
NEED   :: <engine> :: <tool[,tool]>         # missing deps
FIXED  :: <engine>                          # --fix succeeded
MANUAL :: <engine> :: tools/deps/<tool>.md  # auto-install failed, see doc
```

The Agent never needs to read the verbose `deps/<tool>.md` unless a manual step is required.

## Design rules

- **Keep main `SKILL.md` slim.** It only references `tools/check.sh` (or `tools\check.ps1`); it does NOT list any per-tool install commands.
- **`tools/check.sh` outputs at most one line per engine.** Status only.
- **`tools/deps/<tool>.md` is human-friendly, not Agent-facing.** Detailed prose is allowed here because humans read it on demand.
- **`setup.sh` and `setup.ps1` delegate** engine-env work to `tools/check.*` so the install logic lives in ONE place.
