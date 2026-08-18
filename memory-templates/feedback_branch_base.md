---
name: Branch from an up-to-date default branch
description: Before `git checkout -b`, return to the default branch and pull. Never cut a branch from another branch whose PR is still open — the child carries the parent's commits into main past the parent's review gate.
type: feedback
---

Cutting a branch is **two steps, not one**:

```bash
git checkout main && git pull && git checkout -b <type>/<slug>
```

Never branch off a feature branch whose PR hasn't merged yet.

**Why:** a branch stacked on an unmerged branch carries the parent's commits. When the child PR merges, **the parent's commits land in `main` too — bypassing the parent PR's own review and CI gate.** If the parent PR later needed rework or rejection, too bad; it already shipped. The history misleads as well: `git log` attributes the parent's work to a merge commit named for the child's PR, so "when did we change X?" points at a PR about something else. `git blame` still resolves correctly, which is why this is easy to miss until it matters.

This is distinct from [[feedback_no_work_on_main]], which is about not *editing* on `main`. That rule tells you to get **off** `main`; this one tells you to go **back** to it before branching again. Read together they mean: sync, branch, work, merge, sync again. [[feedback_no_push_after_merge]] covers the post-merge case ("branch off new `main` for follow-up work") — this covers the case where the parent PR is still **open**, which is the one that actually causes damage.

**Watch for the interaction with the branch-first hook.** `block-edit-on-protected-branch.sh` (see [[feedback_no_work_on_main]]) *blocks* edits while on `main`. That's correct, but it creates pressure to stay off `main` — so a session already on a feature branch has a disincentive to check out `main` before cutting the next one. The hook does not enforce base branch; only this rule does. Don't let "I'd be blocked on `main`" become "so I'll branch from here."

**How to apply:**
- Applies to the second and third branch of a session as much as the first. Finishing a PR does not put you on a clean base — you're still on the branch you just pushed.
- Symptoms: a PR diff containing files you never touched, or `git log --graph` showing your branch descending from another feature branch instead of from `main`.
- Caught before pushing → `git rebase --onto main <wrong-base>` fixes it.
- Caught after merging → **leave it.** Rewriting shared history costs more than a mislabelled merge commit, and it breaks any other checkout of that branch.
- Deliberately stacked PRs are a legitimate pattern when work genuinely depends on unmerged work — but say so explicitly in the PR body, and expect the base PR to merge first.
