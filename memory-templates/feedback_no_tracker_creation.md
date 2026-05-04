---
name: Tracker authority decides the default — issue-first when you own it, read-only when you don't
description: Externally-owned trackers (work JIRA, upstream OSS) stay read/reference only — never create projects, labels, workflows, or sprint scaffolding. Personally-owned trackers default to issue-first for trackable work, with explicit confirmation before bulk-creating issues.
type: feedback
---

The default behavior when kit features or Claude actions touch a tracker depends on **who owns it**.

## Externally-owned trackers (work JIRA, upstream OSS, etc.)

**Read/reference only.** Never create tracker projects, labels, workflow states, sprint configurations, or any structural artifact. Capture *references* to projects that already exist (project key, MCP availability, link) and let the human owners handle creation. Creating individual issues/tickets inside an existing project is on the table only when the user explicitly asks for it.

**Why:** at most workplaces, tracker projects map to teams or initiatives and are governed by PMs, program managers, or admin teams. A bootstrap that spins up its own project would step on that ownership, create duplicates, and likely violate org policy. The same logic extends to labels and workflows — those encode team-wide conventions that an individual contributor (or AI assistant) shouldn't unilaterally change.

## Personally-owned trackers (your own GitHub Issues, your own Linear team, etc.)

**Issue-first by default for trackable work.** When the user owns the tracker (their personal repo's GitHub Issues, their own Linear team, etc.), trackable work gets an issue *before* the work starts. The local `phase-N-checklist.md` is the working view; the tracker is the public/durable view. Both should agree.

- **Granularity:** one issue ≈ one phase-checklist item. Phase-level umbrella issues are optional — only worth creating when the phase has 5+ items or spans multiple repos.
- **Cross-linking:** checklist items record `Issue:` + `Branch:` + `PR:`; PR body includes `Closes #N` so merge auto-closes the issue.
- **Working-folder-only items** (local sanity checks, internal verifications with no PR) still get an issue when the tracker is yours — title or label them so it's obvious no PR is expected; close manually after the verification lands.
- **Confirm before bulk-create.** When carving a phase checklist into issues, propose the full list (titles + bodies + labels) and wait for the nod before running `gh issue create` (or equivalent). Don't auto-create silently. Single ad-hoc issues during a session are fine without a heavyweight confirmation step — the constraint is on bulk operations.

See `CONVENTIONS.md` → *Ticket-driven workflows* → *Issue-first when you own the tracker* for the full rule and rationale.

## How to apply

- When designing features that touch trackers (bootstrap prompts, MCP integrations, automation), default to **read/reference only** for externally-owned trackers and **issue-first with confirmation** for personally-owned trackers.
- Do not propose flows that call `gh project create`, `jira project create`, `linear team create`, or equivalents — for any tracker. Project-level structural artifacts are out of scope regardless of ownership.
- For personally-owned trackers, propose the issue list when carving a phase checklist; create issues after explicit confirmation. The "user explicitly asks" gate from the externally-owned rule shifts to "user confirms the proposed list" here — the distinction is that issue-first is now the *expected* path, not an ad-hoc exception.
- If unsure whether a tracker is owned by the user or externally-owned, ask first. Default to assuming externally-owned.
