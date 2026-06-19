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
bash scripts/ollama-task.sh fast  "..."   # dob-fast  — quick Q&A
bash scripts/ollama-task.sh deep  "..."   # dob-deep  — architecture
bash scripts/ollama-task.sh coder "..."   # qwen3-coder:30b — logic/tests
```
