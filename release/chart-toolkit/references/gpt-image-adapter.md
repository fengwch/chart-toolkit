# GPT Image Gen Adapter

## Engine
`engines/gpt-image-gen/SKILL.md` — GPT Image generation via OpenAI API

## Capabilities
- AI-generated diagrams, charts, infographics, and visual content
- Natural language to image (text-to-image)
- Image editing with text instructions (image + prompt → new image)
- Multiple providers: OpenAI official, OpenAI-compatible proxies, AtlasCloud
- Configurable size, quality, and output format

## Output
- `.png` (default, lossless)
- `.jpeg` / `.webp` (compressed alternatives)
- Raster images only — no SVG/vector output

## Prerequisites
- Python 3.9+
- `openai` SDK (`pip install openai`)
- `Pillow` (`pip install Pillow`) — optional, for image processing
- `OPENAI_API_KEY` environment variable (or `.env` file in engine directory)
- Optional: `OPENAI_BASE_URL` for proxy/relay providers

## Configuration

Set up API access via environment variables or `.env` file:

```bash
# Option A: Environment variables
export OPENAI_API_KEY="sk-xxx"
export OPENAI_BASE_URL="https://your-proxy.com/v1"   # optional
export CODEX_PPT_IMAGE_MODEL="gpt-image-2"           # optional

# Option B: .env file at engines/gpt-image-gen/.env
# OPENAI_API_KEY=sk-xxx
# OPENAI_BASE_URL=https://your-proxy.com/v1
# CODEX_PPT_IMAGE_MODEL=gpt-image-2
```

## Execution

1. **Load the upstream skill**: Read `engines/gpt-image-gen/SKILL.md`
2. **Verify configuration**: Check `OPENAI_API_KEY` is set (see Configuration above)
3. **Generate the image**:
   ```bash
   python3 engines/gpt-image-gen/scripts/image_gen.py generate \
     --prompt "<detailed visual description>" \
     --size 1536x1024 \
     --quality medium \
     --out <output-path>.png \
     --force
   ```
4. **Report** the generated file path

## Prompt Engineering Tips

For best results, describe the visual in detail:
- Layout direction (left-to-right, top-down, radial)
- Component names and relationships
- Color scheme and style preferences
- Text labels to include
- Level of detail and abstraction

Example prompt:
```
A clean, professional microservices architecture diagram. API Gateway at the top
connects to Auth Service, User Service, and Order Service. Each service has its
own database. Redis cache sits between the gateway and services. Use a blue and
white color scheme with rounded rectangles for services and cylinders for databases.
Include directional arrows showing data flow.
```

## When to Use This Engine

- User wants AI-generated artistic/creative visuals
- Other engines (fireworks, mermaid) are unavailable or unsuitable
- User explicitly requests gpt-image / AI image generation
- Diagrams that benefit from natural, hand-drawn aesthetics
- Quick prototyping when precise SVG editing isn't needed

## When NOT to Use

- User needs editable SVG vector output → use fireworks
- User needs markdown-embedded diagrams → use mermaid
- User needs Obsidian canvas → use canvas
- User needs Drawio editable format → use drawio
- No `OPENAI_API_KEY` configured → guide user to configure or use alternative engine
