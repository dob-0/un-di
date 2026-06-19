#!/usr/bin/env bash
# Auto-sync ~/.claude/settings.json and ~/.claude/CLAUDE.md into un-di's
# backup templates whenever they drift, and push. Wired as a Stop hook in
# ~/.claude/settings.json so it runs at the end of every session — cheap
# (cmp + git), zero model tokens.
set -euo pipefail
UNDI=/home/nooo/un-di
CHANGED=0

if ! cmp -s ~/.claude/settings.json "$UNDI/templates/global-settings.json" 2>/dev/null; then
  cp ~/.claude/settings.json "$UNDI/templates/global-settings.json"
  CHANGED=1
fi

if ! cmp -s ~/.claude/CLAUDE.md "$UNDI/templates/global-CLAUDE.md" 2>/dev/null; then
  cp ~/.claude/CLAUDE.md "$UNDI/templates/global-CLAUDE.md"
  CHANGED=1
fi

[ "$CHANGED" -eq 0 ] && exit 0

cd "$UNDI"
git add templates/global-settings.json templates/global-CLAUDE.md
git commit -m "chore: auto-sync global Claude config backup" --quiet
git push origin main --quiet
echo "un-di: global config backup synced and pushed"
