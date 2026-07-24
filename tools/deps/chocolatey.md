# Chocolatey (Windows package manager)

Used by `setup.ps1` and `tools/check.ps1` to install rsvg-convert / node / git on Windows.

## Install (管理员 PowerShell)

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
irm https://community.chocolatey.org/install.ps1 | iex
```

Verify:

```powershell
choco --version
```

## Usage

```powershell
choco install rsvg-convert -y
choco install nodejs-lts -y
choco install git -y
```
