#!/bin/bash

cd "$(dirname "$0")"

APP_NAME="InjectHub.app"
TARGET_PATH="/Applications/$APP_NAME"

echo "📦 Installing $APP_NAME to /Applications..."

# Move the app to /Applications
if [ -d "./$APP_NAME" ]; then
    cp -R "./$APP_NAME" /Applications/
else
    echo "❌ Error: $APP_NAME not found in the current directory."
    exit 1
fi

echo "🧼 Removing quarantine attributes..."
xattr -rc "$TARGET_PATH"

echo "🔏 Codesigning the app (ad-hoc)..."
codesign -f -s - --deep "$TARGET_PATH"

echo "✅ Installation complete: $TARGET_PATH"
open "$TARGET_PATH"
