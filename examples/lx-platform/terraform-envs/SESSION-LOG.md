# Session Log — terraform-envs

Chronological record of Claude working sessions in the `terraform-envs` repo. **Append-only.**

---

## Session: 2026-04-24 — ACME-1234 staging bump

**Focus:** Bump `modules/alb` from `v1.3.0` → `v1.4.0` in `staging/` to pick up the ACME-1234 routing fix.

**Tickets touched:**
- [ACME-1234](../tickets/ACME-1234-fix-lb-routing.md) — staging bump shipped; prod bump deferred for soak.

**Branches/PRs:**
- `chore/ACME-1234-bump-alb-staging` → PR #495 (merged 2026-04-24, applied via Atlantis)

**Key decisions:**
- Search-and-replace `?ref=v1.3.0` → `?ref=v1.4.0` in `staging/alb.tf` only. `dev/` was already on `main` via local override (the dev-doesn't-need-tags exception).
- Plan output reviewed line-by-line in PR — three rule changes (one insert at priority 110, two priority bumps) match the expected diff. No drift.

**Non-obvious findings:**
- Atlantis hung for ~3 minutes on first plan. Turned out to be the OPA policy-check workflow waiting on a slow lint cache. No action — transient.

**Open threads / next steps:**
- Soak window ends 2026-04-25 17:00 UTC.
- Open prod-bump PR after the soak.

---

## Session: 2026-04-25 — ACME-1234 prod bump PR opened

**Focus:** Open the prod-bump PR for ACME-1234 ahead of the soak window ending.

**Tickets touched:**
- [ACME-1234](../tickets/ACME-1234-fix-lb-routing.md) — prod PR open, awaiting soak completion before merge.

**Branches/PRs:**
- `chore/ACME-1234-bump-alb-prod` → PR #501 (open — soak window ends 2026-04-25 17:00 UTC)

**Key decisions:**
- PR opened in draft, will be marked ready-for-review at soak end. Body cites the staging soak metrics (no rule-evaluation errors, p95 latency unchanged).
- Atlantis plan posted on PR — same shape as staging (one insert + two priority bumps). Reviewed.

**Open threads / next steps:**
- Mark PR #501 ready and merge once soak completes (post 17:00 UTC).
- Once Atlantis applies, update ACME-1234's `Status` in this scratchpad to `Done` and stage the archive note.
- Carry over: `prod-dr/` is still on `lighthouse-vpc@v1.0.0` (pre-CIDR-fix). Open follow-up ticket whenever DR drift becomes load-bearing.

---

## Session: 2026-04-14 — ACME-1100 dev migration

**Focus:** First consumer migration for the new VPC module — replace dev's hand-rolled VPC with `lighthouse-vpc@v1.0.1`.

**Tickets touched:**
- [ACME-1100](../tickets/archive/ACME-1100-add-vpc-module.md) — dev migration shipped; staging/prod migrations carved into ACME-1115/ACME-1130.

**Branches/PRs:**
- `feat/ACME-1100-migrate-dev-vpc` → PR #421 (merged 2026-04-14, applied via Atlantis)

**Key decisions:**
- Surfaced the CIDR-default bug during the dry-run plan — module's default `private_subnet_cidrs` overlapped with the dev peering range. Filed back to ACME-1100 in the modules repo, fixed there (`v1.0.1`), then unblocked this migration.
- Migration done as a single PR (not staged): replace the hand-rolled resources + import-or-recreate. Validated via `terraform plan` showing only an in-place update for the affected subnets, no destructive ops.

**Non-obvious findings:**
- `terraform plan` showed phantom diff for `vpc_endpoint_policy` — module sets a stricter default than the hand-rolled version. Decided to accept the stricter policy since dev's existing one was permissive-by-default.
