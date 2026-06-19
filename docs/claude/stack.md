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
External tool connectors via Model Context Protocol. Heavy — every configured server injects its tool schema into every turn, even when unused. There is no live "load mid-task when needed" mode — servers are fixed for the whole session at startup. The real lever is **scope**: keep global minimal, put servers only where they're actually used.

`mcpServers` is **not** a valid `settings.json` field. Configure it in a project-root `.mcp.json`:
```json
{
  "mcpServers": {
    "context7": { "command": "npx", "args": ["-y", "@upstash/context7-mcp"] }
  }
}
```
Then approve it in that project's `.claude/settings.json` so it loads without a prompt:
```json
{ "enabledMcpjsonServers": ["context7"] }
```

`~/.claude/settings.json` (global) should normally have **no MCP servers** — anything global loads in every session of every project, including ones that never touch it. di.iiii has `context7` (library docs) and `playwright` (browser verification) scoped this way in `di.iiii/.mcp.json` — confirmed actually used there (UI verification, auth review), not just installed by default.

**Rule:** few MCPs, many Commands, and project-scoped by default. Pin one MCP per external system, write thin Commands that orchestrate them. Global MCP is the exception, not the starting point.

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
| Plugins | none | `frontend-design`, `security-guidance` |
| MCP | none (minimal by default) | `context7`, `playwright` via `.mcp.json` |
| defaultMode | auto | auto |

Updated 2026-06-19: global MCP (`context7`, `playwright`) and the GitHub MCP were removed from `~/.claude/settings.json`. di.iiii had unused `sqlite`/`serena` MCP servers dropped earlier (`chore: drop unused sqlite/serena MCP servers from settings`) and the still-used `context7`/`playwright` moved from global into `di.iiii/.mcp.json`, scoped to that project only.
