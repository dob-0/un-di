# di.iiii — Project Context

For any AI working on di.iiii. Read alongside `me.md`.

## What it is

**di.iiii** is a spatial authoring platform for immersive XR experiences.  
Site: di-studio.xyz | Repo: `dob-0/di.iiii` | Running since 2022.

Core loop: open a space → compose a 3D scene → publish to a URL → experience in XR.

Two editor surfaces:
- **Studio** — project-based, inspector-driven, collaborative. The currently shipped surface.
- **Beta** — node-graph-first, recursive, composable. Future-facing.

## Why it exists

di.iiii is the software infrastructure behind an active artistic practice (di.ii XR studio_network). It is not a startup product — it is a platform built by and for artists making real exhibitions, performances, and residencies across Armenia and Germany.

The work it enables: immersive installations, body-tracking environments, live A/V performance, AI-driven experiences, metaverse spaces, XR education programs. Real venues, real audiences, real institutions.

## Long-term direction

Decentralized and creator-owned:
- Assets → content-addressed (SHA-256 / IPFS-compatible)
- Scenes → CRDT op-logs, mergeable without a central server
- Sync → WebRTC P2P, no mandatory relay
- Auth → self-hostable
- Publish → a scene is a hash, not a server URL

"A scene published today should be retrievable in 30 years without a running server."

Every decision should step toward this direction, not away from it.

## Stack

- Frontend: React + Three.js / React Three Fiber (R3F), Vite — port 5173
- Backend: Node.js (`serverXR`), SQLite (node-sqlite3-wasm) — port 4000
- Full stack: Docker Compose — port 8080
- Auth: session cookies, role-based, OAuth (GitHub/Google)
- Staging: staging.di-studio.xyz (`dev` branch)
- Production: di-studio.xyz (`main` branch)
- Branch flow: `dev → staging → main`
- Deploy: GitHub Actions (`publish-cpanel-prebuilt-v2.yml`)

## Code structure

Each domain has a role card in `docs/ai/roles/`:

| Area | Role |
|---|---|
| CSS/layout/visual | ui-ux-engineer |
| nodeRegistry/ports/graph model | node-system-engineer |
| Three.js/viewport/XR render | viewport-3d-engineer |
| serverXR/SQLite/auth/API | backend-api-engineer |
| shared schema/op-log/CRDT | schema-protocol-engineer |
| Docker/CI/deploy | infrastructure-engineer |
| tests/lint/validation | qa-test-engineer |

## AI workflow in this repo

- Read `AGENTS.md` first (auto-loaded), then `CURRENT.md` immediately after
- `CURRENT.md` has the known-fixes table — check it before investigating any bug
- Use Ollama (dob-fast / dob-deep / qwen3-coder) for analysis and planning before escalating to Claude
- Role cards define scope — do not touch files listed under "Must Never Touch"

## Non-negotiables

- No tokens/secrets in the JS bundle — ever
- Schema changes: always update both ESM and CJS mirrors (`src/shared/` + `shared/*.cjs`)
- vite.config.js `three-vendor` chunk must include all drei peer deps (missing one = TDZ crash in prod)
