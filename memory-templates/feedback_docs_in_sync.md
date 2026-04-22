---
name: Keep planning docs in sync as work lands
description: Update plan.md / phase-N-checklist.md / implementation.md as PRs merge, not just at phase boundaries. Session-end drift check before writing the SESSION-LOG entry.
type: feedback
---

The working folder's planning docs should reflect reality at all times — not just at phase boundaries. Specifically:

- **`phase-N-checklist.md`** — tick the item and record its branch name + PR number the moment the PR merges
- **`implementation.md`** — amend the task's approach block if the implementation diverged from the original spec
- **`plan.md`** — bump the status line when a phase transitions or a major open question resolves

**Why:** docs that are only updated at phase boundaries inevitably drift. By the time you go to update them, you've forgotten the small-but-important details (why a branch was renamed mid-flight, why you abandoned a sub-task, what the PR-review comments changed). Updating inline while context is fresh keeps the docs useful as memory aids instead of ceremonial.

**How to apply:**
- After every PR merge: update the checklist and (if applicable) implementation.md in the same Claude session — don't wait
- Before writing a `SESSION-LOG.md` entry at session end, do a quick drift check: "Do the planning docs still match reality?" Fix anything that's wrong before logging
- If a task's approach changed mid-implementation, add a one-line note under the implementation.md spec ("Landed with X instead of Y because Z") — don't silently edit the original spec
