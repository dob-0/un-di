# un-di

AI workspace for Gevorg Aram Grigoryan (`dob_`).

Three purposes:
1. **Knowledge base** — docs any AI reads to understand the context, projects, and working style
2. **AI research** — findings on tools, models, workflows, capabilities
3. **Starter kit** — templates and patterns for new projects, proven in di.iiii

## Structure

```
docs/
  context/
    me.md           — who I am, background, working style (read this first)
    di-iiii.md      — di.iiii project context, stack, AI workflow rules
  claude/
    stack.md        — Claude Code five-layer architecture reference
    hooks.md        — hook patterns with explanations, proven in di.iiii
    new-project.md  — checklist for setting up a new project from scratch
  ai-research/
    ai-workflow-2026.md  — research on AI workflows, context engineering, tools

templates/
  project-settings.json   — base .claude/settings.json for any new project
  commands/
    ship.md         — commit and push
    branch.md       — create feature branch
    stack.md        — check service status
    live.md         — pre-show readiness check
  agents/
    frontend.md     — frontend engineer agent
    backend.md      — backend engineer agent
    qa.md           — QA/test engineer agent
    security.md     — security auditor agent

NOTES.md    — open items / backlog
DONE.md     — completed config changes
```

## How to use this for a new project

1. Read `docs/claude/new-project.md` — full checklist
2. Copy `templates/project-settings.json` → `.claude/settings.json` in the new repo
3. Copy relevant commands from `templates/commands/` → `.claude/commands/`
4. Copy relevant agents from `templates/agents/` → `.claude/agents/` (adapt as needed)
5. Write a `CURRENT.md` at repo root — this is the highest-leverage AI tool
6. Write an `AGENTS.md` or `CLAUDE.md` with routing rules and non-negotiables

## Working in this repo

New ideas and friction points go in `NOTES.md`. We review together, turn each item into a concrete change, then move it to `DONE.md`.
