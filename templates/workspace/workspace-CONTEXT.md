# Workspace — {{WORKSPACE_NAME}}
**Last updated:** {{YYYY-MM-DD}}

---

## How to load this context

At the start of any session that spans multiple repos in this workspace, say:
> "Read workspace-CONTEXT.md before we start."

Read this file **first** in workspace mode — it tells Claude the *current initiative* so per-repo context loads make sense. Per-repo context (`<repo>/CONTEXT.md`, `<repo>/SESSION-LOG.md`) lives in each repo's subfolder; load that for the specific repo when work narrows to that repo. Per-ticket scratchpads live at `tickets/<KEY>-<slug>.md` (active) and `tickets/archive/` (closed).

This file is private — never commit it to any repo.

---

## Workspace Overview

{{ONE_PARAGRAPH_DESCRIPTION — what this workspace is, the program/team/scope it represents, and why these repos belong together. Persists across initiatives — write the workspace's enduring purpose, not the current piece of work.}}

- **Program / team:** {{e.g. Platform, Cloud Infrastructure, Data}}
- **Stakeholders:** {{teams / leads / on-call rotations involved across initiatives}}
- **Started:** {{YYYY-MM-DD}}

---

## Current Initiative

The active initiative this workspace is focused on. **Update this section when initiatives change** (`/close-phase` style — close out the previous initiative below in "Past initiatives", then bump this section).

- **Initiative:** {{e.g. Terraform foundation, Helm migration, Observability stack rollout}}
- **Initiative key (if applicable):** {{epic / OKR ID / project codename}}
- **Status:** {{kicking off | active | wrapping up | done}}
- **Started:** {{YYYY-MM-DD}}
- **Target completion:** {{YYYY-MM-DD or "open-ended"}}
- **Why this initiative now:** {{one sentence — the driver or trigger}}
- **Repos primarily touched:** {{<repo-a>, <repo-b>}}

**Plan** — see [`workspace-plan.md`](workspace-plan.md) for the full initiative list and per-initiative plans.

---

## Past initiatives

Chronicle of completed initiatives in this workspace. Keep entries to one or two lines so the file stays scannable; deeper history lives in `workspace-plan.md` and the per-repo `SESSION-LOG.md` files.

- {{YYYY-MM-DD}} — **{{initiative name}}** — {{one-line summary; key outcome / cross-reference (PR, archived ticket, plan section)}}
- …

---

## Tracker Configuration

Shared tracker config for the workspace. If a single tracker covers all repos, capture it here once instead of duplicating in each `<repo>/CONTEXT.md`.

- **Tracker type:** {{TRACKER_TYPE}}
- **Project / team key:** {{TRACKER_KEY}}
- **MCP availability:** {{installed | not installed | unknown}}
- **Tracker link:** {{URL}}
- **Tracker authority:** {{user-owned | externally-owned | unknown}} — *user-owned* triggers issue-first defaults; *externally-owned* trackers (work JIRA, upstream OSS) stay read-only.

See `CONVENTIONS.md` (kit-level — `## Ticket-driven workflows`) for the branch / PR / commit conventions to use against a tracker, and `## Ticket-driven workflows → Issue-first when you own the tracker` for the issue-creation defaults.

---

## Repos in this workspace

| Repo | Subfolder | Role | Local CONTEXT |
|---|---|---|---|
| {{repo-a}} | `{{repo-a}}/` | {{role — e.g. Terraform envs}} | [{{repo-a}}/CONTEXT.md]({{repo-a}}/CONTEXT.md) |
| {{repo-b}} | `{{repo-b}}/` | {{role — e.g. Terraform modules}} | [{{repo-b}}/CONTEXT.md]({{repo-b}}/CONTEXT.md) |

---

## Tickets

Active per-ticket scratchpads live under `tickets/<KEY>-<slug>.md`. Closed ticket files move to `tickets/archive/`.

**Active:**
- [{{KEY}}](tickets/{{KEY}}-{{slug}}.md) — {{one-line summary; repos touched; initiative}}

**Recently archived:**
- [{{KEY}}](tickets/archive/{{KEY}}-{{slug}}.md) — {{one-line "what shipped"; initiative}}

---

## Cross-repo notes

{{Anything that spans multiple repos and doesn't belong in any single per-repo `CONTEXT.md` — shared dependencies, deployment ordering across repos, cross-repo PR coordination, naming conventions that hold across the workspace, etc. Keep tight; if a section grows past a paragraph, consider whether it belongs in a per-repo `CONTEXT.md` or in `implementation.md` of the relevant repo.}}

---

## Reference

- [`workspace-plan.md`](workspace-plan.md) — initiative list, current + past + planned, with per-initiative scope notes
- `tickets/` — per-ticket scratchpads (per [`docs/adr/0001-multi-repo-folder-model.md`](https://github.com/IamMrCupp/claude-project-kit/blob/main/docs/adr/0001-multi-repo-folder-model.md) in the kit)
- `<repo>/CONTEXT.md` — per-repo context (one per repo subfolder)
- `<repo>/SESSION-LOG.md` — per-repo session history
- `<repo>/plan.md`, `<repo>/phase-*-checklist.md` — per-repo planning docs
