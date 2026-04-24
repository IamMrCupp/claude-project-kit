---
name: Automation for {{PROJECT_NAME}} — Atlantis (Terraform)
description: This project uses Atlantis for Terraform plan/apply on PRs. Interaction is via PR comments, not a traditional CI dashboard.
type: reference
---

**{{PROJECT_NAME}}** uses **Atlantis** for Terraform automation.

- **Interaction model:** PR-comment driven. `atlantis plan` comments produce plan output on the PR; `atlantis apply` applies after approval.
- **Config:** `atlantis.yaml` at repo root (optional — Atlantis auto-discovers Terraform directories if absent).
- **Workflow:** open PR → Atlantis auto-plans (or wait for `atlantis plan` comment) → reviewer approves the plan output → `atlantis apply` comment runs the apply → Atlantis auto-merges (if configured) or leaves the PR for human merge.
- **Locking:** Atlantis locks a workspace during plan/apply; competing PRs wait. Long-running applies can block other work.

**Why:** Atlantis bridges Terraform and PR review, so the PR IS the deploy interface. Treating it like normal CI (looking at a dashboard) misses the point — the plan output on the PR is the artifact.

**How to apply:**
- When reviewing a Terraform PR, the plan comment is load-bearing: read it carefully. `+/-/~` counts aren't enough; specific resource changes matter.
- Never suggest `atlantis apply` without an approval already landed — Atlantis enforces this, but propose the right sequence.
- If a PR's plan is stale (pushed new commits since), re-run `atlantis plan` to regenerate before any approval judgments.
- Workspace locks are real — if a plan says "locked by PR #42," coordinate with that PR's owner instead of force-unlocking.
- For multi-workspace repos, understand which workspaces are in scope for the PR before commenting; `atlantis.yaml`'s `projects:` block defines this.
