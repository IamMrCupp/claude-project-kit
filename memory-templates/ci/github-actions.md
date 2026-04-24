---
name: CI for {{PROJECT_NAME}} — GitHub Actions
description: This project runs CI on GitHub Actions. Workflows live at `.github/workflows/`; `gh run` is the CLI of record.
type: reference
---

**{{PROJECT_NAME}}** runs CI on **GitHub Actions**.

- **Workflow files:** `.github/workflows/*.yml` in the repo.
- **CLI:** `gh run` for inspection (`gh run list`, `gh run view <id>`, `gh run watch <id>`).
- **Logs:** `gh run view <id> --log` for full output; `--log-failed` for just the failing steps.
- **Secrets:** repo-level at *Settings → Secrets and variables → Actions*; org-level inherited for org-owned repos.

**Why:** standardizing on `gh run` (rather than the web UI) keeps CI observation scriptable and surfaces enough detail inline that Claude doesn't have to ask the user to paste logs.

**How to apply:**
- After pushing a branch that should trigger CI, wait ~5s for the run to register, then fire `gh run watch` in the background so the completion pings the session. Don't poll.
- On CI failure, fetch `gh run view <id> --log-failed` first — scope to the failing steps before reading the whole log.
- Never re-run workflows blindly to "fix" a flake. Identify the root cause or flag the flake explicitly in the SESSION-LOG.
- When opening a PR, rely on `gh pr checks` to see required checks at a glance.
