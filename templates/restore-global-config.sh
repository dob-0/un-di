#!/usr/bin/env bash
# Restore ~/.claude global config from un-di's backup templates.
# Run after a fresh OS install / Claude Code reinstall, from anywhere:
#   bash /home/nooo/un-di/templates/restore-global-config.sh
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
mkdir -p ~/.claude
cp "$DIR/global-settings.json" ~/.claude/settings.json
cp "$DIR/global-CLAUDE.md" ~/.claude/CLAUDE.md
echo "Restored ~/.claude/settings.json and ~/.claude/CLAUDE.md from un-di templates."
echo "Per-project config (di.iiii, etc.) is already version-controlled in those repos — just re-clone."
