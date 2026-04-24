---
name: Issue tracker for {{PROJECT_NAME}}
description: Tickets for this project are tracked in JIRA project {{JIRA_PROJECT_KEY}}.
type: reference
---

Tickets for **{{PROJECT_NAME}}** are tracked in **JIRA project `{{JIRA_PROJECT_KEY}}`**.

- **Reference format:** `{{JIRA_PROJECT_KEY}}-123` — always include the project key, never bare ticket numbers.
- **MCP:** if a JIRA MCP server is connected in the session, use it to fetch ticket details; don't guess contents.

**Why:** work at this project is driven by JIRA tickets. Commit messages, branch names, and PR titles should reference the ticket so work is traceable from any layer.

**How to apply:**
- When the user mentions a ticket (e.g. `{{JIRA_PROJECT_KEY}}-42`), attempt to fetch it via the JIRA MCP first. If the MCP isn't connected, ask the user to paste the relevant ticket details rather than guessing.
- Branch names should include the ticket key: `feat/{{JIRA_PROJECT_KEY}}-42-short-slug`.
- PR titles should lead with the ticket key: `{{JIRA_PROJECT_KEY}}-42: <Conventional Commit summary>`.
- Commit messages follow Conventional Commits but should reference the ticket in the description when applicable: `fix(auth): handle expired tokens ({{JIRA_PROJECT_KEY}}-42)`.
- If the user references a ticket from a *different* JIRA project, flag it — the memorized project key is `{{JIRA_PROJECT_KEY}}` and cross-project work may need confirmation.
