---
name: Issue tracker for {{PROJECT_NAME}}
description: Stories for this project are tracked in Shortcut (formerly Clubhouse).
type: reference
---

Stories for **{{PROJECT_NAME}}** are tracked in **Shortcut**.

- **Reference format:** `sc-123` (common in commits/branches) or `[sc-123]` (Shortcut auto-links these). Also accepted: plain `#123` inside Shortcut's UI but prefer `sc-123` in git artifacts to disambiguate from GitHub-style issue refs.
- **Story URLs:** `https://app.shortcut.com/<workspace>/story/<number>` — the workspace slug is fixed per account; the `<number>` is global (not per-team).
- **MCP:** if a Shortcut MCP server is connected in the session, use it to fetch story details.

**Why:** work on this project is driven by Shortcut stories. Referencing the story ID in commits, branches, and PRs keeps work traceable and triggers Shortcut's auto-linking.

**How to apply:**
- When the user mentions a story (e.g. `sc-42`), attempt to fetch details via the Shortcut MCP first. If the MCP isn't connected, ask the user to paste the relevant story details rather than guessing.
- Branch names should include the story ID: `feat/sc-42-short-slug`. Shortcut's "copy git branch" feature generates this format automatically.
- PR titles should reference the story: `sc-42: <Conventional Commit summary>`.
- Commit messages follow Conventional Commits; include the story ID in the description when applicable: `fix(auth): handle expired tokens [sc-42]`.
