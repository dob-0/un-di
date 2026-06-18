# Claude Code Full Stack

Five layers, from cheapest to heaviest:

## 1. CLAUDE.md
Persistent rules loaded every session. Free. Lives in repo root or `~/.claude/CLAUDE.md` for global.

## 2. Commands (Skills)
Reusable workflows in `.claude/commands/<name>.md`. Cost ~30–50 tokens until invoked.  
Triggered via `/name` or auto-invoked if Claude matches the task to the description.

Key frontmatter:
```yaml
---
allowed-tools: Bash(git add:*), Bash(git commit:*)
description: What this command does — used for auto-invocation matching
---
```

Inline command execution: prefix a line with `!` to run it and inject the output.  
Example: `- Branch: !`git branch --show-current``

**Use for:** repeated workflows, deploy, git ops, style enforcement, domain expertise.

## 3. Hooks
Event-driven shell commands in `.claude/settings.json`. Zero model tokens.

Events: `PreToolUse`, `PostToolUse`, `SessionStart`, `Stop`, `FileChanged`, `PermissionDenied`

Handler types: `command` (shell), `prompt` (LLM), `http` (POST), async variants.

PreToolUse hooks can modify tool arguments before execution via `updatedInput`.  
`asyncRewake: true` lets long-running hooks wake Claude when done.

**Use for:** auto-lint after edits, safety warnings, quality gates, session context injection.

## 4. Subagents (Agents)
Isolated context windows with their own system prompts, tools, and optional model override.  
With `isolation: worktree` they get their own git branch — enables parallel edits without conflicts.

Built-in types: `Explore` (read-only fast), `Plan` (architect), `claude` (general).

**Use for:** security audits, parallel research, preventing context bloat.

## 5. MCP Servers
External tool connectors via Model Context Protocol. Heavy — a 5-server setup can cost 50k+ tokens upfront.

Configure in `settings.json` under `mcpServers`. Currently configured globally:
- `github` — PRs, issues, repos (HTTP via api.githubcopilot.com, token in settings.local.json)
- `context7` — up-to-date library docs (Three.js, React, etc.)
- `playwright` — browser automation

In di.iiii project settings:
- `sqlite` — direct DB queries on di.db

**Rule:** few MCPs, many Commands. Pin one MCP per external system, write thin Commands that orchestrate them.

## Architecture principle

```
CLAUDE.md    → persistent context and rules
Commands     → reusable workflows, invoked explicitly or auto-matched
Hooks        → enforce things automatically without model tokens
Agents       → isolate heavy or parallel work
MCP          → connect external systems
```

## Current setup

| Layer | Global | di.iiii |
|---|---|---|
| CLAUDE.md | `~/.claude/CLAUDE.md` | `AGENTS.md` (canonical) |
| Commands | none | `/ship`, `/branch`, `/stack`, `/live` |
| Hooks | none | SessionStart, Stop, PreToolUse, PostToolUse |
| MCP | github, context7, playwright | + sqlite |
| defaultMode | auto | auto |
