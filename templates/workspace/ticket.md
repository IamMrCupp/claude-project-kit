# {{KEY}} — {{TITLE}}

- **Tracker:** [{{KEY}}]({{TRACKER_URL}})
- **Status:** {{Open | In progress | Blocked | Done}} — sync with tracker periodically; tracker is source of truth.
- **Created:** {{YYYY-MM-DD}}
- **Last touched:** {{YYYY-MM-DD}}

---

## Summary

{{One paragraph from the tracker, or hand-written if pulled before the ticket was fleshed out. Keep in sync with the tracker — this file is a working scratchpad, not a replacement for the tracker.}}

---

## Acceptance criteria

{{Pulled from the tracker. Don't paraphrase — copy verbatim and add inline notes if needed. If criteria evolve in the tracker, update here.}}

- [ ] {{AC bullet}}
- [ ] {{AC bullet}}

---

## Working notes

{{Free-form Claude-managed notes — what's been tried, what's been decided, what's still open. Append-style is fine; structure is loose. This is the scratchpad, not the deliverable.}}

---

## Branches / PRs / commits

Multi-repo tickets accumulate work across repos. List branches and PRs here so the ticket scratchpad is the cross-repo coordination point.

| Repo | Branch | PR | Status |
|---|---|---|---|
| {{repo-a}} | `{{type}}/{{KEY}}-{{slug}}` | #{{N}} | merged / open / draft |

---

## Decisions / blockers

- {{YYYY-MM-DD: decision or blocker, with brief rationale}}

---

## Cross-references

- **Sessions that touched this ticket:** {{list per-repo `SESSION-LOG.md` entries by date}}
- **Related tickets:** {{KEY1 (dependency), KEY2 (follow-up)}}
- **Workspace context:** `../workspace-CONTEXT.md` (sibling of the `tickets/` directory after deployment)

---

## Archive note

When the upstream tracker ticket closes, move this file to `../tickets/archive/`. Add a 1–2 sentence "what shipped" note here before archiving so the archive is grep-able for "what did we do for `{{KEY}}`".

{{Pre-archive note goes here.}}
