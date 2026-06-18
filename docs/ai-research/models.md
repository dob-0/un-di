# Model Routing Guide

Which model for which task. Applies to all projects.

## Decision tree

```
Is it analysis, docs, or planning (no file edits needed)?
  → Ollama (free, local)

Does it need file edits?
  → Single file, simple change?     → Haiku
  → Multi-file, feature work?       → Sonnet  ← default
  → Architecture, security, schema? → Opus
```

## Ollama (free, always try first)

Run via `bash scripts/ollama-task.sh <model> "..."` in di.iiii.

| Model | Command | Best for |
|---|---|---|
| `dob-fast` | `fast` | Quick Q&A, docs questions, project context |
| `dob-deep` | `deep` | Architecture analysis, deep planning |
| `qwen3-coder:30b` | `coder` | Logic reasoning, test design, code review |

Rule: if you don't need file edits, use Ollama first. Only escalate to Claude API when writing code.

## Haiku

Fast and cheap. Use for:
- Single-file edits
- Lint fixes
- Small test additions
- CSS/layout tweaks
- Straightforward refactors

In di.iiii agents: `ux`, `qa`

## Sonnet — default

Best balance of capability and cost. Use for:
- Feature work across multiple files
- Bug fixes requiring context
- API/backend changes
- Three.js / XR work
- Most day-to-day coding

In di.iiii agents: `viewport`, `backend`, `nodes`, `infra`

## Opus

High capability, high cost. Reserve for:
- Architecture decisions and non-negotiables review
- Auth and security audit
- Schema / CRDT contract changes
- Any decision that is hard to reverse or affects data integrity
- Plan mode — think at Opus level, execute at Sonnet level

In di.iiii agents: `schema`, `security`

## Boris Cherny's pattern (Claude Code creator)

> Start every task in Plan mode (Opus-level thinking). Refine the plan until it's ideal. Then switch to auto-approve and execute (Sonnet). Always ask Claude to review its own work at the end — 2-3x quality improvement.

In practice: `/plan` → approve → execute → self-review.
