---
allowed-tools: Bash(docker ps:*), Bash(docker compose:*), Bash(curl:*), Bash(lsof:*), Bash(git branch:*)
description: Show the status of the full dev stack — docker, backend, frontend
---

## Task

Check and report the status of each layer:

1. **Branch**: !`git branch --show-current`
2. **Docker**: !`docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || echo "docker not running"`
3. **Backend** (PORT_BACKEND): !`curl -s -o /dev/null -w "%{http_code}" http://localhost:PORT_BACKEND/health 2>/dev/null || echo "unreachable"`
4. **Frontend** (PORT_FRONTEND): !`curl -s -o /dev/null -w "%{http_code}" http://localhost:PORT_FRONTEND 2>/dev/null || echo "unreachable"`

Replace PORT_BACKEND and PORT_FRONTEND with actual ports for this project.

Report which services are up, which are down, and how to start anything that's missing.
