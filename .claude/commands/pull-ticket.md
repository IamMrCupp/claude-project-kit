---
description: Pull a tracker ticket into a per-ticket scratchpad. Reads tracker config from CONTEXT.md, fetches ticket data via the relevant MCP (JIRA / GitHub Issues / Linear), creates tickets/<KEY>-<slug>.md from the kit's template, updates workspace-CONTEXT.md, appends to SESSION-LOG.md. Read/reference only — never pushes back to the tracker.
argument-hint: <KEY>
---

## Precheck — is this a kit project?

Before doing anything else:

1. Look up `reference_ai_working_folder.md` in this project's auto-memory.
2. If it isn't there, OR the working-folder path it points to doesn't have a `CONTEXT.md` file, **stop** and tell me:
   > "No kit working folder found for this project. To use this command, either run `bootstrap.sh` from the kit (https://github.com/IamMrCupp/claude-project-kit) to create one, or `cd` into a kit-bootstrapped repo. If a working folder exists at a non-default path, tell me and I'll load from there."
3. Don't load partial state. If any required file is missing, treat the project as not-bootstrapped and bail with the message above.

If the precheck passes, continue.

---

I want to pull ticket `$ARGUMENTS` from the project's tracker into a per-ticket scratchpad. Read-only — do not push anything back to the tracker.

## Step 1 — determine tracker config

Read `CONTEXT.md` in the working folder. Find the **Tracker Configuration** section. If `../workspace-CONTEXT.md` exists, also read it — workspace-level tracker config takes precedence in workspace mode.

Pull these values:

- **Tracker type** (jira / github / linear / gitlab / shortcut / other / none)
- **Project / team key** (e.g. `ACME`, `INFRA`, `ENG`)
- **MCP availability**

Stop and ask the user before continuing if any of these hold:

- Tracker type is `none` or `other` — there's no automated path; the user can either set up tracker config first or fall back to a manual stub.
- MCP availability says `not installed` or `unknown` — confirm the relevant MCP is available before attempting to fetch.
- The ticket key doesn't match the project key — e.g. tracker is JIRA project `ACME` but the user asked for `INFRA-42`. This is usually a typo or wrong-project mistake.

## Step 2 — fetch ticket data

Use the tracker MCP that matches the configured type. **Read-only** operations only: get / view / search. Never create, edit, transition, or comment.

- **JIRA** — use the JIRA MCP. Fetch: summary, description, acceptance criteria (or definition of done if AC isn't separate), status, assignee, sprint, parent epic if any.
- **GitHub Issues** — use the GitHub MCP if available, otherwise fall back to `gh issue view <NUM> --json title,body,state,labels,assignees,milestone`. The issue lives at `<REPO_URL>/issues/<NUM>`.
- **Linear** — use the Linear MCP. Fetch: title, description, state, priority, AC, project / cycle.
- **GitLab** — use the GitLab MCP if available, otherwise `glab issue view <NUM>` against the configured repo.
- **Shortcut** — use the Shortcut MCP if available, otherwise pause and ask the user how to fetch.

If the relevant MCP isn't available and there's no CLI fallback, stop and tell the user — don't silently produce a stub. The user can choose to install the MCP, install the CLI, or proceed with a manual stub.

## Step 3 — create the ticket file

**Determine the tickets directory:**

- Workspace mode (`../workspace-CONTEXT.md` exists): tickets go in `../tickets/`. The `tickets/archive/` subdirectory should already exist from `bootstrap.sh --workspace`.
- Single-repo mode: tickets go in `<working-folder>/tickets/`. Create `tickets/` and `tickets/archive/` with `mkdir -p` if they don't exist.

**Generate the slug:**

- Take the ticket title from the tracker.
- Lowercase, replace non-alphanumeric runs with `-`, trim leading/trailing dashes, cap at ~40 chars.
- Example: title "Fix LB path-routing for /api/v2" → slug `fix-lb-path-routing-for-api-v2`.

**File path:** `<tickets-dir>/<KEY>-<slug>.md` (e.g. `tickets/ACME-1234-fix-lb-path-routing.md`).

**Idempotence guard:** if a file matching `<KEY>-*.md` already exists in either `tickets/` or `tickets/archive/`, stop and ask the user before overwriting. They may have an existing scratchpad with notes worth preserving.

**Fill the template:** use the kit's `templates/workspace/ticket.md` shape (already in the workspace if `bootstrap.sh --workspace` ran; otherwise read from the kit checkout). Substitute:

- `{{KEY}}` → the ticket key
- `{{TITLE}}` → from the tracker
- `{{TRACKER_URL}}` → canonical tracker link to this specific ticket
- `{{Open | In progress | Blocked | Done}}` → actual status (map tracker-specific status names to one of these four; note the tracker-native name in parens if it doesn't fit cleanly)
- `{{YYYY-MM-DD}}` → today's date (both Created and Last touched)
- **Summary section** → fill from the tracker description (one paragraph, plain prose; don't paste the entire ticket body if it's long — that's what the tracker is for)
- **Acceptance criteria** → copy verbatim from the tracker. Convert numbered/bulleted lists to `- [ ] {{...}}` checkboxes if not already.
- **Working notes** → leave empty (Claude/user fills as work happens)
- **Branches / PRs / commits** → leave the example row in place as a structure hint
- **Decisions / blockers** → leave empty
- **Cross-references → Sessions** → leave empty (filled by `/session-end` or `/close-phase`)
- **Cross-references → Related tickets** → if the tracker shows links / blockers / dependencies, list them; otherwise leave the placeholder

## Step 4 — update workspace-CONTEXT.md (workspace mode only)

If in workspace mode, open `../workspace-CONTEXT.md`. Find the `## Tickets` section, then the `**Active:**` sub-section.

If the placeholder example bullet is still there (`- [{{KEY}}](tickets/{{KEY}}-{{slug}}.md) — {{one-line summary; repos touched}}`), replace it. Otherwise append a new bullet:

```
- [<KEY>](tickets/<KEY>-<slug>.md) — <one-line summary from tracker>; <repos touched, or "TBD" if unknown>
```

Bump the `**Last updated:**` date at the top of `workspace-CONTEXT.md`.

## Step 5 — log it

Stage (do not yet write) a one-line addition to the working folder's `SESSION-LOG.md` for the current session entry:

```
- Pulled <KEY> — <one-line summary>
```

If `/session-end` runs later this session, this line should be folded into the session entry's "Branches/PRs/Tickets" block. If you're appending to an in-flight entry, append directly.

## Step 6 — hand back

Print:

1. Path to the new ticket file (e.g. `tickets/ACME-1234-fix-lb-path-routing.md`).
2. First three lines of the file: key + title, tracker link, status.
3. A reminder: "Tracker is source of truth — re-run `/pull-ticket <KEY>` if the tracker changes. This file is the local working scratchpad."

Then stop. Don't propose a branch name, don't open a worktree, don't start work. The user drives next — typically by checking the kit's CONVENTIONS.md (Ticket-driven workflows section) for the branch / PR / commit shape and starting from there.
