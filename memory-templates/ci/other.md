---
name: CI/automation for {{PROJECT_NAME}}
description: This project uses a CI or automation tool that isn't covered by the kit's named variants — fill in the details below.
type: reference
---

**{{PROJECT_NAME}}** uses: **{{describe the CI/automation tool — e.g. Buildkite, Drone, TeamCity, Spinnaker, custom runners}}**

- **Config location:** {{e.g. `.buildkite/pipeline.yml`, `.drone.yml`, `teamcity/` in VCS root}}
- **Access:** {{URL / host / org info — or "see CONTEXT.md" if it's documented there}}
- **CLI or API:** {{command used to inspect runs / trigger builds, e.g. `buildkite-agent`, `drone build`}}
- **Secret/credential store:** {{where secrets live; how they're injected into jobs}}

**Why:** the project uses a CI or automation system that isn't GitHub Actions, GitLab CI, Jenkins, CircleCI, Atlantis, or local Ansible. Without this reference, Claude has no way to know the naming or lookup conventions.

**How to apply:**
- Fill in the placeholders above before relying on this memory.
- Add a `How to apply:` section with the patterns you actually use: how you watch runs, how you fetch failing logs, how you reference a build (`#NNN` vs `build-NNN` vs URL), and whether the user expects Claude to kick off runs or just interpret their output.
- If a dedicated MCP server exists for this CI/automation tool, note it here — Claude will use it for lookups when connected.
