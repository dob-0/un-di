# Context: Who I Am

This doc is for any AI working with me. Read it before asking basic questions about my setup.

## Identity

- **Name:** Gevorg Aram Grigoryan (`dob_`)
- **GitHub:** `dob-0`
- **Email:** `info@thedi.studio`
- **Based in:** Republic of Armenia
- **Languages:** Armenian, English, Russian, Dutch
- **OS:** Linux (Fedora/Nobara)

## Background

Artist and director who codes. Deeply involved in digital and artistic realms since 2012. Background spans theater direction, multimedia art, electronic art, audio/visual production — not a traditional software engineer. Built up programming as a skill to realize artistic/technical vision.

Formal education: Master of Arts in Theater Art, Yerevan State Institute of Theatre and Cinematography (2017–2019). Previously lectured there (2020–2021). Also worked as art manager at Gyumri State Symphony Orchestra and as actor/director at Gyumri State Drama Theater.

## Primary project

**di.iiii** — XR studio network platform at di-studio.xyz.  
Repo: `dob-0/di.iiii` on GitHub. Running since 2022.

**What it is:** An open-source XR studio_network that connects physical and virtual environments through creative collaborations, supporting live processes across XR platforms and physical infrastructure. It is the software infrastructure behind a practice that produces real-world installations, performances, and events.

**The practice behind it:** di.ii has produced work across Armenia (Yerevan, Gyumri) and Germany (Munich) since 2020. The recurring themes are:
- Physical-digital hybridity — installations where projections respond to physical space and bodies
- Body/human tracking — depth sensors, computer vision, motion tracking as artistic material
- Cultural memory and identity — Armenian communal life, borders, language, collective reflection
- Live A/V — real-time audiovisual performance synchronized with music and events
- AI as artistic tool — real-time generative systems, AI alter egos, data-driven feedback loops
- XR — VR experiences, metaverse spaces, spatial computing

**Selected projects:**
- `di.ex: no_map` — immersive installation, depth scanner + body tracking, questioning maps and borders (DDD Kunsthous, Yerevan)
- `bisetka` / `bisetka v:2` — communal gathering space reimagined as performance and installation (Hochx / PATHOS Theater, Munich; SPIELART Festival)
- `recordAR` — XR educational platform exploring memory and identity (XR Hub Bavaria / Gyumri)
- `OUT` — interdisciplinary performance, audiovisual systems, 3D-printed stage (NPAK / Yerevan)
- `alter ego` — TV show with real-time AI-generated alter egos (Public Television of Armenia)
- `Cascade club` — high-fidelity digital recreation of Yerevan's 1990s Cascade Club as interactive 360° metaverse space (YODoor)
- `dimensions:004` — depth sensor installation, movement triggers collapses/reconstructions (Academy of Fine Arts, Munich; mards residency)
- `f3 3d 6ack` — data-driven installation where cultural research generates real-time visual feedback (NPAK / AGBU Katapult)
- `ai.sd` — real-time interactive AI generation installation (TUMO, Yerevan)
- `zoo.3d` — 3D master plan visualization for Yerevan Zoo
- `engineering city (EC)` — spatial multimedia environment for EEC opening ceremony
- `Yokozo` — 3D-printed sculpture exhibition with light/laser takeover
- `techno_sapiens` — sound and light performance in a train station tunnel exploring the clash between the "techno generation" and those encountering digital realities for the first time (Gyumri, Armenia)

**Collaborators and institutions:** UNICEF, Goethe Institute Yerevan, NPAK (Armenian Center for Contemporary Experimental Art), TUMO, EIF, XR Hub Bavaria, Hochx Theater Munich, SPIELART Contemporary Theater Festival, Public Television of Armenia, Academy of Fine Arts Munich, Hayfilm Cluster, Hosq.co.

Stack:
- Frontend: React + Three.js / React Three Fiber, Vite, port 5173
- Backend: Node.js (`serverXR`), port 4000
- Full stack: Docker Compose, port 8080
- DB: SQLite (node-sqlite3-wasm)
- Branch flow: `dev → staging → main`

Route work to the right domain:
- CSS/layout → UI/UX Engineer (`docs/ai/roles/ui-ux-engineer.md`)
- Three.js/XR → 3D/Viewport Engineer
- serverXR/auth/db → Backend/API Engineer
- shared schema/op-log → Schema/Protocol Engineer
- nodeRegistry/graph → Node System Engineer

## AI tools I use

- **Claude Code** — primary, terminal-based, for full feature work
- **Cursor** — IDE, for inline edits and staying in flow
- **ChatGPT / other AI** — research, second opinions
- **Ollama (local)** — free delegation before escalating to paid APIs:
  - `dob-fast` — quick Q&A
  - `dob-deep` — architecture
  - `qwen3-coder:30b` — logic/tests

## How I like to work

- **Concise responses.** No trailing summaries, no recaps of what was just done.
- **No emojis.**
- **Don't over-ask.** Proceed on safe/routine ops. Pause only before destructive or ambiguous things — one sentence to confirm, not a menu of options.
- **Don't charge ahead blindly either.** If scope or interpretation is unclear, ask before burning tokens on the wrong thing.
- **Write code, don't describe it.** If you know what to do, do it.

## This workspace (`un-di`)

`un-di` is where I collect context, research AI tools, and tune my Claude Code setup. Markdown docs here are meant to be read by any AI, not just Claude.
