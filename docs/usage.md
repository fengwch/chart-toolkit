# Usage Guide

## Basic Usage

Once installed, just describe what you want to draw. The toolkit handles the rest.

### Examples

```
画一个电商系统的微服务架构图
```

The toolkit will:
1. Analyze: domain=e-commerce, type=architecture, complexity=medium-high
2. Propose 3-5 chart types you can choose from
3. Ask clarifying questions (audience, components, style, etc.)
4. Generate SVG+PNG from the best engine

## Interactive Flow

Every request goes through 4 phases:

### Phase 1: Intent Analysis (automatic)
The toolkit silently analyzes your request to understand:
- What domain? (architecture, data flow, timeline, ...)
- What complexity? (simple, medium, complex)
- Who is the audience? (engineers, management, public)
- What's the output medium? (docs, slides, README, Obsidian)

### Phase 2: Chart Proposal (YOU choose)
The toolkit presents 3-5 chart type options. Each includes:
- Chart type name
- Recommended engine + style
- Output format
- Best-for description

You pick one or more (e.g., "A", "B+C", "A+D").

### Phase 3: Deep Interview (interactive)
4 deep questions tailored to your selection, then 4 standard questions.

### Phase 4: Generation (automatic)
The toolkit loads the right engine and generates your diagram.

## Trigger Words

The toolkit auto-activates on these keywords (Chinese and English):

| Chinese | English |
|---|---|
| 画图, 帮我画, 生成图, 做个图 | draw, create, generate, make |
| 架构图, 流程图, 思维导图 | architecture diagram, flowchart, mind map |
| 可视化, 可视化一下, 出图 | visualize, diagram, chart |
| 数据看板, 报表 | dashboard, data viz, report |
| 时序图, 类图, ER图 | sequence diagram, class diagram, ER |

## Picking the Right Tool (Manual)

If you know which engine you want, you can specify directly:

| Say this... | To use... |
|---|---|
| "用 fireworks 画..." | Fireworks Tech Graph (SVG+PNG) |
| "用 Mermaid 画..." | Mermaid (.md code block) |
| "用 Excalidraw 画..." | Excalidraw (hand-drawn) |
| "用 Canvas 做思维导图" | Obsidian Canvas (.canvas) |
| "用 Drawio 画..." | Drawio (browser editing) |
| "用 gpt-image 画..." / "AI 生成图片" | GPT Image (PNG/JPEG/WebP) |
| "做数据可视化" | Dataviz |

## Tips

1. **Be specific**: "电商微服务架构图" is better than "画图"
2. **Mention the audience**: "给老板看的" vs "技术文档用" → different styles
3. **Mention the output medium**: "放 README 里" → Mermaid; "放 PPT 里" → fireworks PNG
4. **You can combine**: "既是架构图又想要 Mermaid 代码块" → two engines run

## Troubleshooting

| Problem | Solution |
|---|---|
| "cairosvg not found" | `pip install cairosvg` or toolkit falls back to rsvg-convert |
| "Drawio MCP not available" | Run `claude mcp add drawio -- npx @next-ai-drawio/mcp-server@latest` |
| "Engine not found" | Run `./setup.sh` to clone engines |
| "Symbolic link failed" (Windows) | Run setup.ps1 (uses Junction or copy fallback) |
| Chart quality not good | Be more specific in Phase 3 interview; try a different style |
| "gpt-image: OPENAI_API_KEY not found" | Set `export OPENAI_API_KEY="sk-xxx"` or create `engines/gpt-image-gen/.env` |