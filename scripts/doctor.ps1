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
Write-Host "—— SVG → PNG ——" -ForegroundColor Yellow
$pwOk = $false
try {
    npm list -g playwright 2>$null | Out-Null
    $pwOk = $true
} catch {}
if ($pwOk) {
    Write-Host "✔ playwright installed" -ForegroundColor Green
    $chromiumPath = "$env:USERPROFILE\AppData\Local\ms-playwright\chromium-*\chrome-win\chrome.exe"
    if (Test-Path $chromiumPath) {
        Write-Host "✔ Chromium for Playwright found" -ForegroundColor Green
    } else {
        Write-Host "⚠ Chromium for Playwright not found (run: npx playwright install chromium)" -ForegroundColor Yellow
    }
} else {
    Write-Host "⚠ playwright not installed (npm install -g playwright; npx playwright install chromium)" -ForegroundColor Yellow
}

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