# Engine: Mermaid

Code-fenced markdown rendered natively by GitHub / GitLab / Obsidian / Notion.

## Tool prereqs

**None.** Mermaid is rendered by the viewing platform (Obsidian's Mermaid plugin, GitHub's content pipeline, etc.). The output `.md` file IS the diagram.

## Check

```bash
bash tools/check.sh mermaid
# OK     :: mermaid     # always passes
```

## Notes

- Output path: `<topic>.mermaid.md` with ```mermaid code fence
- Critical syntax rules in `engines/mermaid-visualizer/SKILL.md`
