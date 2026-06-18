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
