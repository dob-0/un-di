# Personal Claude Code Preferences

## Default behavior

- Responses: concise. No trailing summaries or recaps of what was just done.
- Comments in code: only when the WHY is non-obvious. No docstrings, no narration.
- No emojis unless asked.
- When editing files in di.iiii: read CURRENT.md before the first edit of any session.

## When to pause and check in

Proceed without asking for: reading files, running tests/lint, git status/diff/log, standard dev operations already in the allow-list.

Pause and confirm before: destructive ops (delete files, force push, drop DB), actions visible to others (push to shared branches, create PRs, send messages), and any task where the scope or interpretation is genuinely ambiguous — one sentence to confirm is enough, not a list of options.

Do not ask permission mid-task for things already implied by the original request.

## Primary project

`/home/nooo/di.iiii` — XR authoring platform (di-studio.xyz).
- Repo: `dob-0/di.iiii` on GitHub
- Branch flow: `dev → staging → main`
- Backend runs on port 4000, frontend on 5173, full Docker stack on 8080
- High-trust project: full dev workflow is pre-approved in project settings

## Role routing shorthand (di.iiii)

- CSS/layout → UI/UX Engineer (`docs/ai/roles/ui-ux-engineer.md`)
- Three.js/XR → 3D/Viewport Engineer
- serverXR/auth/db → Backend/API Engineer
- shared schema/op-log → Schema/Protocol Engineer
- nodeRegistry/graph → Node System Engineer

## Local delegation (free, no API cost)

When Ollama is running, use it for analysis/docs/planning before escalating to Claude API:
```bash
bash scripts/ollama-task.sh fast    "..."   # dob-fast (qwen3:8b)      — quick Q&A
bash scripts/ollama-task.sh deep    "..."   # dob-deep (qwen3:8b)      — architecture
bash scripts/ollama-task.sh coder   "..."   # qwen2.5-coder:7b         — logic/tests
bash scripts/ollama-task.sh general "..."   # qwen2.5:7b               — mixed reasoning
bash scripts/ollama-task.sh tiny    "..."   # qwen2.5-coder:1.5b       — symbol search
```

## Running Claude Code itself on a local model

`ollama launch claude --model dob-fast` (or any pulled tag) repoints the `claude` CLI at a
local Ollama model instead of the real API for that session; `ollama launch claude --restore`
reverts. Local 7-8B models cannot reliably judge ambiguity inside an agentic harness — given a
vague prompt they will hallucinate a plausible-looking tool call (e.g. invent a fake file path
and write to it) instead of asking what's wanted. This rule mitigates it for any model running
under `claude` (real or local), but only give local-model sessions fully explicit, narrow,
already-scoped tasks — never vague prompts — and prefer throwaway directories.

**If the user's message is a single word, a greeting, or otherwise lacks a concrete, specific
task, do not call any tool. Ask exactly one clarifying question instead.**
