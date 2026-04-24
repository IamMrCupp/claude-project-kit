---
name: CI for {{PROJECT_NAME}} — CircleCI
description: This project runs CI on CircleCI. Pipeline config is `.circleci/config.yml`; `circleci` is the CLI of record.
type: reference
---

**{{PROJECT_NAME}}** runs CI on **CircleCI**.

- **Pipeline config:** `.circleci/config.yml` at repo root.
- **CLI:** `circleci` (`circleci local execute` runs a job locally; `circleci config validate` catches YAML errors; `circleci api` hits the REST endpoints for run/job inspection).
- **Orbs:** reusable config packages — check the `orbs:` block in `config.yml` for what the project depends on.
- **Contexts:** org-wide secret buckets (`circleci context list`). Jobs reference contexts via the `context:` key; understanding which context a job uses is often the first step when debugging auth failures.
- **Workflows vs jobs:** a workflow orchestrates jobs; a pipeline triggers one or more workflows. CircleCI surfaces all three in the UI; disambiguate when reporting status.

**Why:** CircleCI's config is terse and orb-heavy, so understanding what a job depends on often means chasing orb definitions. The CLI's `config validate` catches most YAML/schema issues before a push.

**How to apply:**
- Before pushing a `.circleci/config.yml` change, run `circleci config validate` — saves a roundtrip.
- On failure, fetch the job step output via the CircleCI API; the UI is slower to load than the API.
- If the project uses approval jobs (manual gates), note them in `CONTEXT.md` so Claude doesn't expect a fully green pipeline on first push.
- Orb version pins matter — if a job starts failing with no config change, check whether an unpinned orb auto-updated.
