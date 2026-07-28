# Append drawio MCP entry to TeleAgent's config file (Windows PowerShell).
# TeleAgent uses TeleAgent.jsonc with a different schema than mcp.json:
#   "drawio": { "command": ["npx", "@next-ai-drawio/mcp-server@latest"], "enabled": true, "type": "local" }
#
# Usage: .\scripts\merge-teleagent-config.ps1 [agent_label]

$ErrorActionPreference = "Stop"
$AgentLabel = if ($args.Count -gt 0) { $args[0] } else { "TeleAgent" }

# Resolve config path
if ($env:TELEAGENT_CONFIG) {
    $Config = $env:TELEAGENT_CONFIG
} elseif ($env:USERPROFILE) {
    $Config = Join-Path $env:USERPROFILE ".config\TeleAgent\TeleAgent.jsonc"
} elseif ($env:HOME) {
    $Config = Join-Path $env:HOME ".config/TeleAgent/TeleAgent.jsonc"
} else {
    Write-Host "✖ Cannot resolve TeleAgent config path" -ForegroundColor Red
    exit 1
}

$Dir = Split-Path $Config -Parent
if (-not (Test-Path $Dir)) {
    Write-Host "⊘ $AgentLabel not installed - skipping ($Config)" -ForegroundColor DarkGray
    exit 0
}

# Already configured?
if ((Test-Path $Config) -and (Select-String -Path $Config -Pattern '"drawio"' -Quiet)) {
    Write-Host "✔ $AgentLabel: drawio MCP already in $Config" -ForegroundColor Green
    exit 0
}

# Need node.js for JSON manipulation
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Host "✖ node.js not found - cannot configure TeleAgent drawio MCP" -ForegroundColor Red
    Write-Host "  Install node.js, then re-run setup.ps1" -ForegroundColor Yellow
    exit 1
}

$tmp = "$Config.tmp.$PID"

# Create from scratch if missing
if (-not (Test-Path $Config)) {
    $initial = @{
        drawio = @{
            command = @("npx", "@next-ai-drawio/mcp-server@latest")
            enabled = $true
            type = "local"
        }
    }
    $initial | ConvertTo-Json -Depth 4 | Set-Content $Config
    Write-Host "✔ $AgentLabel: created $Config with drawio entry" -ForegroundColor Green
    Write-Host "  → restart TeleAgent for MCP tools to load" -ForegroundColor Yellow
    exit 0
}

# Merge into existing config
$drawioEntry = @{
    command = @("npx", "@next-ai-drawio/mcp-server@latest")
    enabled = $true
    type = "local"
}

try {
    $raw = Get-Content $Config -Raw
    $existing = $raw | ConvertFrom-Json
} catch {
    Write-Host "✖ $AgentLabel: TeleAgent.jsonc is not valid JSON - manual edit required" -ForegroundColor Red
    Write-Host "  File: $Config" -ForegroundColor Yellow
    Write-Host "  Append this object at root level:" -ForegroundColor Yellow
    Write-Host "    drawio: { command: ['npx', '@next-ai-drawio/mcp-server@latest'], enabled: true, type: 'local' }" -ForegroundColor Yellow
    exit 1
}

if ($existing.drawio) {
    Write-Host "✔ $AgentLabel: drawio MCP already configured" -ForegroundColor Green
    exit 0
}

$existing | Add-Member -NotePropertyName "drawio" -NotePropertyValue $drawioEntry -Force
$existing | ConvertTo-Json -Depth 4 | Set-Content $tmp
Move-Item -Force $tmp $Config
Remove-Item -Force $tmp -ErrorAction SilentlyContinue

Write-Host "✔ $AgentLabel: drawio MCP appended to $Config" -ForegroundColor Green
Write-Host "  → restart TeleAgent for MCP tools to load" -ForegroundColor Yellow