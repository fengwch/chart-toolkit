# Chart Toolkit Doctor — Windows PowerShell
Write-Host ""
Write-Host "Chart Toolkit Doctor (Windows)" -ForegroundColor Cyan
Write-Host "==============================" -ForegroundColor Cyan
Write-Host ""

$TOOLKIT_DIR = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)

Write-Host "—— System ——" -ForegroundColor Yellow
@("git", "python", "node", "npx") | ForEach-Object {
    if (Get-Command $_ -ErrorAction SilentlyContinue) {
        Write-Host "✔ $_" -ForegroundColor Green
    } else {
        Write-Host "✖ $_ not found" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "—— Python ——" -ForegroundColor Yellow
try { python -c "import cairosvg"; Write-Host "✔ cairosvg" -ForegroundColor Green }
catch { Write-Host "⚠ cairosvg not installed (pip install cairosvg)" -ForegroundColor Yellow }

Write-Host ""
Write-Host "—— Engines ——" -ForegroundColor Yellow
@("fireworks-tech-graph", "mermaid-visualizer", "excalidraw-diagram", "canvas-creator") | ForEach-Object {
    if (Test-Path "$TOOLKIT_DIR/engines/$_") {
        Write-Host "✔ $_" -ForegroundColor Green
    } else {
        Write-Host "⚠ $_ missing (run setup.ps1)" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "—— MCP (Drawio) ——" -ForegroundColor Yellow
Write-Host "ℹ To check manually: claude mcp list"