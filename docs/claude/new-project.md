# New Project Setup Checklist

Use this when starting any new project. Everything here has been proven in di.iiii.

## 1. Project settings — `.claude/settings.json`

Copy from `templates/project-settings.json`. At minimum set:
- `defaultMode: auto` — stops Claude asking permission for routine ops
- `permissions.allow` — whitelist your common safe commands
- `hooks` — at least SessionStart (state reminder) and PostToolUse lint

## 2. Session state file — `CURRENT.md`

Create a `CURRENT.md` at repo root (≤50 lines). Fields:
```
active_branch: <name>

## Last commit
<hash> — <message>

## What works
- ...

## What is broken / open
- ...

## Known fixes — check here before investigating
| Symptom | Root cause | Fix | File |
```

This is the single most valuable AI productivity tool in di.iiii. Claude reads it at session start and avoids re-investigating already-solved problems.

## 3. Commands — `.claude/commands/`

Copy from `templates/commands/`. Minimum set:
- `ship.md` — stage, commit, push
- `branch.md` — create feature branch from main/dev
- `stack.md` — check service status (adapt ports)

Add `live.md` if the project has live performance or demo scenarios.

## 4. Agents — `.claude/agents/`

Copy from `templates/agents/` and adapt. Agents make sense when:
- The codebase has distinct domains that shouldn't cross-contaminate
- You want different models for different task types (haiku for small edits, opus for security)
- You do parallel work that would pollute a shared context

Minimum useful team for a fullstack project: `frontend`, `backend`, `qa`, `security`.

## 5. CLAUDE.md or AGENTS.md

Write a short routing guide:
- What to read first (session state file)
- Which role/agent owns which part of the codebase
- Non-negotiables (secrets, schema rules, etc.)
- Token efficiency guidance (when to use local models vs API)

Keep it under 80 lines. The role cards / agent files hold the detail.

## 6. MCP

Add only what you actively use:
- `context7` — always useful for library docs
- `sqlite` — if you have a local SQLite DB
- `github` — if you need PR/issue access from within Claude
- `playwright` — if you do UI testing

Token cost: each MCP server loads on every session. Keep it minimal.

## 7. Global settings

These are already set globally (in `~/.claude/`):
- `defaultMode: auto`
- GitHub MCP (with real token)
- Context7 MCP
- Playwright MCP
- Cleaned-up global permission list

You only need project-level settings for project-specific things.

## Order of operations for a new session (Boris Cherny pattern)

1. Read `CURRENT.md` — know the state before touching anything
2. Start in **Plan mode** — define the task clearly before any code changes
3. Refine the plan until it's right, then enable auto-approve
4. After finishing — ask Claude to review its own work (2-3x quality improvement)
5. Update `CURRENT.md` before stopping
