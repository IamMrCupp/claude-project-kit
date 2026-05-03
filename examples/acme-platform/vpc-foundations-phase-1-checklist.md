# Workspace Phase 1 Checklist — VPC + env foundations — bring up dev / staging / prod

> **Archived 2026-04-04.** This checklist tracked Phase 1 of the **VPC + env foundations** initiative, which closed when `prod` was deployed and serving traffic. Renamed from `workspace-phase-1-checklist.md` → `vpc-foundations-phase-1-checklist.md` so the next initiative ([Production hardening](workspace-phase-1-checklist.md)) could claim the unprefixed file name.

**Initiative:** VPC + env foundations (see `workspace-plan.md` "Completed initiatives")
**Goal:** Stand up the AWS foundation for Lighthouse — shippable VPC module + composed envs (`dev`, `staging`, `prod`) on top.
**Status:** ✅ Complete (2026-04-04)
**Exit criteria:** All three envs terraformed end-to-end via the shared VPC module; `prod` accepting real traffic; rollback procedure tested in `dev`.
**Repos touched:** `terraform-modules`, `terraform-envs`

---

## Section A — VPC module

### A.1 Reusable VPC module with subnet/NAT layout

- **Tracker:** ACME-1100
- **Repos:**
  - **terraform-modules** — branch `feat/ACME-1100-vpc-module` → PR #287 ✅ merged
- **Status:** [x] merged
- **Tag:** `modules/vpc@v1.0.0`
- **Cross-reference:** [`tickets/archive/ACME-1100-add-vpc-module.md`](tickets/archive/ACME-1100-add-vpc-module.md)

---

## Section B — Per-env composition

### B.1 `envs/dev` — first consumer of `modules/vpc@v1.0.0`

- **Tracker:** ACME-1110
- **Repos:**
  - **terraform-envs** — branch `feat/ACME-1110-envs-dev-vpc` → PR #170 ✅ merged
- **Status:** [x] merged

### B.2 `envs/staging` — pin VPC module + add ALB + ECS service

- **Tracker:** ACME-1115
- **Repos:**
  - **terraform-envs** — branch `feat/ACME-1115-envs-staging` → PR #178 ✅ merged
- **Status:** [x] merged

### B.3 `envs/prod` — production rollout with rollback procedure tested in dev

- **Tracker:** ACME-1120
- **Repos:**
  - **terraform-envs** — branch `feat/ACME-1120-envs-prod` → PR #190 ✅ merged
- **Status:** [x] merged

---

**Checkpoint B (closed 2026-04-04):** All three envs operational. `prod` ALB took its first real request at 2026-04-04T14:23 UTC.

---

## Acceptance testing

Tests recorded in `acceptance-test-results.md` (archived alongside this checklist):

- [x] Test 1 — `terraform plan` runs clean against `envs/dev` ✅ PASS
- [x] Test 2 — `terraform apply` succeeds in `envs/dev` and the resulting VPC matches the module's documented subnet/NAT layout ✅ PASS
- [x] Test 3 — Repeat for `envs/staging` and `envs/prod` ✅ PASS
- [x] Test 4 — Rollback procedure tested in `envs/dev` (revert PR → re-apply → confirm previous state) ✅ PASS
- [x] Test 5 — `prod` ALB accepts a real request and returns the expected response ✅ PASS

---

## Phase exit (completed 2026-04-04)

- [x] All items in all sections ticked
- [x] Acceptance tests pass (see archived `acceptance-test-results.md`)
- [x] `workspace-plan.md` updated — initiative moved from "Active" to "Completed initiatives"
- [x] `workspace-CONTEXT.md` updated — Past initiatives entry added; Current Initiative bumped to Production hardening
- [x] Session entry appended to `workspace-SESSION-LOG.md` describing phase + initiative completion
- [x] Active initiative wrapped — checklist renamed to `vpc-foundations-phase-1-checklist.md`; next initiative ([Production hardening](workspace-phase-1-checklist.md)) starts with a fresh `workspace-phase-1-checklist.md`.
