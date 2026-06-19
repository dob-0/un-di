# Hooks Reference

All hook patterns proven in di.iiii. Copy and adapt for new projects.

## How hooks work

Hooks live in `.claude/settings.json` under `"hooks"`. They fire on lifecycle events and run shell commands — zero model tokens.

```json
{
  "hooks": {
    "EventName": [{ "hooks": [{ "type": "command", "command": "..." }] }],
    "PreToolUse": [{ "matcher": "Edit|Write", "hooks": [...] }],
    "PostToolUse": [{ "matcher": "Edit|Write", "hooks": [...] }]
  }
}
```

`asyncRewake: true` — hook runs async, wakes Claude when done (use for slow ops like lint).  
`statusMessage` — shown in the UI while the hook runs.  
Exit code 2 from a hook = Claude sees it as a blocking error.

---

## SessionStart — read project state on open

**What it does:** Prints CURRENT.md and warns if the active branch doesn't match what the doc expects.

**Why:** Prevents Claude from starting work on the wrong branch or without knowing the current state.

```bash
bash -c 'printf "\n  ● session started\n\n"; cat CURRENT.md 2>/dev/null || printf "  (CURRENT.md not found)\n"; EXPECTED=$(grep -m1 "^active_branch:" CURRENT.md 2>/dev/null | sed "s/active_branch: *//"); ACTUAL=$(git branch --show-current 2>/dev/null); if [ -n "$EXPECTED" ] && [ -n "$ACTUAL" ] && [ "$EXPECTED" != "$ACTUAL" ]; then printf "\n  ⚠ BRANCH MISMATCH: expected \"%s\" but on \"%s\"\n\n" "$EXPECTED" "$ACTUAL"; fi'
```

Adapt: Replace `CURRENT.md` with whatever your session state file is called.

---

## Stop — quality gate at end of session

**What it does:** Runs a check script before Claude stops.

**Why:** Catches things that should be captured in docs or rules before the session ends.

```bash
bash scripts/golden-rules-check.sh
```

Adapt: Replace with `npm run test`, `npm run lint`, or any end-of-session validation.

---

## PreToolUse — warn before editing high-risk files

**What it does:** Intercepts Edit/Write calls and warns before touching files that have dangerous dependencies.

**Pattern 1 — schema sync warning (di.iiii specific):**  
If editing a shared schema file, remind Claude to update the CJS mirror or the server crashes on deploy.

```bash
bash -c 'FILE="${CLAUDE_TOOL_INPUT_FILE_PATH:-}"; [[ -z "$FILE" ]] && exit 0; echo "$FILE" | grep -qE "src/shared/.*Schema\.js$" && printf "\n  ⚡ SCHEMA SYNC REQUIRED\n  Also update the .cjs mirror in shared/\n\n"; exit 0'
```

**Pattern 2 — vite config warning (di.iiii specific):**  
If editing vite.config.js, remind about the three-vendor chunk.

**Generic pattern — warn before any high-risk file:**
```bash
bash -c 'FILE="${CLAUDE_TOOL_INPUT_FILE_PATH:-}"; [[ -z "$FILE" ]] && exit 0; echo "$FILE" | grep -qE "(config\.js|\.env|Dockerfile|migrate)" && printf "\n  ⚡ High-risk file: %s\n  Double-check before saving.\n\n" "$FILE"; exit 0'
```

---

## PostToolUse — auto-lint after JS edits

**What it does:** Runs ESLint on any JS/JSX file immediately after Claude edits it. Blocks with exit 2 if lint fails.

**Why:** Catches lint errors at the point of edit, not at commit time.

```json
{
  "matcher": "Edit|Write",
  "hooks": [{
    "type": "command",
    "asyncRewake": true,
    "statusMessage": "Linting...",
    "command": "bash -c 'FILE=\"${CLAUDE_TOOL_INPUT_FILE_PATH:-}\"; [[ -z \"$FILE\" ]] && exit 0; echo \"$FILE\" | grep -qE \"\\.(js|jsx|cjs|mjs)$\" || exit 0; echo \"$FILE\" | grep -q \"node_modules\" && exit 0; RESULT=$(npx eslint \"$FILE\" 2>&1); CODE=$?; [[ $CODE -eq 0 ]] && exit 0; printf \"\\n  ✗ Lint failed:\\n%s\\n\" \"$RESULT\"; exit 2'"
  }]
}
```

Adapt: Change `eslint` to your linter (`biome`, `oxlint`, etc.).

---

## PostToolUse — high-signal file reminder

**What it does:** After editing auth/DB/config files, reminds Claude to capture any non-obvious findings.

**Why:** Hard-won knowledge gets lost between sessions. This prompts capture in the moment.

```bash
bash -c 'FILE="${CLAUDE_TOOL_INPUT_FILE_PATH:-}"; [[ -z "$FILE" ]] && exit 0; echo "$FILE" | grep -qE "(auth|session|db\.js|migrate|config\.js|Dockerfile)" && printf "\n  ● High-signal file edited: %s\n    If this revealed something non-obvious, capture it.\n\n" "$FILE"; exit 0'
```

---

## PostToolUse — sync derived files

**What it does:** After editing a canonical file, auto-runs the sync script.

**Why:** Keeps generated/derived files in sync without manual steps.

```bash
bash -c 'FILE="${CLAUDE_TOOL_INPUT_FILE_PATH:-}"; [[ -z "$FILE" ]] && exit 0; echo "$FILE" | grep -q "AGENTS.md" || exit 0; npm run docs:ai:sync --silent 2>&1; exit 0'
```

Adapt: Change the file matcher and sync command for your project's derived files.

---

## Stop — auto-backup global config to un-di (global, not project)

**What it does:** At the end of every session, diffs `~/.claude/settings.json` and `~/.claude/CLAUDE.md` against the snapshots in `un-di/templates/global-*`. If either drifted, copies the live file over the snapshot, commits, and pushes — no manual step.

**Why:** `~/.claude/settings.json` and `~/.claude/CLAUDE.md` aren't version-controlled by Claude Code itself. Without this, a wipe/reinstall silently loses every bit of global tuning (minimal MCP, permissions, personal preferences). This hook makes the backup self-maintaining instead of relying on remembering to re-copy files after every tweak.

Lives in `~/.claude/settings.json` (global, not any project's `.claude/settings.json`):
```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash /home/nooo/un-di/templates/sync-global-config.sh",
            "async": true,
            "statusMessage": "Syncing global config backup..."
          }
        ]
      }
    ]
  }
}
```

Script: `templates/sync-global-config.sh` — `cmp` both files, copy+`git commit`+`git push` only if something actually changed (no-op, no commit noise, on sessions where nothing changed).

**Tradeoff, explicitly accepted:** this pushes to GitHub unattended on every session where the global config changed, with no per-run confirmation. That's normally something to pause on (push = visible to others / hard to silently reverse), but here the target is the user's own backup repo and the whole point is "don't make me remember to do this" — so it was deliberately approved as the exception. If you ever want to dial it back: copy-and-commit-only (drop `git push`, run it yourself via a command) or copy-only (drop git entirely) are the two safer variants.

**Path is hardcoded** to `/home/nooo/un-di` — this hook is machine-specific, not something to copy into a new project's `.claude/settings.json`.
