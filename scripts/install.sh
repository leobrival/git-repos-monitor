#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
APP_NAME="Git Repos Monitor"
APP_BUNDLE="$PROJECT_DIR/$APP_NAME.app"
INSTALL_DIR="$HOME/Applications"
LAUNCHAGENT_DIR="$HOME/Library/LaunchAgents"
LAUNCHAGENT_PLIST="$LAUNCHAGENT_DIR/dev.leobrival.git-repos-monitor.plist"

# Build first if needed
if [ ! -d "$APP_BUNDLE" ]; then
    echo "App bundle not found, building first..."
    sh "$SCRIPT_DIR/build.sh"
fi

# Install to ~/Applications
echo "Installing to $INSTALL_DIR..."
mkdir -p "$INSTALL_DIR"
rm -rf "$INSTALL_DIR/$APP_NAME.app"
cp -R "$APP_BUNDLE" "$INSTALL_DIR/$APP_NAME.app"

echo "Installed: $INSTALL_DIR/$APP_NAME.app"

# Ask about LaunchAgent
read -p "Install LaunchAgent for login auto-start? [y/N] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    mkdir -p "$LAUNCHAGENT_DIR"

    cat > "$LAUNCHAGENT_PLIST" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>dev.leobrival.git-repos-monitor</string>
    <key>ProgramArguments</key>
    <array>
        <string>$INSTALL_DIR/$APP_NAME.app/Contents/MacOS/GitReposMonitor</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <false/>
</dict>
</plist>
EOF

    launchctl load "$LAUNCHAGENT_PLIST" 2>/dev/null || true
    echo "LaunchAgent installed: $LAUNCHAGENT_PLIST"
fi

echo ""
echo "Done! You can launch the app from $INSTALL_DIR/$APP_NAME.app"
echo "Or run: open '$INSTALL_DIR/$APP_NAME.app'"
