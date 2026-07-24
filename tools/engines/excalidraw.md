# Engine: Excalidraw Diagram

Hand-drawn style. Generated JSON opened by Obsidian Excalidraw plugin OR excalidraw.com.

## Tool prereqs

**None for generation.** For viewing:

| Viewer | Prereq |
|---|---|
| Obsidian | Excalidraw plugin (Obsidian Community) |
| Browser | https://excalidraw.com (no install) |

## Check

```bash
bash tools/check.sh excalidraw
# OK     :: excalidraw     # always passes
```

## Notes

- Three output modes: Obsidian `.md` (default), Standard `.excalidraw`, Animated `.excalidraw`
- Text escaping: `"` → `『』`, `()` → `「」`
- Font family 5 (Excalifont)
