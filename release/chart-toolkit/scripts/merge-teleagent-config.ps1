# Append drawio MCP entry to TeleAgent's config file (Windows PowerShell).
# TeleAgent uses TeleAgent.jsonc with a different schema than mcp.json:
#   "drawio": { "command": ["npx", "@next-ai-drawio/mcp-server@latest"], "enabled": true, "type": "local" }
#
# IMPORTANT (Windows): ConvertTo-Json emits pretty-printed output with 4-space
# indentation. TeleAgent's JSONC parser is strict about whitespace style and
# may reject multi-line blocks for nested arrays. We therefore write the
# entry in the original compact one-line-per-field format and append a
# trailing newline. Never re-serialize the whole config — that would rewrite
# the user's other fields in PS style and break parsing.
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

# Read raw bytes — we never round-trip through ConvertTo-Json, because PS's
# serializer produces an indentation style that TeleAgent's JSONC parser
# rejects for nested arrays.
$raw = if (Test-Path $Config) { Get-Content $Config -Raw -Encoding UTF8 } else { "" }
$trailingNewline = ($raw.Length -gt 0) -and $raw.EndsWith([char]10)

# Build the drawio block in the EXACT compact format TeleAgent expects.
# Keys: command (array), enabled (bool), type (string).
# One line per field, 2-space indent, comma after the closing brace.
$drawioBlock = @'
  "drawio": {
    "command": [
      "npx",
      "@next-ai-drawio/mcp-server@latest"
    ],
    "enabled": true,
    "type": "local"
  },
'@

# Create from scratch if missing — write minimal valid JSONC
if ([string]::IsNullOrEmpty($raw)) {
    $initial = @"
{
$drawioBlock.TrimEnd(',')
}
"@
    Set-Content -Path $Config -Value $initial -Encoding UTF8 -NoNewline
    Write-Host "✔ $AgentLabel: created $Config with drawio entry" -ForegroundColor Green
    Write-Host "  → restart TeleAgent for MCP tools to load" -ForegroundColor Yellow
    exit 0
}

# Merge into existing config — append before the LAST closing brace of the
# root object. Use simple line scan; supports standard compact JSONC without
# comments. If comments or unusual structure is detected, fall back to a
# parse-validate path using node.js.

# Strip BOM if present (TeleAgent configs sometimes have UTF-8 BOM)
$rawNoBom = if ($raw.Length -gt 0 -and $raw[0] -eq [char]0xFEFF) { $raw.Substring(1) } else { $raw }

# Detect // comments in root (rare but possible in .jsonc). If found, use node.js.
$hasComments = ($rawNoBom -split "`r?`n" | Where-Object { $_ -match '^\s*//' }) -ne $null

if ($hasComments) {
    # Delegate to node.js for proper JSONC handling
    if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
        Write-Host "✖ $AgentLabel: TeleAgent.jsonc has // comments but node.js is not available" -ForegroundColor Red
        Write-Host "  Please edit manually: $Config" -ForegroundColor Yellow
        exit 1
    }
    $nodeScript = @'
const fs = require('fs');
const path = process.argv[1];
const raw = fs.readFileSync(path, 'utf8');
let data;
try {
    // Strip // line comments before parsing (simple heuristic)
    const stripped = raw.split('\n').map(l => l.replace(/\/\/.*$/, '')).join('\n');
    data = JSON.parse(stripped);
} catch (e) {
    console.error('parse failed: ' + e.message);
    process.exit(1);
}
if (data.drawio) { console.log('already configured'); process.exit(0); }
data.drawio = {
    command: ['npx', '@next-ai-drawio/mcp-server@latest'],
    enabled: true,
    type: 'local'
};
fs.writeFileSync(path, JSON.stringify(data, null, 2) + '\n');
console.log('appended');
'@
    $tmp = "$Config.teleagent.tmp"
    node -e $nodeScript $Config
    if ($LASTEXITCODE -ne 0) {
        Write-Host "✖ $AgentLabel: node.js merge failed for $Config" -ForegroundColor Red
        exit 1
    }
    Write-Host "✔ $AgentLabel: drawio MCP appended (via node) to $Config" -ForegroundColor Green
    Write-Host "  → restart TeleAgent for MCP tools to load" -ForegroundColor Yellow
    exit 0
}

# Plain JSON: find the LAST closing '}' at root and insert the block before it.
# Find the index of the final '}' (searching from end of file).
$idx = $rawNoBom.LastIndexOf('}')
if ($idx -lt 0) {
    Write-Host "✖ $AgentLabel: malformed TeleAgent.jsonc — no closing brace" -ForegroundColor Red
    exit 1
}

# Check if the previous non-whitespace char is a comma. If yes, just insert.
# If no, add a comma after the existing last field.
$before = $rawNoBom.Substring(0, $idx).TrimEnd()
$endsWithComma = $before.EndsWith(',')
$insertion = if ($endsWithComma) { "`n" + $drawioBlock } else { ",`n" + $drawioBlock }

# Reconstruct: prefix + insertion + suffix (from the '}' onward + optional trailing newline)
$suffix = $rawNoBom.Substring($idx)
$newContent = $rawNoBom.Substring(0, $idx - ($idx - $before.Length - ($before.Length - $before.TrimEnd().Length))) + $insertion + "`n" + $suffix.TrimStart()

# Cleaner reconstruction
$prefix = $before
$newContent = $prefix + $insertion + "`n" + $suffix

Set-Content -Path $Config -Value $newContent -Encoding UTF8 -NoNewline

Write-Host "✔ $AgentLabel: drawio MCP appended to $Config (compact format)" -ForegroundColor Green
Write-Host "  → restart TeleAgent for MCP tools to load" -ForegroundColor Yellow