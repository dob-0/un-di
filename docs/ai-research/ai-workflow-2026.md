# AI Workflow Research — 2026

Findings from session on 2026-06-18.

## Key concept: Context Engineering

The defining AI skill of 2026. Designing what information a model receives, how it is structured, and when it enters the context window. A well-engineered context = fewer retries, better first passes, less wasted token spend.

## LLM Wiki vs RAG

For focused knowledge bases, a structured markdown wiki living directly in the context window cuts token usage by up to 95% vs naive RAG/document loading. This is exactly what `un-di/docs/` is.

Rule: keep the wiki small, current, and structured. Staleness = hallucination.

## Claude Code stack (five layers)

From cheapest to heaviest:

| Layer | What it is | Token cost |
|---|---|---|
| CLAUDE.md | Persistent rules, loaded every session | Always on |
| Commands/Skills | `.claude/commands/*.md` — reusable workflows | ~30–50 tokens until invoked |
| Hooks | Event-driven shell commands in settings.json | Zero tokens |
| Agents/Subagents | Isolated context windows, optional worktree isolation | Heavy |
| MCP servers | External tool connectors (GitHub, DB, browser, etc.) | 50k+ tokens for 5 servers |

Rule: **few MCPs, many Skills**. Skills are cheap. MCP is expensive upfront.

## Tool choices (2026)

- **Claude Code** — autonomous terminal agent, best for shipping complete features (~70% task completion on SWE-bench)
- **Cursor** — inline edits, staying in flow in the editor (~55% on SWE-bench)
- These are complementary, not competing. Use each for what it's good at.

## MCP servers worth having

- `context7` — live library docs (Three.js, React, etc.) — critical for di.iiii
- `github` — PRs, issues, repo ops — use HTTP approach via `api.githubcopilot.com`
- `playwright` — browser automation, UI testing
- `sqlite` — direct DB queries (already in di.iiii project settings)

Avoid adding MCP for systems you don't actively use — each server costs tokens on every session.

## Hooks — best patterns

- `SessionStart` — inject project context, check branch alignment
- `PreToolUse` on Edit/Write — warn before touching high-risk files (schema, vite config)
- `PostToolUse` on Edit/Write — auto-lint JS files, sync dependent files
- `Stop` — run quality checks before ending session

## Boris Cherny's workflow (Claude Code creator)

From the 2026 full guide video:

- **5 parallel terminals** — multiple Claude instances running simultaneously, system notifications for when any instance needs input
- **Plan mode first** — every task starts in Plan mode. Refine the plan until it's ideal, then enable auto-approve for code changes. If you need to change the code, first change the plan.
- **Self-review loop** — always ask Claude to check its own work after finishing. This feedback cycle increases final quality 2-3x.
- **Shared CLAUDE.md** — team maintains one CLAUDE.md and documents every edge case where Claude defaults fail. Not rules for the sake of rules — documented failures.

Takeaway: slow down before coding (plan), speed up during coding (auto-approve + parallel), always close the loop (self-review).

## Agents — when to use

- `Explore` — fast read-only search, finding files/symbols. Never for analysis.
- `Plan` — architecture decisions before implementation
- `claude` (general) — multi-step tasks, parallel research, context isolation
- `isolation: worktree` — parallel edits on separate git branches without conflicts
