# cairosvg (Python)

Used by the **fireworks** engine to convert SVG → PNG.

## Quick install

```bash
python3 -m pip install cairosvg
```

Verify:

```bash
python3 -c "import cairosvg; print(cairosvg.__version__)"
```

## macOS prerequisites

`cairosvg` links against Cairo. On a brand-new macOS, the system Cairo can be too old.

If `pip install cairosvg` succeeds but the first SVG render fails with `Library not loaded: /opt/homebrew/opt/libffi/lib/libffi...`:

```bash
brew install cairo pkg-config libffi
python3 -m pip install --force-reinstall --no-cache-dir cairosvg
```

## Windows

`pip install cairosvg` ships wheels that include Cairo. If a wheel is missing for your Python version:

- Use Python 3.11 or 3.12 (well-supported wheels), or
- Fall back to `rsvg-convert` instead (see `tools/deps/rsvg-convert.md`).

## Linux (Debian/Ubuntu)

```bash
sudo apt install libcairo2-dev pkg-config python3-dev
python3 -m pip install --force-reinstall cairosvg
```

## 自动检测

```bash
bash tools/check.sh fireworks    # 输出 NEED :: fireworks :: cairosvg
bash tools/check.sh fireworks --fix
```
