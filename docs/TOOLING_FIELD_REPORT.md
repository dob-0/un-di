# Field report — what can be modded, what's out there, what to do

Researched 2026-08-06 across four parallel strands: official Claude Code surfaces, the
community ecosystem, terminal/desktop tooling, and rival agentic CLIs. Claims marked
**[verified]** were checked against the local binary (`2.1.222`) or this machine, not just
read in a doc. Everything else is documentary — no tool below has been installed or looked at.

---

## 0. TL;DR — the eight things worth doing

| # | Do | Why | Cost |
|---|---|---|---|
| 1 | Fix `~/.claude/keybindings.json` | It's in the wrong schema — **both** your shortcuts are dead **[verified]** | 5 min |
| 2 | `dnf install fzf zoxide eza fd-find git-delta lazygit btop` | Cheapest daily payoff on the list | 10 min |
| 3 | Install **ghostty** (in `terra`, 1.3.1) **[verified]** | Unlocks inline images — the difference between "the agent describes the chart" and you seeing it | 15 min |
| 4 | `Stop`/`Notification` hooks → `notify-send` + di-bo Telegram | You already have both; agent-finished signal costs nothing new | 30 min |
| 5 | Custom theme (`~/.claude/themes/*.json`) + `spinnerVerbs` | Officially supported since 2.1.118; nobody knows it exists | 20 min |
| 6 | `subagentStatusLine` | Per-subagent rows in the agent panel — directly serves your fan-out habit | 1 h |
| 7 | `claude-monitor` (uv) | Only monitor doing 5h **and** official weekly **and** burn-rate-to-exhaustion | 10 min |
| 8 | A `/review` skill that emits findings without editing | The single best idea in the rival field | 1 h |

**Do not** install waybar / mako / eww / ags. You are on **KDE Plasma, Wayland [verified]** —
those are wlroots/Hyprland tools and mako actively fights Plasma for the notification D-Bus name.

---

## 1. Your current state **[verified]**

- KDE Plasma on Wayland, bash, `TERM=xterm-256color`, no modern terminal emulator installed.
- Installed: `starship`, `tmux`, `bat`, `gum`, `glow`, `notify-send`, `rg`, `jq`.
- Missing: `fzf`, `zoxide`, `eza`, `fd`, `delta`, `lazygit`, `btop`, `yazi`, `atuin`, `zellij`.
- Plugins: only the official marketplace — `frontend-design` (user + di.iiii),
  `security-guidance`, `typescript-lsp` (di.iiii only).
- **No user-level subagents at all** (`~/.claude/agents/` empty) — every fan-out runs generic.
- `~/.claude` is **1.0 GB**: projects 371M, jobs 321M, security 278M.
- One custom command (`recap.md`). Two keybindings, both broken.

### 1.1 The keybindings bug

Your file:

```json
[ { "key": "ctrl+shift+r", "command": "/research" },
  { "key": "ctrl+shift+e", "command": "/recap" } ]
```

The real schema **[verified in binary: `bindings: w.array` of `{context, bindings: w.record}`]**:

```json
{
  "$schema": "https://www.schemastore.org/claude-code-keybindings.json",
  "bindings": [
    { "context": "Chat", "bindings": { "ctrl+e": "chat:externalEditor" } }
  ]
}
```

Three problems: no `bindings` wrapper, no `context`, and **actions must be `namespace:action`
IDs — slash commands are not bindable at all**. There is no `/research` command in
`~/.claude/commands/` either. 19 contexts exist (`Global, Chat, Autocomplete, Settings,
Confirmation, Tabs, Help, Transcript, HistorySearch, Task, ThemePicker, Attachments, Footer,
MessageSelector, DiffDialog, ModelPicker, Select, Plugin, Scroll`); namespaces include `app:`,
`chat:`, `history:`, `task:`, `transcript:`, `theme:`, `voice:`, `scroll:`.
Ctrl+C / Ctrl+D / Ctrl+M / Caps Lock can't be rebound. Run `claude --debug` to see it reject the file.

---

## 2. What can actually be modded — the official surface is much bigger than advertised

### 2.1 statusLine

Beyond `type`/`command`, the key takes **`padding`**, **`refreshInterval`** (min 1s, for idle
updates) and **`hideVimModeIndicator`** **[verified]**. Multi-line output, ANSI, and OSC 8
hyperlinks all work. `COLUMNS`/`LINES` arrive as env vars — `tput cols` does **not** work
because stdout is captured, not a tty. (Your script already falls back correctly.)

Payload fields you are **not** using yet: `effort.level` (`low|medium|high|xhigh|max`),
`thinking.enabled`, `fast_mode`, `agent.name`, `output_style.name`, `vim.mode`, `session_name`,
`pr.{number,url,review_state}`, `worktree.{name,branch,original_branch}`, `workspace.repo`,
`cost.{total_lines_added,total_lines_removed,total_api_duration_ms}`,
`context_window.current_usage.{cache_read_input_tokens,cache_creation_input_tokens}`,
`exceeds_200k_tokens` **[all verified present in binary]**.

Two semantics worth knowing: `used_percentage` is **input-only** (excludes output tokens), and
`exceeds_200k_tokens` tests a **fixed** 200k threshold regardless of your actual 1M window.

**`subagentStatusLine`** is a separate settings key that renders **one row per subagent** in the
agent panel **[verified]**. It receives `tasks[]` with `id, name, status, description, model,
effort, contextWindowSize, tokenCount, startTime, cwd`, and you emit one JSON line per row:
`{"id":"<task id>","content":"<row body>"}`. Given how much you fan out, this is the highest-value
unused surface on the whole list.

### 2.2 Hooks — 31 events, not 6 **[all 31 verified in binary]**

`SessionStart, Setup, SessionEnd, UserPromptSubmit, UserPromptExpansion, PreToolUse,
PermissionRequest, PermissionDenied, PostToolUse, PostToolUseFailure, PostToolBatch,
Notification, MessageDisplay, SubagentStart, SubagentStop, TaskCreated, TaskCompleted, Stop,
StopFailure, TeammateIdle, InstructionsLoaded, ConfigChange, CwdChanged, DirectoryAdded,
FileChanged, WorktreeCreate, WorktreeRemove, PreCompact, PostCompact, Elicitation,
ElicitationResult`

And **five handler types**, not just `command`: `command`, `http` (POST to a URL),
`mcp_tool`, `prompt` (runs a prompt), `agent` (runs a subagent). Per-hook fields include
`if` (a permission-rule filter like `"Bash(rm *)"`), `statusMessage` (spinner text), `once`,
`async`, and **`asyncRewake`** — background work that *wakes Claude when it exits*.

Universal output includes `systemMessage` and **`terminalSequence`** (OSC 0/1/2/9/99/777 or BEL)
— the sanctioned way to fire a desktop notification or set the terminal title from a hook.

The interesting ones for you:
- `MessageDisplay` → `displayContent` rewrites **what's on screen** while the transcript keeps the
  original. The only genuine "restyle the UI" hook.
- `PreToolUse` → `updatedInput` rewrites a tool call before it runs; `permissionDecision` gates it.
- `SessionStart` → `additionalContext`, `sessionTitle`, `watchPaths`, `reloadSkills`.
- `TeammateIdle`, `TaskCreated`/`TaskCompleted`, `SubagentStart` → the raw material for an
  external "which agent is waiting on me" board.
- Hooks can also live in **skill/agent frontmatter**, scoped to that skill's lifetime.

### 2.3 The TUI is themeable — this is the surprise

**Custom color themes since v2.1.118 [verified].** `~/.claude/themes/<slug>.json`, hot-reloaded:

```json
{ "name": "br-id-ge", "base": "dark",
  "overrides": { "claude": "#bd93f9", "permission": "#ff5555", "diffAdded": "#50fa7b" } }
```

Then `"theme": "custom:br-id-ge"`. Tokens include `claude` (brand accent — spinner + assistant
label), `text`, `subtle`, `permission` (dialog + permission-prompt borders), `planMode`,
`diffAdded`, `diffRemoved`, `userMessageBackground`, `success`, `error`, `warning`. Colors accept
`#rrggbb`, `rgb()`, `ansi256(n)`, `ansi:<name>`. Built-ins include daltonized and ANSI-only
variants. Given br_id_ge's colours-as-concept-actors design language, a matching terminal theme
is a real, cheap alignment.

**Spinner words are customizable [verified]:**

```json
{ "spinnerVerbs": { "mode": "append", "verbs": ["Crossing", "Inscribing", "Reading"] },
  "spinnerTipsEnabled": false }
```

`mode: "replace"` drops the built-ins entirely (the defaults start `Accomplishing, Actioning,
Actualizing, Architecting, Baking…` **[verified in binary]**). `spinnerTipsOverride` replaces
the rotating hint pool.

Other look keys **[verified]**: `tui: "fullscreen"`, `viewMode` (`default|verbose|focus`),
`syntaxHighlightingDisabled`, `prefersReducedMotion`, `showThinkingSummaries`,
`showTurnDuration`, `showMessageTimestamps`, `terminalProgressBarEnabled`,
`terminalTitleFromRename`, `vimInsertModeRemaps`, and **`footerLinksRegexes`** — clickable footer
badges built from regexes over turn output (e.g. `PROJ-\d+` → your issue tracker).

**Correction to a claim circulating in summaries:** `terminal.title`, `terminal.scrollbackLines`,
`keyBindings`, `terminalColumns` and `workspaceLayout` **do not exist** in the 2.1.222 schema, and
`statusLine` is not a `{{.Model}}` template. Those are hallucinated keys.

### 2.4 Skills, subagents, plugins

Skills frontmatter goes far past `name`/`description`: `allowed-tools`, `disallowed-tools`,
`model`, `effort`, `context: fork`, `agent`, `background`, `hooks`, `paths`, `shell`,
`disable-model-invocation`, `user-invocable`. Body substitutions include `$ARGUMENTS`, `$N`,
`${CLAUDE_SKILL_DIR}`, `${CLAUDE_PROJECT_DIR}` — and the last two also substitute **inside
`allowed-tools` Bash rules**, which is the trick for bundling a script that never prompts.

Subagent frontmatter: `tools`, `disallowedTools`, `model`, `permissionMode`, `maxTurns`, `skills`
(preloads whole skill bodies), `mcpServers`, `hooks`, **`memory`** (`user|project|local` →
persistent `~/.claude/agent-memory/<name>/`), `background`, `effort`, **`isolation: worktree`**,
`color`, `initialPrompt`. You have none of these defined — see §5.

---

## 3. Community ecosystem — what's worth installing

### Statusline
| Tool | Stars | Note |
|---|---|---|
| **ccstatusline** | ~12k | Widest widget set, TUI builder, powerline, session/weekly/cost/block timer |
| **CCometixLine** | ~3.4k | Rust binary — no node spawn per redraw, lowest latency |
| **claude-hud** | ~19.6k | Parses transcript JSONL for **live tool + subagent activity** — the one thing the official payload still doesn't expose |
| **claude-powerline** | ~1.1k | Plugin-native, explicit 5h-block + weekly segments |
| **cship** | ~321 | The only serious **starship-module bridge** — reuses your starship config |

Honestly: your hand-rolled script now does the core job (context, 5h, 7d, resets). The only real
reasons to switch are **claude-hud's live subagent activity** or **cship's starship reuse**.

### Usage / limits
- **claude-monitor** (`uv tool install claude-monitor`) — the recommendation. Consumes the
  official `rate_limits` payload for weekly, does 5h rolling windows, **burn-rate velocity and
  time-to-limit projection**, P90 limit auto-detection, and keeps history past Claude's 30-day
  cleanup. `--write-state --compact` feeds a bar without a second collector.
- **ccusage** (~17.7k) — historical analyzer, 5-hour blocks report. Not a forecaster.
- **sniffly** (Chip Huyen) — local web dashboard with **error and interruption-rate analysis**.
- **ai-usagebar** — waybar widget; wrong compositor family for you, but its TUI mode works.

### Sessions
**claude-code-viewer** (`npx @kimuson/claude-code-viewer`) — local web client, browse + resume
sessions, macOS/Linux only. **claude-code-log** — whole `~/.claude/projects/` → linked HTML
archive. Both local-only, no network. `ccundo`/`ccheckpoints` are superseded by native `/rewind`.

### Orchestration
**claude-squad** (~8.2k, Go TUI, tmux + worktree per agent) is the reference implementation of
the pattern you already run by hand. **container-use** (Dagger) if you want agents off your host.

### Flags — don't walk into these
- **Vibe Kanban** (27.7k) is **sunsetting**; **Crystal** (3.1k) is **deprecated** → closed-source
  Nimbalyst. Big stars, dead projects.
- **opcode/Claudia** (22.4k) has **still never shipped a binary** — build from source or skip.
- **Ruflo** (ex-claude-flow, 67.1k stars, 540 open issues, two rebrands) — README ≫ substance.
- **ccflare** / **claude-code-router** credential pools: multi-account rotation on subscription
  plans is a **ToS/ban risk**, not just a smell.
- **stfnRO's GNOME extension** (3★) reads `~/.claude/.credentials.json` and calls the Anthropic
  usage API. Local and plausible, but audit it before enabling — that's your live OAuth token.
- **Happy** (23.2k) mobile relay routes sessions through *their* sync server by default. Backend
  is in-repo — self-host it or don't use it for br_id_ge work.

---

## 4. Terminal & desktop — for KDE Wayland specifically

**Terminal.** You have none of the modern class. `ghostty` **1.3.1 is in `terra`**, `kitty`
**0.47.1** and `alacritty` **0.17.0** in `nobara`; wezterm isn't packaged **[all verified]**.
Take **ghostty** (native Wayland via GTK4, no XWayland, kitty graphics protocol, config you can
read in one screen) or **kitty** if you want the remote-control protocol (`kitten @`) for
scripting windows from inside a session. **Skip alacritty — no image support**, which is
disqualifying given the "must be SEEN" rule: with a graphics-protocol terminal, `chafa`, `viu`,
`timg`, `yazi` previews and matplotlib's kitty backend all render *actual images inline*.

**Notifications — the KDE-correct stack.** `notify-send` (installed) → Plasma's own service, which
already gives you urgency, history and DND. For an always-visible readout, a **Plasma 6 plasmoid**
or `conky` — not waybar. Push to phone: **ntfy** (self-hostable, and `claude-ntfy-hook` supports
**Allow/Deny answered from the phone**), or simply reuse **di-bo**, which already exists and adds
no infra. Trigger from the `Stop`/`Notification` hooks, not from terminal-activity heuristics —
the hook knows the difference between "printed a line" and "finished".

**Click-to-focus-the-terminal is genuinely hard on Wayland** — no `wmctrl -a`. It needs a KWin
script over D-Bus or `kdotool`. Treat as experimental, not a quick win.

**Multiplexer.** Keep tmux. Add `sesh` (best-in-class session switcher) and
`tmux-resurrect`+`continuum`. Zellij has the better agent story (`zjstatus`, and **`zellaude`**
which puts Claude activity indicators on tabs) but you'd adopt a churning plugin API.
Note: **OSC 8 hyperlinks are broken inside tmux** — clickable links in any statusline won't work
there.

**Dashboards — don't build an app.** A bash script emitting metrics, run under `viddy -n 5` in a
tmux pane, dressed with `gum style` (you have gum). Escalate to `sampler` YAML only if that's not
enough, and to textual/ratatui only if it becomes a real tool.

---

## 5. The best ideas from rival tools, and what you can have today

Ranked by daily impact, with the verdict for a Claude Code user:

| # | Idea | Where from | Verdict here |
|---|---|---|---|
| 1 | **Kanban of agents with a "Ready for Review" column** | Devin Desktop, Cursor, Warp | **Buildable** — `SubagentStart`/`TaskCreated`/`TaskCompleted`/`TeammateIdle` hooks write a state file; `viddy`+`gum` renders it |
| 2 | Two-level steering: queue → nudge → hard interrupt | Amp (`Enter Enter` / `Esc Esc`) | ❌ Not exposed |
| 3 | Context meter with the **compaction threshold adjustable in the tooltip** | Cline | Partial — meter yes, `PreCompact` can block but not tune |
| 4 | **Plan as an editable, approvable document** | Junie, Windsurf, Devin | **Buildable** — skill writes `plan.md`, `PreToolUse` denies Edit/Write until it's marked approved |
| 5 | Per-hunk keep/reject in a post-run review buffer | Zed `Review Changes` | ❌ Needs Anthropic |
| 6 | **Review as a non-mutating verb** | Codex `/review`, `amp review` | **Buildable and worth it** — a skill that diffs base branch and emits ranked findings, touching nothing |
| 7 | Always-visible cost per turn and per thread | Aider, Amp, OpenCode | **Free** — `cost.*` is already in your payload |
| 8 | Session as a URL — hand off, continue from phone | Amp, OpenCode `/share` | Buildable on the headless SDK; or just use di-bo |
| 9 | **Best-of-N racing in isolated worktrees** | Cursor `/best-of-n` | **Buildable** — subagents with `isolation: worktree`, then a diff-comparison pass |
| 10 | Follow mode (editor jumps to the file being edited) | Zed | ❌ No API |
| 11 | **Per-mode tool permissions + per-subagent model** | Roo/Kilo | **Native already** — subagent frontmatter `tools`/`model`/`permissionMode` |
| 12 | Accessibility themes (high-contrast, colorblind) | Copilot CLI `/theme` | **Native already** — `dark-daltonized`, `*-ansi`, custom themes |

**Standards to track.** **MCP 2026-07-28** is the big one: stateless HTTP core, and an extensions
framework that includes **MCP Apps** (mcp-ui) — the first sanctioned path to *server-rendered
interactive UI inside an agent client*. **ACP** (Zed, Devin) standardizes exactly the UI
vocabulary hooks can't express — diffs, plans, permission requests. **AGENTS.md** (60k+ repos) is
the nonproprietary CLAUDE.md; worth adding alongside, since un-di already has one.

---

## 6. Concrete next moves, in order

1. **Rewrite `keybindings.json`** into the real schema; decide what `ctrl+shift+r` should actually
   do (it can't be a slash command) — or write the missing `/research` command and bind something
   legal instead.
2. **`dnf install fzf zoxide eza fd-find git-delta lazygit btop`**, then **ghostty from terra**.
3. **`Stop` + `Notification` hooks** → `notify-send` locally, di-bo to the phone, one distinct
   `pw-play` tone per state.
4. **A custom theme** in br_id_ge's palette + `spinnerVerbs` in the rite's vocabulary.
5. **`subagentStatusLine`** — one row per subagent with model, effort, tokens, status.
6. **`claude-monitor`** for burn-rate projection the statusline can't do.
7. **Two skills**: a non-mutating `/review`, and a plan-gate that blocks edits until `plan.md` is
   approved.
8. **Define real subagents** in `~/.claude/agents/` with scoped tools and `isolation: worktree` —
   right now every fan-out is generic, which is the cheapest quality loss you're carrying.
9. **Prune `~/.claude`** — 1 GB, and `security/` alone is 278M. Check `cleanupPeriodDays` before
   deleting anything from `jobs/`, which holds recoverable artifacts.

---

## 7. Confidence

- **[verified]** = checked against `/home/nooo/.local/share/claude/versions/2.1.222` or run on this
  machine: all 31 hook events, every statusline field named, the settings keys in §2.3, the theme
  values, the keybindings schema shape, the spinner defaults, the DE/session/installed-tools
  baseline, and dnf availability of ghostty/kitty/alacritty.
- Everything in §3, §4 and §5 is **documentary** — star counts, maintenance status and feature
  claims come from repo pages and docs read once. **Nothing has been installed, rendered, or
  looked at.** Version numbers and shortcut strings for Cursor, Warp, Devin Desktop, Kilo and
  Windsurf lean on secondary write-ups and should be re-checked before building against them.
- One research strand claimed there is no quota data in the statusline payload. **That is wrong** —
  `rate_limits.{five_hour,seven_day}.{used_percentage,resets_at}` exists and is already wired into
  your statusline.
