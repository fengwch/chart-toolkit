# Engine: Dataviz (built-in Skill)

Data visualization design methodology. Built into Claude Code; nothing to install at the OS level.

## Tool prereqs

**None.** Method-driven (form heuristic + palette). Optional Python/Node toolchains apply only if the output medium requires code generation (e.g., matplotlib, Plotly).

## Check

```bash
bash tools/check.sh dataviz
# OK     :: dataviz     # always passes
```

## Notes

- Trigger the built-in `dataviz` Skill from the Agent session.
- Output medium options: HTML/React, inline SVG, PNG, Plotly / D3 / Recharts / Matplotlib code.
