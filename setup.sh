#!/bin/bash

set -e

INSTALL_DIR="$HOME/.sentnel"
OLD_DIR="$HOME/sentnel"

INSTALLER_VERSION="2.0.5"
echo "Installing Sentnel v$INSTALLER_VERSION..."

# Migrate from old directory if it exists
if [ -d "$OLD_DIR" ]; then
  echo "Migrating from $OLD_DIR to $INSTALL_DIR..."
  mkdir -p "$INSTALL_DIR"
  mv "$OLD_DIR"/* "$INSTALL_DIR/" 2>/dev/null || true
  rmdir "$OLD_DIR" 2>/dev/null || true
fi

mkdir -p $INSTALL_DIR

# Files to install
FILES=("hook.py" "rules.yaml" "logger.py")

# Install CLAUDE.md to ~/.claude/ for intent-layer guardrails
CLAUDE_MD_SRC="CLAUDE.md"
CLAUDE_MD_DEST="$HOME/.claude/CLAUDE.md"
mkdir -p "$HOME/.claude"
if [ -f "$CLAUDE_MD_SRC" ]; then
  echo "Installing CLAUDE.md to $CLAUDE_MD_DEST..."
  cp "$CLAUDE_MD_SRC" "$CLAUDE_MD_DEST"
else
  echo "Downloading CLAUDE.md from GitHub..."
  curl -sSL "https://raw.githubusercontent.com/sentnelops/sentnel/main/CLAUDE.md" -o "$CLAUDE_MD_DEST"
fi

for FILE in "${FILES[@]}"; do
  if [ -f "$FILE" ]; then
    echo "Found local $FILE, copying..."
    cp "$FILE" "$INSTALL_DIR/"
  else
    echo "Downloading $FILE from GitHub..."
    curl -sSL "https://raw.githubusercontent.com/sentnelops/sentnel/main/$FILE" -o "$INSTALL_DIR/$FILE"
  fi
done

# Install dependencies
echo "Installing dependencies..."
# Use --break-system-packages for macOS/PEP 668 compliance
pip3 install pyyaml --quiet --break-system-packages 2>/dev/null || pip3 install pyyaml --quiet

# Create DB file
touch $INSTALL_DIR/audit.db

# Update Claude config
CLAUDE_CONFIG="$HOME/.claude/settings.json"

if [ ! -f "$CLAUDE_CONFIG" ]; then
  echo '{}' > $CLAUDE_CONFIG
fi

# Inject hook (simple version)
python3 - <<EOF
import json
import os

config_path = os.path.expanduser("~/.claude/settings.json")

with open(config_path, "r") as f:
    config = json.load(f)

config.setdefault("hooks", {})
config["hooks"]["PreToolUse"] = [
    {
        "matcher": "",
        "hooks": [
            {
                "type": "command",
                "command": "python3 ~/.sentnel/hook.py"
            }
        ]
    }
]

with open(config_path, "w") as f:
    json.dump(config, f, indent=2)
EOF

echo "✅ Installed successfully!"