# LX-1234 — Fix ALB host-header routing for /api/v2

- **Tracker:** [LX-1234](https://example.atlassian.net/browse/LX-1234)
- **Status:** In progress — sync with tracker periodically; tracker is source of truth.
- **Created:** 2026-04-23
- **Last touched:** 2026-04-25

---

## Summary

The ALB rule chain for the API service routes by host header (`api.lighthouse.example`) and then by path. The `/api/v2` path was added to the rule list but a stale priority caused it to never match — requests fall through to the legacy v1 target group. Fix is in `modules/alb` (insert v2 rule with the right priority window) and a follow-up in `envs/staging` + `envs/prod` to bump the module pin.

---

## Acceptance criteria

Pulled from the tracker. Don't paraphrase — copy verbatim and add inline notes if needed.

- [x] `/api/v2/*` requests route to the v2 target group in staging
- [x] `/api/v1/*` requests still route to the v1 target group (no regression)
- [x] Rule priorities documented in `modules/alb/README.md`
- [ ] Same behavior verified in prod after the env pin bump
- [ ] Postmortem note in the prod env's session log (post-deploy)

---

## Working notes

- **Root cause:** the v2 listener rule was assigned priority 200, but the v1 catch-all sat at priority 150. ALB evaluates lowest-priority-first, so v1 always won. Fix: v2 → priority 110, v1 catch-all → 200.
- **Why not just bump v2 to 100:** the 100-block is reserved for `/health` and `/metrics` rules in the same listener. Slot 110 is the first free.
- **Module-side test:** added a `terraform plan -target` against a synthetic listener fixture to verify rule order. Plan shows correct insertion. Not unit-test grade but enough to catch a future priority swap.
- **Env-side ordering:** staging first, soak 24h, then prod. Standard for ALB rule changes — they're hot-applied but the failure mode (wrong target group) is loud.

---

## Branches / PRs / commits

Multi-repo tickets accumulate work across repos. List branches and PRs here so the ticket scratchpad is the cross-repo coordination point.

| Repo | Branch | PR | Status |
|---|---|---|---|
| `terraform-modules` | `feat/LX-1234-alb-v2-routing` | #218 | merged 2026-04-24, tagged `v1.4.0` |
| `terraform-envs` | `chore/LX-1234-bump-alb-staging` | #495 | merged 2026-04-24, applied via Atlantis |
| `terraform-envs` | `chore/LX-1234-bump-alb-prod` | #501 | open — soak window ends 2026-04-25 17:00 UTC |

Commit examples (for reference when tickets reuse the same JIRA key across repos):

- `feat(modules): add v2 routing rule to ALB module — LX-1234` (in `terraform-modules`)
- `chore(envs): bump alb module to v1.4.0 in staging — LX-1234` (in `terraform-envs`)
- `chore(envs): bump alb module to v1.4.0 in prod — LX-1234` (in `terraform-envs`)

PR title pattern: `feat(modules): add v2 routing rule to ALB module (LX-1234)`. JIRA key in parens at the end of the conventional-commits subject. PR body has a `## JIRA` section linking the ticket; no `Closes` / `Fixes` keywords (this org doesn't use auto-transitions).

---

## Decisions / blockers

- 2026-04-23: chose priority 110 over 100 for the v2 rule — preserves the 100-block for health/metrics. Documented in `modules/alb/README.md` rule-priority table.
- 2026-04-24: deferred prod rollout 24h to give staging a soak window after merge. Standard practice for ALB rule changes.

---

## Cross-references

- **Sessions that touched this ticket:**
  - `terraform-modules/SESSION-LOG.md` — 2026-04-23 (root-cause + fix), 2026-04-24 (PR review feedback + tag)
  - `terraform-envs/SESSION-LOG.md` — 2026-04-24 (staging bump), 2026-04-25 (prod bump PR opened)
- **Related tickets:**
  - LX-1180 — original API v2 cutover (root issue masked the priority bug; surfaced once v1 fallback stopped being acceptable).
- **Workspace context:** `../workspace-CONTEXT.md` (sibling of the `tickets/` directory after deployment)

---

## Archive note

When the upstream tracker ticket closes, move this file to `../tickets/archive/`. Add a 1–2 sentence "what shipped" note here before archiving so the archive is grep-able for "what did we do for LX-1234".

(Pre-archive note goes here once the prod soak completes and the ticket is closed in JIRA.)
