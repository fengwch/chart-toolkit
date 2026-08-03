# Dataviz Adapter

## Engine
Built-in Claude Code `dataviz` Skill — no upstream repo to clone.

## Capabilities
- Data visualization design system methodology
- Charts: bar, line, scatter, pie, heatmap, area, radar
- Dashboards: KPI cards, stat tiles, sparklines
- Interactive HTML, React components, inline SVG, PNG
- Dark/light mode compatible
- Library support: Plotly, D3, Recharts, Matplotlib

## Output
- HTML/React artifacts — interactive dashboards
- Inline SVG — for embedding
- PNG — via rendering
- Plotting code — matplotlib, plotly, d3, recharts

## Prerequisites
- None (methodology-based, not tool-dependent)
- If generating code: Python/Node.js per chosen library

## Execution

1. **Invoke the `dataviz` Skill** (built-in, no file to load)
2. **Apply its methodology**:
   - Form heuristic: automatically select chart type from data shape
   - Color formula: use the validated palette from `references/palette.md`
   - Mark specs: consistent legend, axis, tooltip rules
   - Dark mode: test readability in both themes
3. **Choose output medium** based on user's context:
   - For dashboards: interactive HTML
   - For embedding: inline SVG
   - For presentations: high-res PNG
   - For developers: code (matplotlib/plotly/d3/recharts)
4. **Generate** following the dataviz design system
5. **Report** output with viewing instructions

## When to Use This Adapter
- User mentions: chart, graph, plot, dashboard, analytics, KPI, metrics, statistics
- User has numerical data to visualize
- NOT for: architecture diagrams, flowcharts, mind maps (route to other adapters)