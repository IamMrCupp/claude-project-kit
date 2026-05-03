# Workspace Plan — acme-platform

The persistent plan for this workspace. Tracks initiatives over time — current, planned, completed. Per-repo phase plans live in each repo's `plan.md`; this file sits one level up and chronicles the program-level arc.

**Update cadence:**
- When a new initiative kicks off — add it under "Active initiative" and move the prior one (if any) to "Completed initiatives".
- When scope of the active initiative changes meaningfully — edit in place, note the date.
- When new initiatives appear on the horizon — add to "Planned / on deck" with whatever certainty you have.

This file is the workspace counterpart to a per-repo `plan.md`. Keep it scannable; deeper detail belongs in per-repo planning docs or per-ticket scratchpads.

---

## Active initiative

### Production hardening — active

**Started:** 2026-04-08
**Target completion:** 2026-06-30
**Initiative key:** ACME-1230 (epic)
**Repos primarily touched:** `terraform-modules`, `terraform-envs`

**Goal:** Now that `prod` is live (foundation rollout complete), close the gap between "deployed" and "operationally trustworthy." Add observability, alerting, and bug fixes that surface once real traffic hits the platform.

**Scope (what's in):**
- CloudWatch dashboards for ALB / ECS / RDS metrics across all envs.
- PagerDuty alerting wired to dashboards (P1 / P2 thresholds documented).
- ALB host-header routing bug fix (`ACME-1234`).
- Backlog of small `prod`-surfaced bugs and tuning items.

**Out of scope (deliberate):**
- Multi-region failover — separate initiative, on deck (see "Planned").
- Auto-scaling tuning — observability comes first; tune once we have data.
- Cost optimization — Q3 effort, separate initiative.

**Open questions / risks:**
- PagerDuty thresholds need product input on what counts as user-visible degradation. Asked, awaiting reply.
- ALB routing fix may need a backwards-compat shim if any existing clients rely on the broken behavior — investigating.

**Cross-references:**
- Phase 1 (current): [`workspace-phase-1-checklist.md`](workspace-phase-1-checklist.md)
- Per-repo plan sections:
  - `terraform-modules/plan.md` — module changes for `alb`, `monitoring`
  - `terraform-envs/plan.md` — wire dashboards into each env, bump module pins
- Tracker epic: [ACME-1230](https://example.atlassian.net/browse/ACME-1230)
- Active ticket: [ACME-1234](tickets/ACME-1234-fix-lb-routing.md)

---

## Planned / on deck

Initiatives the workspace expects to take on but isn't actively working yet. Order = rough priority. Move to "Active initiative" when work starts.

- **Multi-region failover** — Stand up `prod-eu` as a warm standby; design DNS-level failover; document RTO/RPO targets. Trigger: completion of Production hardening (Q3 start). Touches both repos heavily; will likely be a 2-phase initiative.
- **Cost optimization sweep** — Right-size instance types based on a quarter of observability data; reserved-instance commitments for steady-state workloads. Trigger: ≥3 months of CloudWatch data accumulated.

---

## Completed initiatives

Chronicle of what this workspace has shipped, most recent first. Each entry is one paragraph max plus cross-references — anything more detailed lives in per-repo `SESSION-LOG.md` entries and archived ticket scratchpads.

### 2026-04-04 — VPC + env foundations

**Outcome:** Stood up the AWS foundation for Lighthouse: shipped a reusable VPC module with subnet/NAT layout, then composed three environments (`dev`, `staging`, `prod`) on top with shared module pins. By close, all three envs were terraformed end-to-end and `prod` was serving real traffic. Anchored the workspace's first 2 months.

**Key cross-references:**
- Archived phase checklist: [`vpc-foundations-phase-1-checklist.md`](vpc-foundations-phase-1-checklist.md)
- Tracker epic: [ACME-1090](https://example.atlassian.net/browse/ACME-1090) (closed)
- Anchor archived ticket: [ACME-1100](tickets/archive/ACME-1100-add-vpc-module.md) — VPC module v1.0.0
- Subsequent rollout tickets: ACME-1110 (envs/dev), ACME-1115 (envs/staging), ACME-1120 (envs/prod)

---

## Notes

- The workspace itself is long-running; initiatives come and go. If the workspace's purpose drifts substantially (e.g. "acme-platform" becomes a multi-product platform spanning unrelated teams), consider whether you actually want a *new* workspace rather than retrofitting this one.
- For converting a single-repo working folder into a workspace, see [SETUP.md §Upgrading a single-repo working folder to a workspace](https://github.com/IamMrCupp/claude-project-kit/blob/main/SETUP.md#upgrading-a-single-repo-working-folder-to-a-workspace) in the kit.
- For the long-running workspace pattern (multiple initiatives over time, archival ritual when an initiative wraps), see [SETUP.md §Long-running workspace layout](https://github.com/IamMrCupp/claude-project-kit/blob/main/SETUP.md#single-initiative-vs-long-running-workspaces) in the kit.
