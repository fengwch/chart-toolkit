# Chart Toolkit Setup — Windows PowerShell
# Usage: .\setup.ps1   or   iwr -useb <url> | iex

$ErrorActionPreference = "Stop"
$TOOLKIT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$FIRECRACKER_TAG = if ($env:FIRECRACKER_TAG) { $env:FIRECRACKER_TAG } else { "v1.0.4" }
$AXTON_TAG = if ($env:AXTON_TAG) { $env:AXTON_TAG } else { "main" }

Write-Host ""
Write-Host "╔══════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║      Chart Toolkit Setup (Windows)    ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Step 1: Check Prerequisites
Write-Host "Step 1/7: Checking prerequisites..." -ForegroundColor Cyan
$missing = @()
@("git", "python", "node") | ForEach-Object {
    if (Get-Command $_ -ErrorAction SilentlyContinue) {
        Write-Host "✔ $_ found" -ForegroundColor Green
    } else {
        Write-Host "⚠ $_ not found" -ForegroundColor Yellow
        $missing += $_
    }
}
if ($missing.Count -gt 0) {
    Write-Host "Missing: $($missing -join ', '). Please install manually." -ForegroundColor Red
    Write-Host "  git: https://git-scm.com/download/win"
    Write-Host "  python: https://www.python.org/downloads/"
    Write-Host "  node: https://nodejs.org/"
}

# Step 2: Install Python deps
Write-Host "Step 2/7: Installing Python dependencies..." -ForegroundColor Cyan
try {
    pip install cairosvg
    Write-Host "✔ cairosvg installed" -ForegroundColor Green
} catch {
    Write-Host "⚠ cairosvg install failed" -ForegroundColor Yellow
}

# Step 3: Clone Engines
Write-Host "Step 3/7: Cloning upstream engines..." -ForegroundColor Cyan
$ENGINES_DIR = Join-Path $TOOLKIT_DIR "engines"
New-Item -ItemType Directory -Force -Path $ENGINES_DIR | Out-Null

if (-not (Test-Path "$ENGINES_DIR/fireworks-tech-graph")) {
    git clone --depth 1 -b $FIRECRACKER_TAG https://github.com/yizhiyanhua-ai/fireworks-tech-graph.git "$ENGINES_DIR/fireworks-tech-graph"
    Write-Host "✔ fireworks-tech-graph cloned" -ForegroundColor Green
}

if (-not (Test-Path "$ENGINES_DIR/mermaid-visualizer")) {
    $TMP = Join-Path $env:TEMP "axton-$([Guid]::NewGuid())"
    git clone --depth 1 -b $AXTON_TAG https://github.com/axtonliu/axton-obsidian-visual-skills.git $TMP
    Copy-Item -Recurse "$TMP/mermaid-visualizer" "$ENGINES_DIR/"
    Copy-Item -Recurse "$TMP/excalidraw-diagram" "$ENGINES_DIR/"
    Copy-Item -Recurse "$TMP/obsidian-canvas-creator" "$ENGINES_DIR/canvas-creator"
    Remove-Item -Recurse -Force $TMP
    Write-Host "✔ axton engines cloned" -ForegroundColor Green
}

# Step 4: Link Agents
Write-Host "Step 4/7: Linking to detected Agents..." -ForegroundColor Cyan
$SKILLS_DIR = "$TOOLKIT_DIR"
if (Test-Path "$env:USERPROFILE/.claude/skills") {
    $target = "$env:USERPROFILE/.claude/skills/chart-toolkit"
    if (-not (Test-Path $target)) {
        New-Item -ItemType Junction -Path $target -Target $SKILLS_DIR -ErrorAction SilentlyContinue
        if (-not (Test-Path $target)) {
            Copy-Item -Recurse $SKILLS_DIR $target
        }
        Write-Host "✔ Linked to Claude Code" -ForegroundColor Green
    } else {
        Write-Host "✔ Claude Code link exists" -ForegroundColor Green
    }
}
if (Test-Path "$env:USERPROFILE/.agents/skills") {
    $target = "$env:USERPROFILE/.agents/skills/chart-toolkit"
    if (-not (Test-Path $target)) {
        New-Item -ItemType Junction -Path $target -Target $SKILLS_DIR -ErrorAction SilentlyContinue
        if (-not (Test-Path $target)) {
            Copy-Item -Recurse $SKILLS_DIR $target
        }
        Write-Host "✔ Linked to Codex" -ForegroundColor Green
    }
}

# Step 5: Drawio MCP
Write-Host "Step 5/7: Drawio MCP setup..." -ForegroundColor Cyan
Write-Host "ℹ To enable Drawio, run in terminal: claude mcp add drawio -- npx @next-ai-drawio/mcp-server@latest"

# Step 6: Doctor
Write-Host "Step 6/7: Running doctor check..." -ForegroundColor Cyan
$DOCTOR = Join-Path $TOOLKIT_DIR "scripts/doctor.ps1"
if (Test-Path $DOCTOR) {
    & $DOCTOR
}

# Step 7: Report
Write-Host ""
Write-Host "╔══════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║   Chart Toolkit Setup Complete!      ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "Toolkit location: $TOOLKIT_DIR"
Write-Host "Next: Restart your Agent and say 'Create a flowchart' or '画一个架构图'"