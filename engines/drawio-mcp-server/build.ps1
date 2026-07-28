# Build the vendored drawio MCP server (Windows PowerShell)
# Outputs to engines\drawio-mcp-server\dist\index.js
# Run from chart-toolkit root: .\engines\drawio-mcp-server\build.ps1
$ErrorActionPreference = "Stop"
$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $SCRIPT_DIR

# Check node
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Host "✖ node.js not found - install from https://nodejs.org/" -ForegroundColor Red
    exit 1
}
$nodeVer = (node -v).TrimStart('v').Split('.')[0]
if ([int]$nodeVer -lt 18) {
    Write-Host "✖ node.js >=18 required (found $(node -v))" -ForegroundColor Red
    exit 1
}

# Install deps if needed
if (-not (Test-Path node_modules)) {
    Write-Host "Installing drawio MCP server dependencies..." -ForegroundColor Cyan
    npm install --omit=dev --no-audit --no-fund 2>&1 | Select-Object -Last 5
}

# Build
Write-Host "Building drawio MCP server..." -ForegroundColor Cyan
npm run build 2>&1 | Select-Object -Last 10

if (Test-Path dist/index.js) {
    $size = (Get-Item dist/index.js).Length
    Write-Host "✔ Built: dist\index.js ($([math]::Round($size/1024, 0)) KB)" -ForegroundColor Green
} else {
    Write-Host "✖ Build failed - dist\index.js not found" -ForegroundColor Red
    exit 1
}