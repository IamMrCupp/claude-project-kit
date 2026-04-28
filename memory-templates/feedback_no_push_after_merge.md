---
name: Don't push commits to a branch after its PR has been merged
description: Once a PR is merged, the branch is closed. Commits pushed afterward get orphaned — they sit on the remote branch but never reach `main`. Branch off new `main` for follow-up work.
type: feedback
---

Once a PR has been merged, treat the branch as closed. **Do not push additional commits to it.** They land on the remote branch but the merge already happened, so the new commits are unreferenced from `main` and silently get lost on the next branch cleanup.

If you have more work for the same scope after the PR merged:

```bash
git checkout main
git pull --ff-only
git checkout -b <type>/<new-slug>
```

If the user is about to merge a PR and you have pending changes that should land in it (a follow-up commit you haven't pushed, a fix you noticed mid-review), **say so before they merge**. Either get the changes onto the branch first, or explicitly agree to a follow-up PR. Don't assume "I'll push it after" — after merge, the commit gets orphaned.

**Why:** the failure mode is silent. There's no error, no warning, no missing-commit alarm. The push succeeds, the branch shows the new commit on the remote, but `gh pr view` reports the original (pre-merge) file list, and `main` never gains the new content. Discovered cost can be substantial — the change has to be re-done in a follow-up PR, or worse, the original work feels "done" while the gap goes unnoticed for a while.

**How to apply:**
- After every PR merge, branch off the updated `main` for any follow-up work — never reuse the merged branch.
- Before the user merges, scan: is there work staged or in-flight that belongs in this PR? If yes, stop them and push first. If no, confirm and let them merge.
- If a commit *did* get orphaned (you notice the file list in `gh pr view` doesn't match what you expected), open a small recovery PR explicitly named "restore X (lost from #N)" rather than silently bundling it into a future feature PR.
- This rule applies equally to PRs the user merges and to auto-merged PRs (release-please, dependabot, etc.) — once merged is once merged.
