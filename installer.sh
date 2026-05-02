#!/bin/bash

set -e

INSTALL_DIR="$HOME/sentnel"

echo "Installing Sentnel..."

mkdir -p $INSTALL_DIR

# Files to install
FILES=("hook.py" "rules.yaml" "logger.py")

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
pip3 install pyyaml --quiet

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
config["hooks"]["PreToolUse"] = "python3 ~/sentnel/hook.py"

with open(config_path, "w") as f:
    json.dump(config, f, indent=2)
EOF

echo "✅ Installed successfully!"