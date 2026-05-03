# Workspace — acme-platform
**Last updated:** 2026-04-25

---

## How to load this context

At the start of any session that spans multiple repos in this workspace, say:
> "Read workspace-CONTEXT.md before we start."

Read this file **first** in workspace mode — it tells Claude the *current initiative* so per-repo context loads make sense. Per-repo context (`<repo>/CONTEXT.md`, `<repo>/SESSION-LOG.md`) lives in each repo's subfolder; load that for the specific repo when work narrows to that repo. Per-ticket scratchpads live at `tickets/<KEY>-<slug>.md` (active) and `tickets/archive/` (closed).

This file is private — never commit it to any repo.

---

## Workspace Overview

The acme-platform workspace owns the AWS infrastructure for the **Lighthouse** product line. It spans two repos: `terraform-modules` (reusable building blocks — VPC, ALB, ECS service, RDS, etc.) and `terraform-envs` (per-environment composition — `dev/`, `staging/`, `prod/`). Modules ship as versioned tags; envs pin specific tags via `?ref=v1.2.3` source URLs. Atlantis applies plans on PR merge.

The workspace is **long-running** — multiple initiatives have flowed through it (foundation buildout, then production hardening), and more are planned. The repo set + stakeholders + delivery pipeline stay constant; what changes is which initiative is currently driving the work.

- **Program / team:** Platform Infrastructure
- **Stakeholders:** Platform team (owners), Lighthouse product team (consumers), SRE on-call rotation
- **Started:** 2026-02-01

---

## Current Initiative

The active initiative this workspace is focused on. **Update this section when initiatives change** (`/close-phase` style — close out the previous initiative below in "Past initiatives", then bump this section).

- **Initiative:** Production hardening
- **Initiative key (if applicable):** ACME (JIRA epic linked from `workspace-plan.md`)
- **Status:** active
- **Started:** 2026-04-08
- **Target completion:** 2026-06-30
- **Why this initiative now:** Foundation rollout closed in early April with `prod` operational; the next phase of work is hardening — observability, alerting, the bug backlog that surfaced once real traffic landed.
- **Repos primarily touched:** `terraform-modules`, `terraform-envs`

**Plan** — see [`workspace-plan.md`](workspace-plan.md) for the full initiative list and per-initiative scope. Current phase is tracked in [`workspace-phase-1-checklist.md`](workspace-phase-1-checklist.md).

---

## Past initiatives

Chronicle of completed initiatives in this workspace. Keep entries to one or two lines so the file stays scannable; deeper history lives in `workspace-plan.md` and the per-repo `SESSION-LOG.md` files.

- 2026-04-04 — **VPC + env foundations** — VPC module + per-env compositions (dev/staging/prod) shipped. Phase 1 archived as [`vpc-foundations-phase-1-checklist.md`](vpc-foundations-phase-1-checklist.md). Anchored the workspace's first 2 months.

---

## Tracker Configuration

Shared tracker config for the workspace. If a single tracker covers all repos, capture it here once instead of duplicating in each `<repo>/CONTEXT.md`.

- **Tracker type:** jira
- **Project / team key:** ACME
- **MCP availability:** installed
- **Tracker link:** https://example.atlassian.net/browse/ACME

See `CONVENTIONS.md` (kit-level — `## Ticket-driven workflows`) for the branch / PR / commit conventions to use against a tracker.

---

## Repos in this workspace

| Repo | Subfolder | Role | Local CONTEXT |
|---|---|---|---|
| `lighthouse/terraform-modules` | `terraform-modules/` | Reusable Terraform modules; semver-tagged | [terraform-modules/CONTEXT.md](terraform-modules/CONTEXT.md) |
| `lighthouse/terraform-envs` | `terraform-envs/` | Per-env compositions; pins module tags | [terraform-envs/CONTEXT.md](terraform-envs/CONTEXT.md) |

---

## Tickets

Active per-ticket scratchpads live under `tickets/<KEY>-<slug>.md`. Closed ticket files move to `tickets/archive/`.

**Active (Production hardening):**
- [ACME-1234](tickets/ACME-1234-fix-lb-routing.md) — ALB host-header routing breaks for `/api/v2`; fix in `modules/alb` + bump pin in `envs/staging` and `envs/prod`. Touches both repos.

**Recently archived (VPC + env foundations):**
- [ACME-1100](tickets/archive/ACME-1100-add-vpc-module.md) — New VPC module with reusable subnet/NAT layout. Shipped as `modules/vpc@v1.0.0`; `envs/dev` migrated as the first consumer.

---

## Cross-repo notes

- **Module → env pin convention.** Envs source modules via `git::https://...?ref=vX.Y.Z` — never `ref=main`. This means a modules change is a two-PR sequence: (1) merge + tag in `terraform-modules`, (2) bump the pin in `terraform-envs`. Same JIRA key on both PRs (e.g. `ACME-1234`); commit subjects differ in scope tag (`feat(modules):` vs. `chore(envs):`).
- **Atlantis plan on PR; apply on merge.** Both repos are wired to the same Atlantis instance. PR comments show the `terraform plan` output. Apply is gated on PR merge; rollback = revert PR → re-merge.
- **Naming.** Modules use `lighthouse-<resource>` prefix (`lighthouse-vpc`, `lighthouse-alb`). Envs use `lighthouse-<env>-<resource>` (`lighthouse-staging-alb`).
- **Smart Commits NOT enabled.** This org doesn't use auto-transitions; PR descriptions reference the JIRA key but don't include `Closes` / `Fixes`. Tickets are moved manually.

---

## Reference

- [`workspace-plan.md`](workspace-plan.md) — initiative list, current + past + planned, with per-initiative scope notes
- [`workspace-phase-1-checklist.md`](workspace-phase-1-checklist.md) — current phase of the active initiative (Production hardening)
- [`vpc-foundations-phase-1-checklist.md`](vpc-foundations-phase-1-checklist.md) — archived phase from the completed initiative (VPC + env foundations)
- `tickets/` — per-ticket scratchpads (per [`docs/adr/0001-multi-repo-folder-model.md`](https://github.com/IamMrCupp/claude-project-kit/blob/main/docs/adr/0001-multi-repo-folder-model.md) in the kit)
- `<repo>/CONTEXT.md` — per-repo context (one per repo subfolder)
- `<repo>/SESSION-LOG.md` — per-repo session history
- `<repo>/plan.md`, `<repo>/phase-*-checklist.md` — per-repo planning docs (omitted from this example for brevity; see `examples/widget-tracker/` for filled-in `plan.md` / phase checklist examples)
