# Installation Guide

## Prerequisites

- **git** (for cloning engines)
- **Python 3.9+** (for fireworks SVG→PNG conversion)
- **Node.js 18+** (for Drawio MCP, optional)
- **pip** (for cairosvg)

## Platform-Specific

### macOS

```bash
# Install prerequisites
brew install git python3 node librsvg

# Install chart-toolkit
git clone https://github.com/<org>/chart-toolkit.git
cd chart-toolkit
./setup.sh
```

### Linux (Ubuntu/Debian)

```bash
sudo apt-get update
sudo apt-get install -y git python3 python3-pip nodejs npm librsvg2-bin

git clone https://github.com/<org>/chart-toolkit.git
cd chart-toolkit
./setup.sh
```

### Windows

**Option A: PowerShell**
```powershell
git clone https://github.com/<org>/chart-toolkit.git
cd chart-toolkit
.\setup.ps1
```

**Option B: Git Bash / WSL**
```bash
git clone https://github.com/<org>/chart-toolkit.git
cd chart-toolkit
./setup.sh
```

## What setup.sh Does

1. Detects platform (macOS/Linux)
2. Checks prerequisites (git, python3, node)
3. Installs missing dependencies (cairosvg, rsvg-convert)
4. Clones 4 upstream engines into `engines/`
5. Creates symlinks in your Agent's skills directory
6. Checks/Merges Drawio MCP configuration
7. Runs doctor check
8. Prints success report

## gpt-image Engine (Optional)

The `gpt-image-gen` engine generates images using OpenAI's GPT Image API (gpt-image-2). This is a separate setup step — no extra dependencies beyond `openai` SDK:

### Setup

```bash
# 1. Install Python dependencies
pip install -r engines/gpt-image-gen/requirements.txt

# 2. Set API key (choose one)

# Option A: Environment variable
export OPENAI_API_KEY="sk-xxx"
export OPENAI_BASE_URL="https://your-proxy.com/v1"   # optional
export CODEX_PPT_IMAGE_MODEL="gpt-image-2"           # optional

# Option B: .env file
cat > engines/gpt-image-gen/.env << 'EOF'
OPENAI_API_KEY=sk-xxx
OPENAI_BASE_URL=https://your-proxy.com/v1
CODEX_PPT_IMAGE_MODEL=gpt-image-2
EOF
```

### Test

```bash
python3 engines/gpt-image-gen/scripts/image_gen.py generate \
  --prompt "A clean system architecture diagram with API gateway and microservices" \
  --size 1536x1024 \
  --out test-diagram.png
```

## Manual Install (Any Agent)

If your Agent doesn't have auto-detection:

1. Clone the repo anywhere
2. Symlink or copy `chart-toolkit/` to your Agent's skills directory
3. Or reference directly: `@/path/to/chart-toolkit/SKILL.md`

## Verifying Installation

```bash
./scripts/doctor.sh
```

Expected output: all green checkmarks (✔) for installed components.

## Updating

```bash
cd chart-toolkit
./setup.sh  # Re-runs engine clone and dependency checks
```

To update individual engines:
```bash
cd engines/fireworks-tech-graph && git pull
```

## Uninstalling

```bash
# Remove symlinks
rm ~/.claude/skills/chart-toolkit
rm ~/.agents/skills/chart-toolkit

# Remove toolkit directory
rm -rf /path/to/chart-toolkit
```