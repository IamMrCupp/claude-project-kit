# Claude Working Context — terraform-modules
**Last updated:** 2026-04-25
**Project:** `lighthouse/terraform-modules`
**Repo path:** `~/Code/lighthouse/terraform-modules`

---

## How to load this context

At the start of any new Claude session, say:
> "Read CONTEXT.md and SESSION-LOG.md in this folder before we start."

> **Folder shape:** per-repo subfolder of a workspace. Also load `../workspace-CONTEXT.md` for cross-repo context and any active `../tickets/<KEY>-<slug>.md` files in scope for the session.

---

## Project Overview

Reusable Terraform modules for the Lighthouse AWS platform — VPC, ALB, ECS service, RDS, plus shared IAM and observability primitives. Modules are versioned via git tags (`v<MAJOR>.<MINOR>.<PATCH>`); environments (in the sibling `terraform-envs` repo) consume them via pinned source URLs (`?ref=v1.4.0`).

- **GitHub / host:** https://github.com/example-org/terraform-modules
- **Visibility:** private (org-internal)
- **Platform targets:** AWS — `us-east-1`, `us-west-2`
- **This folder:** Private AI working context — never commit to repo

---

## Tracker Configuration

The tracker config lives at the workspace level (`../workspace-CONTEXT.md`) since it covers both repos in the LX initiative. See that file for tracker type, project key, MCP availability, and link.

---

## Working Rules

### Git & commits
- Conventional Commits, single line, signed off (`git commit -s -m "feat(modules): ... — LX-NNNN"`). JIRA key in subject after an em-dash.
- Branch: `<type>/LX-NNNN-<short-slug>` (e.g. `feat/LX-1234-alb-v2-routing`).
- Merge strategy: merge commits (preserves granular commits per ticket).

### PRs
- Title: `<type>(<scope>): <summary> (LX-NNNN)`. Scope is `modules` or the specific module name.
- Body: `## JIRA` section linking the ticket, plus summary + manual test plan.
- No `Closes` / `Fixes` keywords (org doesn't use auto-transitions).
- Test plan must include `terraform plan` against a synthetic fixture for the changed module.

### Shell / build
- macOS default zsh. `tflint` + `terraform fmt -check` pre-commit.
- `terraform init && terraform validate` per module before push.

### File editing
- Repo is mounted at `~/Code/lighthouse/terraform-modules`.
- Never edit module README inputs/outputs tables by hand — regenerated via `terraform-docs` on a pre-commit hook.

---

## Current Phase Status

**Phase 2 — module library buildout, in progress.** v1 of the core stack (VPC, ALB, ECS service, RDS) shipped through Phase 1; Phase 2 is hardening + adding the secondary modules (CloudFront, S3 site hosting, EventBridge wiring).

**Active ticket:** [LX-1234](../tickets/LX-1234-fix-lb-routing.md) — ALB rule priority fix, merged into modules, awaiting env-side rollout.

**Known issues / open threads:**
- ALB module's listener-rule priority handling needs documentation (added in `modules/alb/README.md` as part of LX-1234 — verify on next read).
- VPC module's `nat_gateway_strategy` flag is binary (single vs. per-AZ); a future ticket may want a per-subnet override but no concrete demand yet.

---

## Key Dependencies

- **Atlantis** — handles `terraform plan` on PR and `terraform apply` on merge. Configured via `atlantis.yaml` at repo root. Module repo doesn't apply directly (it's a library); Atlantis runs `terraform validate` + `tflint` on PR.
- **terraform-docs** — generates module README input/output tables. Pre-commit hook.
- **Conftest / OPA policies** — security guardrails (no `0.0.0.0/0` ingress, no public ECS services without explicit allow). Run in CI.

---

## CI Overview

- **CI platform:** GitHub Actions + Atlantis. GH Actions handles lint / docs-check / OPA. Atlantis handles `terraform plan` per module against a sandbox account.
- **Quality gates:** `terraform fmt -check`, `tflint`, `terraform-docs` drift check, OPA policy check.

---

## Reference

- `../workspace-CONTEXT.md` — cross-repo overview + shared tracker config
- `../tickets/<KEY>-<slug>.md` — active per-ticket scratchpads
- `../tickets/archive/` — closed tickets (grep-able record of what shipped)
- `SESSION-LOG.md` — chronological history of sessions in this repo
