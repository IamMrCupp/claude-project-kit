# Workspace — {{INITIATIVE_NAME}}
**Last updated:** {{YYYY-MM-DD}}

---

## How to load this context

At the start of any session that spans multiple repos in this workspace, say:
> "Read workspace-CONTEXT.md before we start."

Per-repo context (`<repo>/CONTEXT.md`, `<repo>/SESSION-LOG.md`) lives in each repo's subfolder; load that for the specific repo when work narrows to that repo. Per-ticket scratchpads live at `tickets/<KEY>-<slug>.md` (active) and `tickets/archive/` (closed).

This file is private — never commit it to any repo.

---

## Initiative Overview

{{ONE_PARAGRAPH_DESCRIPTION — what this initiative is, why it spans these repos, what done looks like}}

- **Initiative key (if applicable):** {{e.g. epic key, OKR ID, project codename}}
- **Status:** {{active | paused | wrapping up | done}}

---

## Tracker Configuration

Shared tracker config for the initiative. If a single tracker covers all repos, capture it here once instead of duplicating in each `<repo>/CONTEXT.md`.

- **Tracker type:** {{none | github | jira | linear | gitlab | shortcut | other}}
- **Project / team key:** {{KEY — e.g. LX, INFRA, ENG}}
- **MCP availability:** {{installed | not installed | unknown}}
- **Tracker link:** {{URL}}

See `CONVENTIONS.md` (kit-level — `## Ticket-driven workflows`) for the branch / PR / commit conventions to use against a tracker.

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
- [{{KEY}}](tickets/{{KEY}}-{{slug}}.md) — {{one-line summary; repos touched}}

**Recently archived:**
- [{{KEY}}](tickets/archive/{{KEY}}-{{slug}}.md) — {{one-line "what shipped"}}

---

## Cross-repo notes

{{Anything that spans multiple repos and doesn't belong in any single per-repo `CONTEXT.md` — shared dependencies, deployment ordering across repos, cross-repo PR coordination, naming conventions that hold across the workspace, etc. Keep tight; if a section grows past a paragraph, consider whether it belongs in a per-repo `CONTEXT.md` or in `implementation.md` of the relevant repo.}}

---

## Reference

- `tickets/` — per-ticket scratchpads (per [`docs/adr/0001-multi-repo-folder-model.md`](https://github.com/IamMrCupp/claude-project-kit/blob/main/docs/adr/0001-multi-repo-folder-model.md) in the kit)
- `<repo>/CONTEXT.md` — per-repo context (one per repo subfolder)
- `<repo>/SESSION-LOG.md` — per-repo session history
- `<repo>/plan.md`, `<repo>/phase-*-checklist.md` — per-repo planning docs
