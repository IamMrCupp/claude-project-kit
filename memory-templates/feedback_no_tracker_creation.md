---
name: Never create tracker projects, labels, workflows, or sprint scaffolding
description: External trackers (JIRA, Linear, etc.) are typically owned by PMs / the business. The kit and Claude operating within it must only read/reference existing projects — never create them or modify their structure.
type: feedback
---

When kit features or Claude actions touch external trackers (JIRA, Linear, GitHub Issues, GitLab, Shortcut, etc.), the rule is **read/reference only** for any tracker that's owned by someone other than the user. Never create tracker projects, labels, workflow states, sprint configurations, or any structural artifact in those tools. Capture *references* to projects that already exist (project key, MCP availability, link) and let the human owners handle creation.

**Why:** at most workplaces, tracker projects map to teams or initiatives and are governed by PMs, program managers, or admin teams. A bootstrap that spins up its own project would step on that ownership, create duplicates, and likely violate org policy. The same logic extends to labels and workflows — those encode team-wide conventions that an individual contributor (or AI assistant) shouldn't unilaterally change.

**How to apply:**
- When designing features that touch trackers (bootstrap prompts, MCP integrations, automation), default to **read/reference only** for business-owned trackers.
- Do not propose flows that call `gh project create`, `jira project create`, `linear team create`, or equivalents — for any tracker the user doesn't personally own.
- **Creating individual issues/tickets inside an existing project is on the table** when the user explicitly asks for it. The constraint is on structural / project-level artifacts, not on standard work-item creation.
- Personal repositories where the user owns the tracker directly (e.g. their own GitHub Issues + Project board on a personal repo) are the exception — there, creation is fine if the user authorizes it.
- If unsure whether a tracker is "owned by the user" or "owned by the business," ask first. Default to assuming business-owned.
