---
allowed-tools: Bash(git branch:*), Bash(git status:*), Bash(git log:*), Bash(docker ps:*), Bash(curl:*)
description: Pre-show or pre-demo readiness check — go/no-go verdict for live performance
---

## Context

- Branch: !`git branch --show-current`
- Uncommitted changes: !`git status --short`
- Last commit: !`git log --oneline -1`
- Docker: !`docker ps --format "table {{.Names}}\t{{.Status}}" 2>/dev/null || echo "docker not running"`
- Services: !`curl -s -o /dev/null -w "backend:%{http_code}" http://localhost:PORT_BACKEND/health 2>/dev/null || echo "backend:unreachable"`

## Task

Report readiness for a live show or demo:

1. **Git state** — warn if on wrong branch or uncommitted changes affect behavior
2. **Services** — what's up, what's down
3. **Go / No-go** — one clear verdict with blockers listed

If anything is down, provide the exact command to start it. Keep it short.
