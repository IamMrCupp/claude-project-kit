---
name: Current project context — widget-tracker
description: What this project is, why it exists, timeline, stakeholders, and constraints that aren't obvious from the code.
type: project
---

**Project:** widget-tracker
**Repo:** `exampleco/widget-tracker`

A single-binary Go CLI for tracking inventory of physical widgets across multiple storage locations. SQLite-backed, fully local, no server, no GUI. Built for a small ops team that lost data twice in six months to concurrent edits on a shared spreadsheet and explicitly doesn't want a cloud service. Each operator runs a local instance; CSV import/export is the sync mechanism between operators. Phase 1 (core CRUD + SQLite backend) targeted for end of April 2026 so the team can start using it before the Q3 inventory cycle.

**Why:** spreadsheet-based tracking has been losing data and triggering manual reconciliation work. The team has decided they don't want a cloud service (reliability concerns, no IT budget). A local CLI with deterministic single-writer behavior wins.

**How to apply:**
- When suggesting scope changes or trade-offs, lean toward what serves the local-first, single-operator goal — not abstract scaling or "what if we had a server" concerns that don't apply.
- Flag anything that would push the end-of-April Phase 1 milestone or reduce the core CRUD value proposition.
- If the goal changes (e.g. team decides they do want a server after all), update this memory — stale project memories cause bad suggestions.

**Known constraints:**
- Must compile with the pure-Go SQLite driver (no CGO). Operators run on locked-down macOS and Linux laptops where toolchain installs are friction.
- No runtime network dependencies — fully offline tool.
- Must support macOS arm64 + x86_64 and Linux x86_64 from day one. Linux arm64 is P1, Windows-via-WSL is P2.

**Stakeholders / audience:**
- Primary users: ~5 operators on the exampleco ops team.
- Code review: project owner + one rotating reviewer from the platform team.
- If it breaks: ops falls back to the old spreadsheet flow until a fix lands.
