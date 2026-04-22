---
name: Current project context — {{PROJECT_NAME}}
description: What this project is, why it exists, timeline, stakeholders, and constraints that aren't obvious from the code.
type: project
---

**Project:** {{PROJECT_NAME}}
**Repo:** `{{REPO_SLUG}}`

{{One paragraph: what are we building, for whom, and why now. Not a feature list — the motivation and the deadline if there is one.}}

**Why:** {{the motivation — what problem is this solving, whose pain are we reducing, what changes for the user / business when this ships}}

**How to apply:**
- When suggesting scope changes or trade-offs, lean toward what serves the project's actual goal (above), not abstract correctness
- Flag anything that would push the {{deadline / milestone}} or reduce the core value proposition
- If the goal changes, update this memory — stale project memories cause bad suggestions

**Known constraints:**
- {{e.g. "Must support X platform even though it's painful because the primary user is on X"}}
- {{e.g. "Cannot depend on Y library for license reasons"}}
- {{e.g. "Ship before Z date because of [external dependency]"}}

**Stakeholders / audience:**
- {{Who reviews PRs, who uses the output, who cares if it breaks}}
