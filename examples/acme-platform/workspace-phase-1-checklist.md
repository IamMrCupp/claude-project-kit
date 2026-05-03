# Workspace Phase 1 Checklist — Production hardening — observability + bug backlog

**Initiative:** Production hardening (see `workspace-plan.md` "Active initiative")
**Goal:** Stand up observability across all envs and clear the high-priority bugs that surfaced after `prod` went live.
**Status:** ⏳ In progress
**Exit criteria:** CloudWatch dashboards rendering for ALB / ECS / RDS in `dev` / `staging` / `prod`; PagerDuty alerting wired with documented thresholds; ALB host-header routing fix shipped to `prod`; sign-off from on-call rotation lead that they have actionable visibility.
**Repos touched:** `terraform-modules`, `terraform-envs`

---

## How to use this doc

This is the workspace counterpart to a per-repo `phase-N-checklist.md`. It tracks one phase of the **active initiative** at the workspace level — the cross-repo arc, not the internals of any one repo.

- One item ≈ one branch ≈ one PR. Items often span repos within the workspace — record the branch + PR for each repo touched.
- For ticket-driven work, items typically reference a tracker key (e.g. ACME-1234) shared across the per-repo PRs.
- Organize items into sections (A, B, C, …) with checkpoints between major chunks.
- Tick items ✅ the moment the LAST per-repo PR for that item merges — not at end of phase.
- Per-repo phases (each repo's `plan.md` / `phase-N-checklist.md`) drift independently from this workspace phase. Use this checklist for the cross-repo initiative arc; use per-repo checklists for repo-internal phases.

---

## Section A — Observability foundation

### A.1 Add `monitoring` module with CloudWatch dashboards (ALB / ECS / RDS)

- **Tracker:** ACME-1240
- **Repos:**
  - **terraform-modules** — branch `feat/ACME-1240-monitoring-module` → PR #312 ✅ merged
  - **terraform-envs** — branch `feat/ACME-1240-wire-monitoring-dev` → PR #198 ✅ merged
- **Status:** [x] merged

### A.2 Wire `monitoring` module into `staging` + `prod`

- **Tracker:** ACME-1241
- **Repos:**
  - **terraform-envs** — branch `feat/ACME-1241-monitoring-staging-prod` → PR #201 ⏳ in review
- **Status:** [ ] merged

---

**Checkpoint A:** Once A.2 ships, every env has live CloudWatch dashboards. Spot-check that ECS task counts + ALB request rates render before moving to alerting.

---

## Section B — Alerting

### B.1 PagerDuty alerting module (P1/P2 thresholds)

- **Tracker:** ACME-1245
- **Repos:**
  - **terraform-modules** — branch `feat/ACME-1245-alerting-module` → PR (not opened — blocked on threshold input from product)
- **Status:** [ ] merged

> **Note:** B.1 is blocked on product team input for what counts as user-visible degradation. Asked 2026-04-22; awaiting reply. Don't proceed past B.1 until thresholds land — alerting without thresholds is noise.

### B.2 Wire alerting into `prod` first, then `staging`

- **Tracker:** ACME-1246
- **Status:** [ ] merged (depends on B.1)

---

## Section C — `prod`-surfaced bug backlog

### C.1 Fix ALB host-header routing for `/api/v2`

- **Tracker:** ACME-1234
- **Repos:**
  - **terraform-modules** — branch `fix/ACME-1234-alb-host-routing` → PR #314 ⏳ in review
  - **terraform-envs** — branch `fix/ACME-1234-bump-alb-pin` → PR (not opened — blocked on PR #314 merging + tag)
- **Status:** [ ] merged
- **Cross-reference:** [`tickets/ACME-1234-fix-lb-routing.md`](tickets/ACME-1234-fix-lb-routing.md)

---

## Acceptance testing

> **Required by convention.** Every phase MUST exit with a non-empty `acceptance-test-results.md`. See `CONVENTIONS.md` → "Acceptance tests at phase boundaries" for the rule and the one allowed escape hatch. Removing this section is a convention violation, not a customization — `/close-phase` will refuse to close if it's missing.

For workspace phases, acceptance tests typically span repos. List them here:

- [ ] Test 1 — Apply the staging env after A.2 + C.1 land; verify CloudWatch dashboards render and the host-header bug is resolved (curl `/api/v2/<known-route>` against the staging ALB DNS, expect 200 + correct backend).
- [ ] Test 2 — Apply the prod env after staging is green; same checks.
- [ ] Test 3 — Trigger a synthetic alert (P2) in staging via PagerDuty integration test; verify the alert routes to the correct on-call.
- [ ] Test 4 — On-call rotation lead reviews the dashboards + alert flow and signs off that visibility is actionable. (Human-deferred; can't auto-run.)

---

## Phase exit

- [ ] All items in all sections ticked (across every repo touched)
- [ ] Acceptance tests pass (see `acceptance-test-results.md`) — OR document the skip on a single line below this block: `Acceptance tests intentionally skipped — rationale: {{one sentence}}`
- [ ] `workspace-plan.md` updated — initiative phase status, any scope drift recorded
- [ ] `workspace-CONTEXT.md` updated — current initiative status, known issues, architectural decisions
- [ ] Session entry appended to `workspace-SESSION-LOG.md` describing phase completion
- [ ] If this phase completes the **active initiative**: move it from "Active initiative" to "Completed initiatives" in `workspace-plan.md` and archive this checklist (rename to `production-hardening-phase-1-checklist.md`, or move all the initiative's phase checklists to an `archive/` subfolder). The next initiative starts with a fresh `workspace-phase-N-checklist.md` (renumbering from 1).
