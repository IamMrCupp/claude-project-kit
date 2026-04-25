---
description: Close a project phase — tick the checklist, update plan.md status, archive acceptance results, append a SESSION-LOG entry. Drafts everything; waits for confirmation before writing.
argument-hint: [phase-number]
---

Close phase $ARGUMENTS of this project. If no phase number was given, read `CONTEXT.md` and infer the current phase.

## Files to load

- `<working-folder>/CONTEXT.md` — current phase status
- `<working-folder>/plan.md` — phase breakdown
- `<working-folder>/phase-$ARGUMENTS-checklist.md` (or current `phase-N-checklist.md`)
- `<working-folder>/SESSION-LOG.md` — last entry for context
- `<working-folder>/acceptance-test-results.md` if it exists

The working-folder path comes from `reference_ai_working_folder.md` in auto-memory. If that's not set, ask the user before guessing.

## What to do

1. **Tick remaining unchecked items** in the phase checklist. For each, find the matching merged PR (`gh pr list --state merged`) and add the PR number + merge date. If no PR exists for an item, flag it for human review rather than ticking blindly.
2. **Update plan.md "Status" line** at the top to reflect phase closure (e.g. `Phase N complete ✅ (YYYY-MM-DD)`).
3. **Update CONTEXT.md "Current Phase Status"** block — mark the closing phase complete, set the next phase posture (often "Deferred — no active work").
4. **Archive acceptance results** if `acceptance-test-results.md` exists and is non-empty: rename to `acceptance-test-results-phase-$ARGUMENTS.md` and update the CONTEXT.md Reference section to point at the archive.
5. **Draft a SESSION-LOG entry** for this session covering: focus, PRs landed, key decisions, non-obvious findings, open threads.

## Hand back

Show each change as a diff (or as the proposed file content if it's a new file). Wait for the user's confirmation per change before writing.

Do not invoke `git commit` or push. The user commits the working-folder updates separately when they're ready.
