---
name: Issue tracker for widget-tracker
description: Tickets for this project are tracked via GitHub Issues on exampleco/widget-tracker.
type: reference
---

Tickets for **widget-tracker** live in GitHub Issues on `exampleco/widget-tracker`.

- **Ticket URLs:** `https://github.com/exampleco/widget-tracker/issues/<number>`
- **Reference format:** `#123` in-repo, `exampleco/widget-tracker#123` for cross-repo references.

**Why:** the repo is the single source of truth for work tracking; commits, PRs, and issues all cross-link natively.

**How to apply:**
- When the user mentions a ticket (e.g. `#42`), fetch it via `gh issue view 42` before reasoning about it — never guess contents.
- When opening a PR that resolves an issue, include `Closes #42` in the PR body so GitHub auto-closes on merge.
- When a commit references an issue, follow the Conventional Commits description with the reference (e.g. `fix(auth): handle expired tokens (#42)`).
