# Done

Items from NOTES.md that have been turned into real Claude config changes.

---

- **Permission prompt behavior** — set `defaultMode: auto` globally (was only in di.iiii); added explicit "when to pause" rules to global CLAUDE.md: proceed on safe ops, pause on destructive/visible/ambiguous tasks, one-sentence confirm only.

- **Credit burn audit (2026-06-19)** — went looking for where Claude sessions were wasting tokens/credits. Found and fixed:
  - 5 stale git worktrees in di.iiii (`tune-claude-config`, `zany-noodling-pudding`, `ethereal-nibbling-hartmanis`, `fix-rotate-modal-regression`, `strip-unused-mcp`) — all already merged into `dev`, just left checked out. Removed with `git worktree remove`. Stale worktrees are a real risk: an agent pointed at one re-derives full context and burns a fresh session on work that's already done.
  - `context7` and `playwright` MCP servers were in `~/.claude/settings.json` (global) — loading into every session of every project, not just di.iiii where they're actually used. Moved them to `di.iiii/.mcp.json` (project-scoped), approved via `enabledMcpjsonServers` in di.iiii's `.claude/settings.json`. Global settings.json is now just `{ "theme": "dark", "defaultMode": "auto" }`.
  - Confirmed `frontend-design`/`security-guidance` plugins and the di.iiii agent role files (`backend.md`, `viewport.md`, etc.) were already correctly scoped and in active use — left alone. Not everything that looks expensive is waste.
  - Key finding to remember: Claude Code has no live "auto-load a tool only when the task needs it" mechanism — MCP servers are fixed for the whole session at startup. The only real lever is **scope** (global vs. project `.mcp.json`), not dynamic toggling. Docs updated: `docs/claude/stack.md` §5, `docs/claude/new-project.md` §6–7, new `templates/mcp.json`.

- **Global config backup, made automatic (2026-06-19)** — manual copy-paste backup wasn't going to stay current. Added a `Stop` hook in `~/.claude/settings.json` that runs `templates/sync-global-config.sh` at the end of every session: diffs the live global config against the un-di snapshot, and if it drifted, copies + commits + pushes automatically. Explicitly approved as the one case where unattended `git push` is fine — it only ever touches un-di, the user's own backup repo, and the entire point was removing the "remember to re-copy this" step. See `docs/claude/hooks.md` for the full writeup and the tradeoff being accepted.
