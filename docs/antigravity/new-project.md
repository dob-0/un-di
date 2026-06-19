# New Project Setup Checklist (Antigravity)

Follow this checklist to configure a new workspace for Google Antigravity (AGY).

## 1. Workspace Customizations Root (`.agents/`)
Create a `.agents/` directory in the root of the repository. This is the canonical folder for all project-level customizations.

## 2. Project-Scoped Rules
Create `.agents/AGENTS.md` to define project-specific coding guidelines, architecture rules, and non-negotiables. Antigravity reads this automatically at session startup.

## 3. Custom Skills
If the project requires specialized workflows, helper scripts, or domain documentation:
1. Create a subdirectory under `.agents/skills/<skill_name>/`.
2. Add a `SKILL.md` file with a descriptive `name` and `description` in its YAML frontmatter.
3. Add supporting scripts or references in `scripts/`, `references/`, etc.

If sharing skills across multiple projects:
- Reference their paths in `.agents/skills.json`.

## 4. Workspace Flow & Subagents
When delegating complex tasks (e.g. database schema migrations, end-to-end QA):
1. Define a subagent using `define_subagent` with appropriate system prompts and enabled write/MCP tools.
2. Launch it via `invoke_subagent` with the `share` workspace mode to leverage git worktrees for parallel execution.

## 5. Session State File (`CURRENT.md`)
Create a `CURRENT.md` at the project root to track active branches, recent commits, current status, and known bugs/fixes. This provides high-leverage context that saves API tokens.
