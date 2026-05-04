---
name: Issue tracker for {{PROJECT_NAME}}
description: Tickets for this project are tracked via GitLab Issues on {{REPO_SLUG}}.
type: reference
---

Tickets for **{{PROJECT_NAME}}** live in GitLab Issues on `{{REPO_SLUG}}`.

- **Issue URLs:** `https://gitlab.com/{{REPO_SLUG}}/-/issues/<number>` (swap the host for self-hosted GitLab instances).
- **Reference format:** `#123` in-repo; `group/project#123` cross-project.
- **Merge requests:** GitLab calls them MRs, not PRs. Reference with `!123` (not `#`).
- **CLI:** `glab` is the GitLab equivalent of `gh` — if installed, prefer it for fetching issue/MR details.

**Why:** the repo is the single source of truth for work tracking; commits, MRs, and issues all cross-link natively within GitLab.

**How to apply:**
- When the user mentions an issue (e.g. `#42`), fetch it via `glab issue view 42` if the CLI is available; otherwise ask the user to paste the relevant issue details.
- When opening an MR that resolves an issue, include `Closes #42` in the MR description so GitLab auto-closes on merge.
- When a commit references an issue, follow Conventional Commits with the reference (e.g. `fix(auth): handle expired tokens (#42)`).
- When a commit references an MR (unusual but happens), use `!NN` — don't confuse it with `#NN`.
- **Issue-first when this is the user's own project.** If the user owns the tracker (their personal GitLab project's Issues), open an issue *before* starting trackable work and record `Issue: #N` in the phase checklist alongside `Branch:` / `PR:`. When carving a phase checklist into issues, propose the full list (titles + bodies + labels) and confirm before bulk-creating with `glab issue create`. Single ad-hoc issues during a session are fine without heavyweight confirmation; the constraint is on bulk operations. See `CONVENTIONS.md` → *Ticket-driven workflows* → *Issue-first when you own the tracker* for the full rule. (For projects where someone else owns the tracker — group-owned, upstream OSS — stay read-only per `feedback_no_tracker_creation.md`.)
