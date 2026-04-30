# Claude Working Context — terraform-envs
**Last updated:** 2026-04-25
**Project:** `lighthouse/terraform-envs`
**Repo path:** `~/Code/lighthouse/terraform-envs`

---

## How to load this context

At the start of any new Claude session, say:
> "Read CONTEXT.md and SESSION-LOG.md in this folder before we start."

> **Folder shape:** per-repo subfolder of a workspace. Also load `../workspace-CONTEXT.md` for cross-repo context and any active `../tickets/<KEY>-<slug>.md` files in scope for the session.

---

## Project Overview

Per-environment composition of the Lighthouse AWS platform — `dev/`, `staging/`, `prod/` directories each pin a specific tag from `terraform-modules` and configure the resources for that environment. Modules are pinned via `git::https://...?ref=vX.Y.Z` source URLs — never `ref=main`. Atlantis runs `terraform plan` on PR comments and `terraform apply` on PR merge.

- **GitHub / host:** https://github.com/example-org/terraform-envs
- **Visibility:** private (org-internal)
- **Platform targets:** AWS — `us-east-1` (dev/staging/prod), `us-west-2` (prod DR)
- **This folder:** Private AI working context — never commit to repo

---

## Tracker Configuration

The tracker config lives at the workspace level (`../workspace-CONTEXT.md`) since it covers both repos in the LX initiative. See that file for tracker type, project key, MCP availability, and link.

---

## Working Rules

### Git & commits
- Conventional Commits, single line, signed off. Module-bump commits use `chore(envs):` (not `feat:` — the change is a pin, not a feature). JIRA key in subject after an em-dash.
- Branch: `<type>/LX-NNNN-<short-slug>`. Same JIRA key as the matching `terraform-modules` PR when bumping a pin (LX-1234 in both repos).
- Merge strategy: merge commits.

### PRs
- Title: `chore(envs): bump <module> module to <vX.Y.Z> in <env> (LX-NNNN)`.
- Body: `## JIRA` section linking the ticket + Atlantis plan output (auto-pasted by the bot) + a short summary.
- Apply order: `dev` → `staging` → soak ≥ 24h → `prod`. Hard rule for any change touching ALB, IAM, or RDS.

### Shell / build
- macOS default zsh. `tflint` + `terraform fmt -check` pre-commit (same setup as modules repo).
- Plan-locally before push for non-trivial changes — `terraform plan` from inside the env directory.

### File editing
- Repo is mounted at `~/Code/lighthouse/terraform-envs`.
- Never hand-edit `terraform.tfstate` (remote state in S3 + DynamoDB lock).
- Module pins live in `<env>/<resource>.tf` — search-and-replace by tag is the cleanest update path.

---

## Current Phase Status

**Steady state — apply per ticket.** This repo doesn't run on phases; it runs on tickets. Each ticket touches one or more env directories; merge → Atlantis applies → next ticket.

**Active ticket:** [LX-1234](../tickets/LX-1234-fix-lb-routing.md) — staging bump merged + applied 2026-04-24; prod bump PR open, soak window ends 2026-04-25 17:00 UTC.

**Known issues / open threads:**
- `prod-dr/` (us-west-2 DR setup) is still on `lighthouse-vpc@v1.0.0` — needs the `v1.0.1` CIDR-default fix from LX-1100. Low priority since DR doesn't see real traffic, but the divergence will eventually bite.

---

## Key Dependencies

- **Atlantis** — same instance as the modules repo. Configured per-env via `atlantis.yaml`. Locks per-env directory (no concurrent applies on the same env).
- **AWS SSO** — devs need `lighthouse-platform-rw` role for staging plans, `lighthouse-platform-prod-rw` for prod. Plans in PR show via Atlantis bot; manual local plans require AWS SSO login.

---

## CI Overview

- **CI platform:** GitHub Actions (lint / fmt-check) + Atlantis (plan/apply).
- **Quality gates:** OPA policies (no `0.0.0.0/0` ingress, no `state.tf` files committed without remote backend, no `aws_iam_policy_attachment` resource type — `aws_iam_role_policy_attachment` only).

---

## Reference

- `../workspace-CONTEXT.md` — cross-repo overview + shared tracker config
- `../tickets/<KEY>-<slug>.md` — active per-ticket scratchpads
- `SESSION-LOG.md` — chronological history of sessions in this repo
