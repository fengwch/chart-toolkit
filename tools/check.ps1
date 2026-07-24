# tools/check.ps1 — Windows engine tool environment check / install instruction.
#
# Usage:
#   powershell -File tools/check.ps1                  # check all
#   powershell -File tools/check.ps1 fireworks        # one engine
#   powershell -File tools/check.ps1 fireworks -Fix  # try install
#
# Output (compressed, same shape as check.sh):
#   OK     :: <engine>
#   NEED   :: <engine> :: <tool[,tool]>
#   FIXED  :: <engine>
#   MANUAL :: <engine> :: tools/deps/<tool>.md

$ErrorActionPreference = "Stop"
$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path

function Has-Cmd($name) { $null -ne (Get-Command $name -ErrorAction SilentlyContinue) }

function Engines-Def-Fireworks {
    $miss = ""
    if (-not (Has-Cmd "git"))   { $miss += " git" }
    if (-not (Has-Cmd "node"))  { $miss += " node" }
    if (Has-Cmd "python") {
        try { python -c "import cairosvg" 2>$null | Out-Null; if ($LASTEXITCODE -ne 0) { $miss += " cairosvg" } } catch { $miss += " cairosvg" }
        if (-not (Has-Cmd "rsvg-convert")) { if ($miss -notmatch "cairosvg") { $miss += " rsvg-convert" } }
    } else { $miss += " python" }
    $miss.Trim()
}
function Engines-Def-Drawio {
    $miss = ""
    if (-not (Has-Cmd "node")) { $miss += " node" }
    $miss.Trim()
}
function Engines-Def-Mermaid    { "" }
function Engines-Def-Excalidraw { "" }
function Engines-Def-Canvas     { "" }
function Engines-Def-Dataviz    { "" }

function Report-Engine($engine, $miss) {
    if ([string]::IsNullOrWhiteSpace($miss)) {
        Write-Host "OK     :: $engine"
    } else {
        Write-Host "NEED   :: $engine :: $miss"
    }
}

function Fix-Engine($engine) {
    switch ($engine) {
        "fireworks" {
            $miss = Engines-Def-Fireworks
            foreach ($t in $miss.Split(" ", [StringSplitOptions]::RemoveEmptyEntries)) {
                switch ($t) {
                    "git"    { if (Has-Cmd "choco") { choco install git -y   | Out-Null } else { Write-Host "MANUAL :: $engine :: tools/deps/git.md"  ; return } }
                    "node"   { if (Has-Cmd "choco") { choco install nodejs -y | Out-Null } else { Write-Host "MANUAL :: $engine :: tools/deps/node.md" ; return } }
                    "python" { Write-Host "MANUAL :: $engine :: tools/deps/python3.md" ; return }
                    "cairosvg" {
                        if (Has-Cmd "pip") { pip install cairosvg 2>&1 | Out-Null }
                        elseif (Has-Cmd "choco") { choco install rsvg-convert -y | Out-Null }
                    }
                    "rsvg-convert" { if (Has-Cmd "choco") { choco install rsvg-convert -y | Out-Null } }
                }
            }
            $after = Engines-Def-Fireworks
            if ([string]::IsNullOrWhiteSpace($after)) { Write-Host "FIXED  :: $engine" } else { Write-Host "MANUAL :: $engine :: tools/deps/<tool>.md" }
        }
        "drawio" {
            if (Has-Cmd "choco") { choco install nodejs -y | Out-Null }
            Write-Host "FIXED  :: $engine (run: claude mcp add drawio -- npx @next-ai-drawio/mcp-server@latest)"
        }
        default { Write-Host "MANUAL :: $engine :: tools/deps/<tool>.md" }
    }
}

$target = if ($args.Count -gt 0) { $args[0] } else { "all" }
$fix = $args -contains "-Fix"

switch ($target) {
    "--list" { Write-Host "fireworks mermaid excalidraw canvas drawio dataviz" }
    "all" {
        $engines = @("fireworks","mermaid","excalidraw","canvas","drawio","dataviz")
        foreach ($e in $engines) {
            $fn = "Engines-Def-$($e.Substring(0,1).ToUpper() + $e.Substring(1))"
            if ($e -eq "drawio") { $fn = "Engines-Def-Drawio" }
            $def = & $fn
            if ($fix) { Fix-Engine $e } else { Report-Engine $e $def }
        }
    }
    { @("fireworks","mermaid","excalidraw","canvas","drawio","dataviz") -contains $_ } {
        $fn = "Engines-Def-$($target.Substring(0,1).ToUpper() + $target.Substring(1))"
        if ($target -eq "drawio") { $fn = "Engines-Def-Drawio" }
        $def = & $fn
        if ($fix) { Fix-Engine $target } else { Report-Engine $target $def }
    }
    default { Write-Host "unknown engine: $target"; exit 2 }
}