---
name: Issue tracker for {{PROJECT_NAME}}
description: Tickets for this project are tracked in an external system — fill in the details below.
type: reference
---

Tickets for **{{PROJECT_NAME}}** are tracked in: **{{describe the tracker — Linear, Asana, Shortcut, custom, etc.}}**

- **Ticket URL pattern:** {{e.g. https://linear.app/acme/issue/ENG-123}}
- **Reference format:** {{e.g. `ENG-123`, `T-4567`, `[task 42]`}}
- **MCP or API access:** {{if a dedicated MCP server is available, name it; otherwise describe how ticket lookup happens — web, CLI, manual paste}}

**Why:** this project uses a tracker that isn't GitHub Issues or JIRA. Without this reference, Claude has no way to know the naming or lookup conventions and will guess incorrectly.

**How to apply:**
- Fill in the placeholders above before relying on this memory.
- When the user mentions a ticket, use the reference format above to identify it; use the MCP or lookup method named above to fetch details.
- Include the ticket reference in commit messages, branch names, and PR titles per your team's convention.
