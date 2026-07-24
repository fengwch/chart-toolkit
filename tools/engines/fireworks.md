# Engine: fireworks (Fireworks Tech Graph)

SVG + PNG technical diagrams. Loaded from engines/fireworks-tech-graph/.

## Tool prereqs (auto-checked by `tools/check.sh`)

| Tool | Why | Check |
|---|---|---|
| `git` | clone upstream repos | `git --version` |
| `node` | used by some fallback renderers | `node --version` |
| `python3` + `cairosvg` (preferred) OR `rsvg-convert` (fallback) | SVG→PNG export | `python3 -c "import cairosvg"` / `rsvg-convert --version` |

## Check

```bash
bash tools/check.sh fireworks
# OK     :: fireworks       # all present
# NEED   :: fireworks :: cairosvg rsvg-convert   # one of these required
```

## Auto-install

```bash
bash tools/check.sh fireworks --fix
```

If auto-install fails, see `tools/deps/<tool>.md` for the manual OS-specific command.

## Notes

- Output path: `<topic>-diagram.svg` + `<topic>-diagram.png`
- Style 1–7 reference sheets live in `engines/fireworks-tech-graph/references/style-*-*.md`
