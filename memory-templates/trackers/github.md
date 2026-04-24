---
name: Issue tracker for {{PROJECT_NAME}}
description: Tickets for this project are tracked via GitHub Issues on {{REPO_SLUG}}.
type: reference
---

Tickets for **{{PROJECT_NAME}}** live in GitHub Issues on `{{REPO_SLUG}}`.

- **Ticket URLs:** `https://github.com/{{REPO_SLUG}}/issues/<number>`
- **Reference format:** `#123` in-repo, `{{REPO_SLUG}}#123` for cross-repo references.

**Why:** the repo is the single source of truth for work tracking; commits, PRs, and issues all cross-link natively.

**How to apply:**
- When the user mentions a ticket (e.g. `#42`), fetch it via `gh issue view 42` before reasoning about it — never guess contents.
- When opening a PR that resolves an issue, include `Closes #42` in the PR body so GitHub auto-closes on merge.
- When a commit references an issue, follow the Conventional Commits description with the reference (e.g. `fix(auth): handle expired tokens (#42)`).
