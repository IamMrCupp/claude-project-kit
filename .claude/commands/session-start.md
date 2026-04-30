---
description: Load the working folder's CONTEXT.md, SESSION-LOG.md, and current phase checklist into the session, then hand back a grounding summary. Same flow as Prompt 1 in PROMPTS.md, packaged as a slash command.
---

Before we start, read these files in my AI working folder, in order:

1. `<working-folder>/CONTEXT.md` — project overview, working rules, current phase
2. `<working-folder>/SESSION-LOG.md` — chronological session history
3. The current phase's checklist (e.g. `<working-folder>/phase-<N>-checklist.md`)

These are my persistent project context — they live outside the repo and hold scope, decisions, and current status. Don't edit them unless I ask; updates happen at session end.

The working-folder path comes from `reference_ai_working_folder.md` in auto-memory. If that's not set, ask before guessing.

## Hand back

A 3–5 bullet summary of:

- Where we are in the project (current phase + status)
- What landed most recently (most recent SESSION-LOG entry — date, focus, PRs)
- Any open threads / next-steps called out in the latest log entry
- Any unticked items in the current phase checklist worth flagging
- The likely starting point for this session, if obvious

Then wait for my next instruction. Don't propose changes or start coding yet.

## When to use a different command

- **Resuming mid-PR with a branch in flight** → use Prompt 4 in PROMPTS.md instead. It loads the same context plus a structured branch / PR / CI assessment.
- **Refreshing context mid-session** (after a `/close-phase` or `/session-end` writeback) → use `/refresh-context`. This command is for cold session starts.
