#!/bin/bash
set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK_CMD="python3 $REPO_DIR/hook.py"

python3 << PYEOF
import json, os

config_path  = os.path.expanduser("~/.claude/settings.json")
hook_command = "$HOOK_CMD"

if not os.path.exists(config_path):
    print("No settings.json found — nothing to do")
    exit(0)

with open(config_path) as f:
    config = json.load(f)

before = len(config.get("hooks", {}).get("PreToolUse", []))

config["hooks"]["PreToolUse"] = [
    e for e in config.get("hooks", {}).get("PreToolUse", [])
    if not any(
        h.get("command", "") == hook_command
        for h in (e.get("hooks", []) if isinstance(e, dict) else [])
    )
]

after = len(config["hooks"]["PreToolUse"])

with open(config_path, "w") as f:
    json.dump(config, f, indent=2)

print(f"Removed {before - after} hook(s) for: {hook_command}")
print("Sentnel unregistered from ~/.claude/settings.json")
PYEOF

echo "✓ Done — restart Claude Code to take effect"
