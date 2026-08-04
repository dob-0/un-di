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

**Anything visual must be SEEN before it is reported.** Schema checks, type validation and
"it loads without errors" prove nothing about whether it reads. If this machine cannot render
it (no WebGL, no browser, no display), stop at the FIRST unit — one page, one scene, one
component — say plainly that I can't see it, and ask for a screenshot before generating the
rest. Never scale an unlooked-at thing to N copies, and never let a report read as delivered
when the visual check is missing.

## Run parallel agents when the work is wide

Don't wait to be asked. When a task has several independent strands — a design pass, an
audit, a survey across files, competing approaches worth comparing — launch parallel agents
in one message and synthesise their returns yourself. Standing permission; no need to check
in first.

Judgement, not reflex: one file, one obvious edit, one lookup → just do it. Delegating a task
smaller than the briefing costs more than it saves.

Agents propose; I still verify. Their output is a draft to be checked against the real thing,
never something to report as done on their word — the SEEN rule above applies to their work
exactly as it applies to mine.

## Primary project

`/home/nooo/di.iiii` — XR authoring platform (di-studio.xyz).
- Repo: `dob-0/di.iiii` on GitHub
- Branch flow: `dev → main` (source). Deploy is GitHub Actions SSHing into a Hetzner VPS and restarting Docker Compose (moved off cPanel 2026-07-15): push `dev`→`.github/workflows/deploy-vps-staging.yml`→`staging.di-studio.xyz`, push `main`→`deploy-vps.yml`→`di-studio.xyz`. `publish-cpanel-prebuilt-v2.yml`/`cpanel-staging`/`cpanel-production` are legacy fallback only — see `docs/deploy/LIVE_DEPLOY.md` for current deploy truth
- Backend runs on port 4000, frontend on 5173, full Docker stack on 8080
- High-trust project: full dev workflow is pre-approved in project settings

## Role routing shorthand (di.iiii)

- CSS/layout → UI/UX Engineer (`docs/ai/roles/ui-ux-engineer.md`)
- Three.js/XR → 3D/Viewport Engineer
- serverXR/auth/db → Backend/API Engineer
- shared schema/op-log → Schema/Protocol Engineer
- nodeRegistry/graph → Node System Engineer
- XR experience/spatial UX/exhibition design → XR Creator (`docs/ai/roles/xr-creator.md`)

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
