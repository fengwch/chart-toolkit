# Chart Toolkit Setup — Windows PowerShell
# Usage: .\setup.ps1   or   iwr -useb <url> | iex

$ErrorActionPreference = "Stop"
$TOOLKIT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path

# Load engine versions from config (engines.json), with env-var overrides
function Load-EngineConfig {
    param([string]$Engine, [string]$Field, [string]$EnvVar, [string]$Default)
    if (Test-Path env:$EnvVar) { return (Get-Item env:$EnvVar).Value }
    $configPath = Join-Path $TOOLKIT_DIR "engines.json"
    if (Test-Path $configPath) {
        try {
            $config = Get-Content $configPath -Raw | ConvertFrom-Json
            $val = $config.engines.$Engine.$Field
            if ($val) { return $val }
        } catch {}
    }
    return $Default
}

$FIRECRACKER_TAG = Load-EngineConfig "fireworks-tech-graph" "tag" "FIRECRACKER_TAG" "v1.0.4"
$AXTON_TAG      = Load-EngineConfig "axton-visual-skills" "tag" "AXTON_TAG" "main"
$FIREWORKS_REPO    = Load-EngineConfig "fireworks-tech-graph" "repo" "FIREWORKS_REPO" ""
$FIREWORKS_FALLBACK = Load-EngineConfig "fireworks-tech-graph" "fallback" "FIREWORKS_FALLBACK" ""
$AXTON_REPO    = Load-EngineConfig "axton-visual-skills" "repo" "AXTON_REPO" ""
$AXTON_FALLBACK = Load-EngineConfig "axton-visual-skills" "fallback" "AXTON_FALLBACK" ""

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

function Clone-Engine {
    param([string]$Name, [string]$Primary, [string]$Fallback, [string]$Tag, [string]$Dest)
    Write-Host "Cloning $Name@$Tag..." -ForegroundColor Cyan
    if (Test-Path $Dest) { Remove-Item -Recurse -Force $Dest }
    $uris = @()
    if ($Primary)  { $uris += $Primary }
    if ($Fallback) { $uris += $Fallback }
    foreach ($uri in $uris) {
        try {
            git clone --depth 1 -b $Tag $uri $Dest 2>$null
            if ($LASTEXITCODE -eq 0) { return }
        } catch {}
        try {
            git clone --depth 1 $uri $Dest 2>$null
            if ($LASTEXITCODE -eq 0) { return }
        } catch {}
    }
    Write-Host "✖ Failed to clone $Name" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path "$ENGINES_DIR/fireworks-tech-graph")) {
    Clone-Engine "fireworks-tech-graph" $FIREWORKS_REPO $FIREWORKS_FALLBACK $FIRECRACKER_TAG "$ENGINES_DIR/fireworks-tech-graph"
    Write-Host "✔ fireworks-tech-graph cloned" -ForegroundColor Green
}

if (-not (Test-Path "$ENGINES_DIR/mermaid-visualizer")) {
    $TMP = Join-Path $env:TEMP "axton-$([Guid]::NewGuid())"
    Clone-Engine "axton-visual-skills" $AXTON_REPO $AXTON_FALLBACK $AXTON_TAG $TMP
    Copy-Item -Recurse "$TMP/mermaid-visualizer" "$ENGINES_DIR/"
    Copy-Item -Recurse "$TMP/excalidraw-diagram" "$ENGINES_DIR/"
    Copy-Item -Recurse "$TMP/obsidian-canvas-creator" "$ENGINES_DIR/canvas-creator"
    Remove-Item -Recurse -Force $TMP
    Write-Host "✔ axton engines cloned" -ForegroundColor Green
}

# Step 4: Link Agents
Write-Host "Step 4/7: Linking to detected Agents..." -ForegroundColor Cyan
$SKILLS_DIR = "$TOOLKIT_DIR"
$INSTALLED = 0

# Helper: create symlink or junction; fall back to copy
function Link-Skill {
    param([string]$AgentName, [string]$TargetPath)
    if (-not (Test-Path (Split-Path $TargetPath -Parent))) { return }
    if (Test-Path $TargetPath) {
        Write-Host "✔ $AgentName link exists" -ForegroundColor Green
        $script:INSTALLED++
        return
    }
    New-Item -ItemType Junction -Path $TargetPath -Target $SKILLS_DIR -ErrorAction SilentlyContinue | Out-Null
    if (-not (Test-Path $TargetPath)) {
        Copy-Item -Recurse $SKILLS_DIR $TargetPath
    }
    Write-Host "✔ Linked to $AgentName" -ForegroundColor Green
    $script:INSTALLED++
}

Link-Skill "Claude Code" "$env:USERPROFILE/.claude/skills/chart-toolkit"
Link-Skill "Codex"       "$env:USERPROFILE/.agents/skills/chart-toolkit"
Link-Skill "TeleAgent"   "$env:USERPROFILE/.config/TeleAgent/skills/chart-toolkit"

if ($INSTALLED -eq 0) {
    Write-Host "⚠ No supported Agent detected." -ForegroundColor Yellow
    Write-Host "Manual: symlink or copy chart-toolkit/ to your Agent's skills directory."
}

# Step 5: Drawio MCP
Write-Host "Step 5/7: Drawio MCP configuration..." -ForegroundColor Cyan

# Read drawio version from engines.json
$DRAWIO_VERSION = "latest"
$enginesJsonPath = Join-Path $TOOLKIT_DIR "engines.json"
if (Test-Path $enginesJsonPath) {
    try {
        $enginesCfg = Get-Content $enginesJsonPath -Raw | ConvertFrom-Json
        $v = $enginesCfg.engines.drawio.version
        if ($v) { $DRAWIO_VERSION = $v }
    } catch {}
}
$DRAWIO_PACKAGE = "@next-ai-drawio/mcp-server@$DRAWIO_VERSION"

# Merge drawio into an MCP config file (agent-agnostic)
function Merge-DrawioMCP {
    param([string]$ConfigPath, [string]$AgentLabel)
    $dir = Split-Path $ConfigPath -Parent
    if (-not (Test-Path $dir)) {
        Write-Host "⊘ $AgentLabel not installed — skipping MCP config" -ForegroundColor DarkGray
        return
    }
    New-Item -ItemType Directory -Force -Path $dir | Out-Null

    if (Test-Path $ConfigPath) {
        $raw = Get-Content $ConfigPath -Raw
        if ($raw -match '"drawio"') {
            Write-Host "✔ $AgentLabel Drawio MCP already configured" -ForegroundColor Green
            return
        }
        try {
            $mcp = $raw | ConvertFrom-Json
            $servers = $mcp.mcpServers
            if (-not $servers) {
                $mcp | Add-Member -NotePropertyName "mcpServers" -NotePropertyValue @{} -Force
                $servers = $mcp.mcpServers
            }
            $drawioEntry = @{ command = "npx"; args = @($DRAWIO_PACKAGE) }
            $servers | Add-Member -NotePropertyName "drawio" -NotePropertyValue $drawioEntry -Force
            $mcp | ConvertTo-Json -Depth 4 | Set-Content $ConfigPath
            Write-Host "✔ $AgentLabel Drawio MCP merged" -ForegroundColor Green
            return
        } catch {}
    }

    # Create from scratch
    @{ mcpServers = @{ drawio = @{ command = "npx"; args = @($DRAWIO_PACKAGE) } } } |
        ConvertTo-Json -Depth 4 | Set-Content $ConfigPath
    Write-Host "✔ $AgentLabel Drawio MCP configured (created)" -ForegroundColor Green
}

Merge-DrawioMCP "$env:USERPROFILE/.claude/mcp.json"              "Claude Code"
Merge-DrawioMCP "$env:USERPROFILE/.agents/mcp.json"              "Codex"
Merge-DrawioMCP "$env:USERPROFILE/.config/TeleAgent/mcp.json"   "TeleAgent"

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