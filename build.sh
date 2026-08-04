#!/bin/bash
# chart-toolkit build script
# Builds a clean release package for skill marketplace upload.
# Only runtime-required files are included; development tools,
# install scripts, and vendored repos are excluded.

set -euo pipefail

# Version: first argument, git tag, or date-based fallback
VERSION="${1:-$(git describe --tags 2>/dev/null || echo "v$(date +%Y.%m.%d)")}"

SOURCE_DIR="$(pwd)"
BUILD_DIR="$SOURCE_DIR/build/chart-toolkit"
RELEASE_DIR="$SOURCE_DIR/release"
ZIP_NAME="chart-toolkit-${VERSION}.zip"

# Clean previous build
rm -rf "$BUILD_DIR"

# Create release directory structure
mkdir -p "$BUILD_DIR/references"
mkdir -p "$BUILD_DIR/engines"

# 1. Core skill files
cp "$SOURCE_DIR/SKILL.md" "$BUILD_DIR/"
cp "$SOURCE_DIR/engines.json" "$BUILD_DIR/"
cp "$SOURCE_DIR/LICENSE" "$BUILD_DIR/" 2>/dev/null || true

# 2. Reference documents (adapters, knowledge, rules)
cp -r "$SOURCE_DIR/references/"* "$BUILD_DIR/references/"

# 3. Scripts (doctor, merge-config helpers)
if [ -d "$SOURCE_DIR/scripts" ]; then
  cp -r "$SOURCE_DIR/scripts" "$BUILD_DIR/scripts"
fi

# 4. Engine files (upstream skill definitions)
# Copy engine directories preserving structure
for engine_dir in "$SOURCE_DIR"/engines/*/; do
  if [ -d "$engine_dir" ]; then
    engine_name="$(basename "$engine_dir")"
    cp -r "$engine_dir" "$BUILD_DIR/engines/$engine_name"
  fi
done

# 5. Package zip into release/
mkdir -p "$RELEASE_DIR"
rm -f "$RELEASE_DIR/$ZIP_NAME"
cd "$SOURCE_DIR/build"
zip -r "$RELEASE_DIR/$ZIP_NAME" chart-toolkit/ -q

# Summary
echo ""
echo "✅ Build complete"
echo "   文件数: $(find "$BUILD_DIR" -type f | wc -l | tr -d ' ')"
echo "   发布包: release/$ZIP_NAME"
echo "   大小:   $(du -sh "$RELEASE_DIR/$ZIP_NAME" | cut -f1)"
echo ""
echo "上传 release/$ZIP_NAME 到技能市场。"
