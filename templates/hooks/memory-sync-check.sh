#!/usr/bin/env bash
# Memory sync check — fires at the end of every Claude Code session, everywhere.
#
# Memory was never being written on schedule because nothing asked for it: the
# only Stop hooks were golden-rules-check (repo rules) and sync-global-config
# (config backup). Writing memory depended entirely on the model remembering to,
# mid-task, unprompted. It mostly didn't. This makes it mechanical.
#
# Non-blocking by design: it reports, it never fails a session.

MEM="$HOME/.claude/projects/-home-nooo/memory"
INDEX="$MEM/MEMORY.md"
[[ -d "$MEM" ]] || exit 0

now=$(date +%s)
problems=()

# 1. Index staleness — a memory file newer than MEMORY.md means a fact was
#    written or updated and the index that surfaces it was never refreshed.
if [[ -f "$INDEX" ]]; then
  index_mtime=$(stat -c %Y "$INDEX")
  while IFS= read -r f; do
    [[ "$f" == "$INDEX" ]] && continue
    if [[ $(stat -c %Y "$f") -gt $index_mtime ]]; then
      problems+=("index stale: $(basename "$f") is newer than MEMORY.md")
    fi
  done < <(find "$MEM" -maxdepth 1 -name '*.md' -type f)
else
  problems+=("MEMORY.md index is missing entirely")
fi

# 2. Orphans in both directions — a file with no index line, or an index line
#    pointing at a file that no longer exists.
if [[ -f "$INDEX" ]]; then
  while IFS= read -r f; do
    base=$(basename "$f")
    [[ "$base" == "MEMORY.md" ]] && continue
    grep -qF "($base)" "$INDEX" || problems+=("unindexed: $base has no line in MEMORY.md")
  done < <(find "$MEM" -maxdepth 1 -name '*.md' -type f)

  while IFS= read -r ref; do
    if [[ "$ref" = /* ]]; then target="$ref"; else target="$MEM/$ref"; fi
    [[ -f "$target" ]] || problems+=("dead index link: MEMORY.md points at missing $ref")
  done < <(grep -oE '\(([A-Za-z0-9_./-]+\.md)\)' "$INDEX" | tr -d '()' | grep -v '^archive/')
fi

# 3. Oversize — the format is one fact per file. Past ~6 KB a file has stopped
#    being a fact and become an unread log, and recall drags the whole thing in.
while IFS= read -r f; do
  size=$(stat -c %s "$f")
  [[ "$(basename "$f")" == "MEMORY.md" ]] && continue
  [[ $size -gt 6144 ]] && problems+=("oversize: $(basename "$f") is $((size/1024)) KB — split it or compact it")
done < <(find "$MEM" -maxdepth 1 -name '*.md' -type f)

# 4. Nothing written in a long while, despite sessions happening.
newest=0
while IFS= read -r f; do
  m=$(stat -c %Y "$f"); [[ $m -gt $newest ]] && newest=$m
done < <(find "$MEM" -maxdepth 1 -name '*.md' -type f)
days=$(( (now - newest) / 86400 ))
[[ $days -ge 7 ]] && problems+=("no memory written in $days days")

echo ""
echo "── Memory Sync Check ───────────────────────────────────────────────"
if [[ ${#problems[@]} -gt 0 ]]; then
  for p in "${problems[@]}"; do echo "    • $p"; done
  echo ""
fi
echo "  Before this session closes, write the residue that outlives it:"
echo "    → a decision the user made that the code does not explain"
echo "    → a correction the user gave you (feedback_*, with the why)"
echo "    → a name/URL/path you had to discover (reference_*)"
echo "    → project state a future session cannot re-derive (project_*)"
echo ""
echo "  Then update MEMORY.md in the same breath. File without index line = lost."
echo "  Contract: meta_memory_sync.md"
echo "────────────────────────────────────────────────────────────────────"
echo ""
exit 0
