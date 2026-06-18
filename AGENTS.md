# AGENTS

Start here. Every AI reads this first, every session, no exceptions.

---

## Who you're working with

**Gevorg Aram Grigoryan** (`dob_`) — artist and director who codes. Background in theater direction, multimedia art, electronic art since 2012. Not a traditional software engineer — programming is a tool for artistic and technical vision. Based in Armenia. Languages: Armenian, English, Russian, Dutch.

Full profile: `docs/context/me.md`

---

## What this repo is

`un-di` is the primary AI workspace. Three roles:

1. **Knowledge base** — `docs/` contains context docs any AI reads to understand Gevorg, his projects, and how to work with him. Not Claude-specific — Cursor, ChatGPT, and others read it too.
2. **AI research** — findings on tools, models, workflows, and capabilities.
3. **Starter kit** — templates and patterns for new projects, proven in di.iiii.

This is not a code project. The output is documentation and configuration.

---

## Primary project

**di.iiii** — open-source XR studio_network platform (di-studio.xyz). The software layer of an active artistic practice producing installations, performances, and residencies across Armenia and Germany. Full context: `docs/context/di-iiii.md`

---

## How to work here

**Documents are the product.** Treat formatting and clarity as first-class concerns. Markdown only.

**For config/tuning items:**
1. New ideas go into `NOTES.md` under Open items
2. We review together — each item becomes a concrete change: settings.json, hook, keybinding, memory file, CLAUDE.md edit
3. Done items move to `DONE.md` with a note of what was changed

**For research:**
Write findings into `docs/ai-research/`. Summaries over transcripts — what was learned, not what was said.

**For new project setup:**
Read `docs/claude/new-project.md`. Templates live in `templates/`.

---

## Working style

- Concise responses. No trailing summaries, no recaps of what was just done.
- No emojis.
- Proceed on safe/routine work. Pause before destructive or ambiguous things — one sentence to confirm, not a menu of options.
- Write the thing. Don't describe it.

---

## Structure

```
docs/
  context/        me.md, di-iiii.md
  claude/         stack.md, hooks.md, new-project.md
  ai-research/    ai-workflow-2026.md

templates/
  project-settings.json
  commands/       ship, branch, stack, live
  agents/         frontend, backend, qa, security

NOTES.md          open backlog
DONE.md           completed changes
AGENTS.md         ← you are here
CLAUDE.md         Claude Code specific overrides
README.md         human-facing summary
```

---

## Global Claude Code setup (already configured)

- `defaultMode: auto` — no permission prompts for routine ops
- MCP: GitHub (HTTP, real token), Context7 (live library docs), Playwright (browser automation)
- Global permissions: git, npm, gh, curl, find, grep, tmux, python3, kill, pkill
- Full reference: `docs/claude/stack.md`
