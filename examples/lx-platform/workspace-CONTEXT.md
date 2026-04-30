# Workspace — lx-platform
**Last updated:** 2026-04-25

---

## How to load this context

At the start of any session that spans multiple repos in this workspace, say:
> "Read workspace-CONTEXT.md before we start."

Per-repo context (`<repo>/CONTEXT.md`, `<repo>/SESSION-LOG.md`) lives in each repo's subfolder; load that for the specific repo when work narrows to that repo. Per-ticket scratchpads live at `tickets/<KEY>-<slug>.md` (active) and `tickets/archive/` (closed).

This file is private — never commit it to any repo.

---

## Initiative Overview

The LX platform initiative builds the AWS infrastructure for the **Lighthouse** product line. It spans two repos: `terraform-modules` (reusable building blocks — VPC, ALB, ECS service, RDS, etc.) and `terraform-envs` (per-environment composition — `dev/`, `staging/`, `prod/`). Modules ship as versioned tags; envs pin specific tags via `?ref=v1.2.3` source URLs. Atlantis applies plans on PR merge.

- **Initiative key (if applicable):** LX (JIRA project)
- **Status:** active

---

## Tracker Configuration

Shared tracker config for the initiative. If a single tracker covers all repos, capture it here once instead of duplicating in each `<repo>/CONTEXT.md`.

- **Tracker type:** jira
- **Project / team key:** LX
- **MCP availability:** installed
- **Tracker link:** https://example.atlassian.net/browse/LX

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

**Active:**
- [LX-1234](tickets/LX-1234-fix-lb-routing.md) — ALB host-header routing breaks for `/api/v2`; fix in `modules/alb` + bump pin in `envs/staging` and `envs/prod`. Touches both repos.

**Recently archived:**
- [LX-1100](tickets/archive/LX-1100-add-vpc-module.md) — New VPC module with reusable subnet/NAT layout. Shipped as `modules/vpc@v1.0.0`; `envs/dev` migrated as the first consumer.

---

## Cross-repo notes

- **Module → env pin convention.** Envs source modules via `git::https://...?ref=vX.Y.Z` — never `ref=main`. This means a modules change is a two-PR sequence: (1) merge + tag in `terraform-modules`, (2) bump the pin in `terraform-envs`. Same JIRA key on both PRs (e.g. `LX-1234`); commit subjects differ in scope tag (`feat(modules):` vs. `chore(envs):`).
- **Atlantis plan on PR; apply on merge.** Both repos are wired to the same Atlantis instance. PR comments show the `terraform plan` output. Apply is gated on PR merge; rollback = revert PR → re-merge.
- **Naming.** Modules use `lighthouse-<resource>` prefix (`lighthouse-vpc`, `lighthouse-alb`). Envs use `lighthouse-<env>-<resource>` (`lighthouse-staging-alb`).
- **Smart Commits NOT enabled.** This org doesn't use auto-transitions; PR descriptions reference the JIRA key but don't include `Closes` / `Fixes`. Tickets are moved manually.

---

## Reference

- `tickets/` — per-ticket scratchpads (per [`docs/adr/0001-multi-repo-folder-model.md`](https://github.com/IamMrCupp/claude-project-kit/blob/main/docs/adr/0001-multi-repo-folder-model.md) in the kit)
- `<repo>/CONTEXT.md` — per-repo context (one per repo subfolder)
- `<repo>/SESSION-LOG.md` — per-repo session history
- `<repo>/plan.md`, `<repo>/phase-*-checklist.md` — per-repo planning docs (omitted from this example for brevity; see `examples/widget-tracker/` for filled-in `plan.md` / phase checklist examples)
