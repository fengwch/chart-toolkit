# Homebrew (macOS / Linux package manager)

Used by `setup.sh` and `tools/check.sh` to auto-install dependencies on macOS and Linux.

## Install (macOS)

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Verify:

```bash
brew --version
```

## Common commands

```bash
brew install git node librsvg
brew update
```
