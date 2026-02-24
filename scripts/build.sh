#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$PROJECT_DIR/.build/release"
APP_NAME="Git Repos Monitor"
APP_BUNDLE="$PROJECT_DIR/$APP_NAME.app"

echo "Building GitReposMonitor..."
cd "$PROJECT_DIR"
swift build -c release

echo "Creating app bundle..."
rm -rf "$APP_BUNDLE"
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

# Copy executable
cp "$BUILD_DIR/GitReposMonitor" "$APP_BUNDLE/Contents/MacOS/GitReposMonitor"

# Copy Info.plist
cp "$PROJECT_DIR/Info.plist" "$APP_BUNDLE/Contents/Info.plist"

echo "Build complete: $APP_BUNDLE"
echo ""
echo "To install, run: sh scripts/install.sh"
