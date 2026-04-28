# Claude Working Context — {{PROJECT_NAME}}
**Last updated:** {{YYYY-MM-DD}}
**Project:** `{{REPO_SLUG}}`
**Repo path:** `{{REPO_PATH}}`

---

## How to load this context

At the start of any new Claude session, say:
> "Read CONTEXT.md and SESSION-LOG.md in this folder before we start."

> **Folder shape:** {{single-repo | per-repo subfolder of a workspace}}. If this folder is a per-repo subfolder of a workspace, also load `../workspace-CONTEXT.md` for cross-repo context and any active `../tickets/<KEY>-<slug>.md` files in scope for the session.

---

## Project Overview

{{ONE_PARAGRAPH_DESCRIPTION}}

- **GitHub / host:** {{REPO_URL}}
- **Visibility:** {{public | private | internal}}
- **Platform targets:** {{PLATFORM_TARGETS}}
- **This folder:** Private AI working context — never commit to repo

---

## Tracker Configuration

The external tracker for this project, used when work is ticket-driven. See `CONVENTIONS.md` (kit-level — `## Ticket-driven workflows`) for the branch / PR / commit conventions to use against a tracker.

- **Tracker type:** {{none | github | jira | linear | gitlab | shortcut | other}}
- **Project / team key:** {{KEY — e.g. LX, INFRA, ENG; leave blank if not applicable}}
- **MCP availability:** {{installed | not installed | unknown}}
- **Tracker link:** {{URL — leave blank if none}}

If this folder lives in a workspace (multi-repo initiative), tracker config commonly lives at the workspace level (`../workspace-CONTEXT.md`) instead of duplicated here. Leave this section as-is or remove it as appropriate.

---

## Planning Document System

This folder uses a layered documentation system. Reuse this pattern when starting each phase — don't invent new conventions.

- **`plan.md`** — high-level project plan (phases, goals, platform targets, Open Questions, risks). Updated rarely.
- **`implementation.md`** — detailed per-task implementation specs across all phases. Items are numbered; other docs reference them (e.g. "see §1.8").
- **`phase-N-checklist.md`** — trackable task list for ONE phase (one file per phase). Items map roughly 1:1 to branches/PRs.
- **`acceptance-test-results.md`** — manual verification log for the current phase's acceptance testing.
- **`research.md`** — frozen technical research that informed the plan. Effectively read-only after Phase 0.
- **`SESSION-LOG.md`** — chronological session-by-session history. Append-only at the end of each session.
- **`CONTEXT.md`** — this file; the "read first" summary every new session loads.

**Phase lifecycle:**
1. **Phase start** → create `phase-N-checklist.md` breaking the phase into trackable items that reference `implementation.md` specs
2. **Per item** → branch name (confirm first) → commit(s) → PR → update checklist with branch + PR number + mark ✅
3. **Phase end** → run acceptance test sequence, record results in `acceptance-test-results.md`, mark phase complete in checklist + `plan.md`
4. **Always** → append a session entry to `SESSION-LOG.md` at end of each working session

---

## Working Rules

### Git & commits
- {{Conventional Commits, single line, `-s` sign-off — OR whatever this project uses}}
- {{Branch naming convention}}
- {{Merge strategy — merge commit / squash / rebase}}

### PRs
- {{Template location if any}}
- {{Required reviewers, required checks}}
- Manual test plan required for runtime changes — see CONVENTIONS.md

### Shell / build
- {{Shell in use — bash / zsh / fish / pwsh}}
- {{Local build command}}
- {{Local test command}}

### File editing
- Repo is mounted at `{{REPO_PATH}}`
- Claude reads + edits directly; never copy-paste code through chat

---

## Current Phase Status

{{Fill in as work progresses — see SESSION-LOG.md for detail}}

**Known issues / open threads:**
- {{…}}

---

## Key Dependencies

{{List anything non-trivial — platform-specific build flags, SDK versions, external services. Anything a future session would want to know without re-deriving it.}}

---

## CI Overview

- {{CI platform: GitHub Actions / GitLab CI / Jenkins / etc.}}
- {{Targets — platforms, architectures}}
- {{Quality gates — lint, format, CodeQL, tests, etc.}}

---

## Acceptance Testing Setup

{{If manual acceptance testing is required: test environment, tooling, account credentials reference (DO NOT store credentials here), reset procedure.}}

---

## Open Questions

| # | Question | Status |
|---|---|---|
| 1 | {{…}} | ⏳ Open / ✅ Resolved — see §X |

---

## Reference

- `plan.md` — Full project plan and phase breakdown
- `implementation.md` — Detailed implementation specs per item
- `phase-N-checklist.md` — Current checklist with branch/commit info
- `research.md` — Technical research backing the plan
- `SESSION-LOG.md` — Chronological history of sessions and decisions
