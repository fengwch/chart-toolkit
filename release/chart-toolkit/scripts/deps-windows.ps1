# Install all dependencies on Windows
Write-Host "Installing Chart Toolkit dependencies for Windows..." -ForegroundColor Cyan
Write-Host ""

Write-Host "Please ensure these are installed manually if missing:" -ForegroundColor Yellow
Write-Host "  Git:        https://git-scm.com/download/win"
Write-Host "  Python 3:   https://www.python.org/downloads/"
Write-Host "  Node.js:    https://nodejs.org/"
Write-Host ""

pip install --upgrade pip
pip install cairosvg

Write-Host "✔ Python dependencies installed." -ForegroundColor Green
Write-Host "ℹ rsvg-convert is not available on native Windows. Use cairosvg (just installed) for SVG→PNG conversion." -ForegroundColor Cyan