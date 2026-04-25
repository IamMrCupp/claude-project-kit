---
name: AI working folder for widget-tracker
description: Private AI context folder (separate from the public repo) with canonical CONTEXT.md, SESSION-LOG.md, and planning docs.
type: reference
---

At the start of every session for this project, read these two files first — they are the canonical source of truth, manually maintained across sessions:

- `/Users/dev/Documents/Claude/Projects/widget-tracker/CONTEXT.md` — project overview, working rules, current phase status
- `/Users/dev/Documents/Claude/Projects/widget-tracker/SESSION-LOG.md` — chronological history of sessions and decisions

Also in that folder:
- `plan.md`, `implementation.md`, `research.md` — planning docs
- `phase-N-checklist.md` — per-phase checklists with branch/commit info
- `acceptance-test-results.md` — manual test log for the current phase

This folder is deliberately OUTSIDE the repo. The repo (`/Users/dev/Code/widget-tracker`) is public — AI working files must never be committed there.

**Why:** having a persistent working folder lets any Claude session pick up where the previous one left off. Ephemeral sandbox filesystems don't survive session changes.

**How to apply:** When starting work on widget-tracker, read CONTEXT.md and SESSION-LOG.md before touching code. Trust them over this memory — they're updated at session end; this memory just points to them.
