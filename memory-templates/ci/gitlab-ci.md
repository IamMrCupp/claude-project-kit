---
name: CI for {{PROJECT_NAME}} — GitLab CI
description: This project runs CI on GitLab CI/CD. Pipeline config is `.gitlab-ci.yml`; `glab ci` is the CLI of record.
type: reference
---

**{{PROJECT_NAME}}** runs CI on **GitLab CI/CD**.

- **Pipeline config:** `.gitlab-ci.yml` at the repo root (includes may fan out to other files).
- **CLI:** `glab ci` (`glab ci list`, `glab ci view <pipeline-id>`, `glab ci watch`). `glab ci trace` streams job logs.
- **Jobs vs pipelines:** a pipeline is a collection of jobs; always disambiguate. A job ID is different from a pipeline ID — specify which you're fetching.
- **Variables:** pipeline/job variables at *Settings → CI/CD → Variables*; group-level variables inherited.
- **Runners:** shared vs group vs project runners; check `.gitlab-ci.yml` tags to know which runner pool a job targets.

**Why:** GitLab's CI conflates "pipeline" and "job" in several UI spots, and the CLI is less familiar than `gh run`. Being explicit about which layer you're inspecting prevents confusion.

**How to apply:**
- After pushing, wait ~5s then fire `glab ci watch` in the background so the pipeline outcome pings the session.
- On failure, identify the failing **job** (not pipeline) and fetch `glab ci trace <job-id>` for its log specifically.
- MR pipelines are different from branch pipelines — confirm which the user is asking about before fetching.
- Don't retry jobs to mask flakes; flag them in the SESSION-LOG.
