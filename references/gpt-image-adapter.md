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

### Check Before Use

**Before generating**, the agent MUST verify `OPENAI_API_KEY` is available. Check in this order:

1. **Process environment variable** — `echo "$OPENAI_API_KEY"` (or `$env:OPENAI_API_KEY` on Windows)
2. **`.env` file** — read `engines/gpt-image-gen/.env` if it exists

If **both** are missing, **STOP and tell the user**. Do NOT proceed to generation. Provide the configuration options below and ask the user to provide the key via that channel.

Example interrupt message:

> ⚠ `OPENAI_API_KEY` is not configured. The gpt-image engine cannot generate images without an API key.
>
> Please set it via one of:
> - Environment variable: `export OPENAI_API_KEY="sk-xxx"`
> - `.env` file at `engines/gpt-image-gen/.env`:
>   ```
>   OPENAI_API_KEY=sk-xxx
>   OPENAI_BASE_URL=https://your-proxy.com/v1   # optional
>   CODEX_PPT_IMAGE_MODEL=gpt-image-2            # optional
>   ```
>
> After configuring, please confirm and I'll continue.

### Configuration Options

```bash
# Option A: Environment variables
export OPENAI_API_KEY="sk-xxx"
export OPENAI_BASE_URL="https://your-proxy.com/v1"   # optional, for proxy/relay
export CODEX_PPT_IMAGE_MODEL="gpt-image-2"           # optional

# Option B: .env file at engines/gpt-image-gen/.env
# OPENAI_API_KEY=sk-xxx
# OPENAI_BASE_URL=https://your-proxy.com/v1
# CODEX_PPT_IMAGE_MODEL=gpt-image-2
```

Note: **Environment variable takes precedence** over `.env` file. The CLI loads `.env` only if the env var is not already set.

## Execution

1. **Load the upstream skill**: Read `engines/gpt-image-gen/SKILL.md`
2. **Verify configuration** (see Check Before Use above) — stop and ask if `OPENAI_API_KEY` is missing
3. **Generate the image**:
   ```bash
   # image_gen.py lives in the **full release package** under
   # engines/gpt-image-gen/scripts/ — omitted in -secure builds.
   # Download: https://github.com/fengwch/chart-toolkit/releases
   # With the full release:
   #   python3 engines/gpt-image-gen/scripts/image_gen.py generate \
   #     --prompt "<detailed visual description>" \
   #     --size 1536x1024 \
   #     --quality medium \
   #     --out <output-path>.png \
   #     --force
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
