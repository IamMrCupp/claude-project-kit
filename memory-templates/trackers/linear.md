---
name: Issue tracker for {{PROJECT_NAME}}
description: Tickets for this project are tracked in Linear team {{LINEAR_TEAM_KEY}}.
type: reference
---

Tickets for **{{PROJECT_NAME}}** are tracked in **Linear team `{{LINEAR_TEAM_KEY}}`**.

- **Reference format:** `{{LINEAR_TEAM_KEY}}-123` — always include the team key.
- **MCP:** if a Linear MCP server is connected in the session, use it to fetch ticket details; don't guess contents.

**Why:** work on this project is driven by Linear issues. Commit messages, branch names, and PR titles should reference the issue so work is traceable from any layer.

**How to apply:**
- When the user mentions an issue (e.g. `{{LINEAR_TEAM_KEY}}-42`), attempt to fetch it via the Linear MCP first. If the MCP isn't connected, ask the user to paste the relevant issue details rather than guessing.
- Branch names should include the issue key: `feat/{{LINEAR_TEAM_KEY}}-42-short-slug`. Linear's "copy git branch name" feature in the issue view gives you this format.
- PR titles should lead with the issue key: `{{LINEAR_TEAM_KEY}}-42: <Conventional Commit summary>`.
- Commit messages follow Conventional Commits; reference the issue in the description when applicable: `fix(auth): handle expired tokens ({{LINEAR_TEAM_KEY}}-42)`.
- If the user references an issue from a *different* Linear team, flag it — the memorized team key is `{{LINEAR_TEAM_KEY}}`.
