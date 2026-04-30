# LX-1100 — Add reusable VPC module

- **Tracker:** [LX-1100](https://example.atlassian.net/browse/LX-1100)
- **Status:** Done — closed in JIRA 2026-04-15, archived 2026-04-16.
- **Created:** 2026-03-28
- **Last touched:** 2026-04-15

---

## Summary

The first reusable Terraform module for the LX platform: a configurable VPC with public + private subnets across 3 AZs, NAT gateway (single or per-AZ via flag), VPC endpoints for S3 / DynamoDB / SSM. Shipped as `lighthouse-vpc@v1.0.0`. `envs/dev` migrated as the first consumer to validate the module's interface; `envs/staging` and `envs/prod` followed in separate tickets (LX-1115, LX-1130).

---

## Acceptance criteria

- [x] Module covers public + private subnets in 3 AZs, configurable CIDR
- [x] NAT gateway count is a flag (cost vs. AZ-isolation trade-off)
- [x] VPC endpoints for S3, DynamoDB, SSM (no internet route required)
- [x] README documents inputs, outputs, and the `nat_gateway_strategy` choice
- [x] `envs/dev` migrated as the first consumer (validation)
- [x] Module tagged `v1.0.0` for env consumption

---

## Working notes

- Started with a fork of the Cloud Posse VPC module pattern, then trimmed to only what we need. Cuts maintenance surface.
- The single-NAT vs. per-AZ-NAT flag is the only "interesting" input — everything else is straightforward subnet math.
- Found a CIDR-collision bug during `dev` migration: the new module's default `private_subnet_cidrs` overlapped with the legacy peering range. Fixed by parameterizing — now defaults to `null` and forces the env to pass explicit CIDRs.

---

## Branches / PRs / commits

| Repo | Branch | PR | Status |
|---|---|---|---|
| `terraform-modules` | `feat/LX-1100-vpc-module` | #189 | merged 2026-04-08, tagged `v1.0.0` |
| `terraform-modules` | `fix/LX-1100-cidr-default-null` | #194 | merged 2026-04-12, tagged `v1.0.1` |
| `terraform-envs` | `feat/LX-1100-migrate-dev-vpc` | #421 | merged 2026-04-14, applied via Atlantis |

---

## Decisions / blockers

- 2026-03-30: chose the single-vs-per-AZ NAT flag over a more granular config. Granular = easy to misconfigure; the binary flag is the right granularity for this module.
- 2026-04-10: `dev` migration surfaced the CIDR-default bug → shipped as `v1.0.1`. Decision: don't reuse v1.0.0 for staging/prod; envs always pin a clean tag.
- 2026-04-13: deferred staging migration to a separate ticket (LX-1115) so this ticket scope stayed "module + dev validation" instead of "module + every env."

---

## Cross-references

- **Sessions that touched this ticket:**
  - `terraform-modules/SESSION-LOG.md` — 2026-03-28 to 2026-04-12 (initial design through v1.0.1 tag)
  - `terraform-envs/SESSION-LOG.md` — 2026-04-13 to 2026-04-14 (`dev` migration)
- **Related tickets:**
  - LX-1115, LX-1130 — staging + prod migrations (separate tickets, separate scope)
  - LX-1102 — initial design proposal (closed, replaced by this implementation ticket)
- **Workspace context:** `../../workspace-CONTEXT.md`

---

## Archive note

**What shipped (2026-04-15):** `modules/vpc@v1.0.1` (initial v1.0.0 + CIDR-default fix). `envs/dev` migrated as the first consumer; staging/prod migrations carved off as LX-1115 / LX-1130. The `nat_gateway_strategy` flag and the explicit-CIDR-default convention are documented in the module README and have informed two follow-on modules (`modules/alb`, `modules/ecs-service`).
