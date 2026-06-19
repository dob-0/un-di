# Antigravity Full Stack

An overview of the Google Antigravity (AGY) customization, orchestration, and interface layers:

## 1. Rules (`AGENTS.md`)
Global or project-scoped guidelines and instructions.
- **Project-scoped:** Append to `.agents/AGENTS.md` in the project root.
- **Global:** Append to `~/.gemini/config/AGENTS.md`.

## 2. Skills (Reusable Capabilities)
Custom toolsets and workflow guidelines located in a `skills/<skill_name>/` folder.
- **Structure:** Must contain a `SKILL.md` file with YAML frontmatter:
  ```yaml
  ---
  name: skill-name
  description: Brief summary of when this skill should be activated.
  ---
  ```
  Can contain subfolders like `scripts/`, `examples/`, `resources/`, and `references/`.
- **Location:** Placed under `.agents/skills/` (project-scoped) or `~/.gemini/config/skills/` (global). Non-standard locations are registered via `skills.json`.

## 3. Subagents (Orchestration & Parallelism)
Specialized agent processes spawned dynamically for complex tasks.
- **Command:** `define_subagent` (to register a new type of subagent) and `invoke_subagent` (to launch a defined subagent).
- **Workspace Modes:**
  - `inherit` (default) - uses the same workspace.
  - `branch` - creates an isolated workspace branch/clone.
  - `share` - shares the parent repository (git worktree style) for independent branching.
- **Built-in Agents:** `self` (inherits full configuration), `research` (read-only exploring).

## 4. Artifacts (Structured User-facing Documents)
Rich markdown files presented to the user, saved in the conversation directory (`<appDataDir>/brain/<conversation-id>/`).
- **Formatting features:**
  - Alerts: `[!NOTE]`, `[!TIP]`, `[!IMPORTANT]`, `[!WARNING]`, `[!CAUTION]`.
  - Embedded media: `![caption](/absolute/path/to/media)`.
  - Carousels: Sequential slides using ````carousel ... <!-- slide --> ... ````.
  - Mermaid diagrams.

## 5. Slash Commands (Shortcut Workflows)
UI shortcuts recommended to the user to trigger specific agent states or routines:
- `/goal` - for long-running, thorough tasks.
- `/schedule` - for cron tasks or timers.
- `/grill-me` - for interactive planning interviews.
- `/learn` - to persist corrected behaviors.

## 6. Background Tasks & Scheduling
Orchestrating long-running commands and cron/timer jobs.
- **Timer/Cron:** `schedule` tool (one-shot with liveness conditions or recurring cron schedules).
- **Management:** `manage_task` (actions: `list`, `kill`, `status`, `send_input`).
