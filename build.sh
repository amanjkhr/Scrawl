#!/bin/bash
# Scrawl Build Script
# Builds the Swift project and packages it into a .app bundle

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_NAME="Scrawl"
APP_BUNDLE="$SCRIPT_DIR/$APP_NAME.app"

echo "🔨 Building $APP_NAME..."
cd "$SCRIPT_DIR"
swift build -c release 2>&1

echo "📦 Packaging $APP_NAME.app..."
cp -f "$SCRIPT_DIR/.build/release/$APP_NAME" "$APP_BUNDLE/Contents/MacOS/$APP_NAME"

echo "📋 Copying to /Applications..."
cp -R "$APP_BUNDLE" /Applications/

echo "🔄 Refreshing Launch Services..."
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "/Applications/$APP_NAME.app"

echo "✅ Done! $APP_NAME.app is ready in /Applications"
echo "   You can now find it in Launchpad or pin it to your Dock."
