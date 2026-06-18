---
allowed-tools: Bash(git branch:*), Bash(git checkout:*), Bash(git switch:*), Bash(git pull:*), Bash(git status:*)
description: Create a new feature branch from the main development branch
---

## Context

- Current branch: !`git branch --show-current`
- Current status: !`git status --short`

## Task

The user will provide a branch name or feature description.

1. If there are uncommitted changes, stop and ask what to do first
2. Switch to the base branch (dev or main) and pull latest
3. Create and switch to `feature/<slug>` (derive slug from user's input if not given)
4. Confirm the new branch is active
