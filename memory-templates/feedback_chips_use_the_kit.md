---
name: Spawned task chips must tell the new session to use the kit
description: In a kit-bootstrapped project, every task chip spawned with `spawn_task` opens with the kit — `/session-start` first, the auto-memory rules the task will hit, issue-first when the tracker is user-owned, `/session-end` last. If the kit isn't present, the chip says nothing about it.
type: feedback
---

A task chip spawned with `spawn_task` starts a **cold** session. It doesn't inherit this conversation or anything you "just know" — it knows only what the chip prompt says. So when the project uses the kit, the prompt has to carry the kit with it. Open every chip prompt with these four points, then describe the task:

1. **Invoke `/session-start`** — loads `CONTEXT.md`, `SESSION-LOG.md`, and the current phase checklist from the working folder ([[reference_ai_working_folder]]).
2. **Follow this project's auto-memory rules — and name the ones the task will hit.** "Follow the rules" on its own gets skimmed past. Spell out the ones in play: branch naming ([[feedback_branch_naming]]), branch first and from an up-to-date base ([[feedback_no_work_on_main]], [[feedback_branch_base]]), signed single-line commits with no AI co-author trailer ([[feedback_commit_format]]), merge commits only ([[feedback_merge_strategy]]), push and watch CI ([[feedback_push_branches]], [[feedback_watch_ci_in_background]]), no manual tagging when release automation is configured ([[feedback_release_per_pr]]). Add any project-specific rule the task touches — a CI toolchain to validate against, another session's open PRs to check before merging.
3. **Issue-first when the tracker is user-owned** ([[feedback_no_tracker_creation]]) — open the issue before the work; the PR closes it. For an externally-owned tracker, reference the existing ticket instead.
4. **Finish with `/session-end`** — it drafts the SESSION-LOG / CONTEXT updates and waits for the user's confirmation.

**Why:** a chip that only describes the technical work produces a session that never loads the working folder, doesn't know the conventions, skips the tracker, and leaves no trace in the SESSION-LOG. The work might land fine — but it lands off the books, and the next session inherits a working folder that's quietly wrong. This rule came from a chip that had to be rewritten because its first draft was all technical detail and no kit.

**How to apply:**
- Before writing any chip prompt, check whether the kit is present: `~/.claude/scripts/kit-print-memory-pointer.sh` resolves, and the working folder it points to has a `CONTEXT.md`.
- **Kit present** → the four points go at the top of the prompt, then the task.
- **Kit absent** → say nothing about it. No `/session-start`, no "use the kit if available." A chip that invokes slash commands the project doesn't have just burns the new session's first turn.
- The prompt still has to stand alone on the technical side — file paths, what you noticed, what "done" looks like. The kit points are the frame, not a substitute for the task.
