---
name: Use the repo's branch-name convention, not auto-generated worktree defaults
description: When working in a worktree, rename the auto-generated branch to match the repo's `<type>/<short-slug>` convention before pushing or opening a PR.
type: feedback
---

When a worktree is auto-created (e.g. by Claude Code), the branch is named something like `claude/sharp-moore-05b6d9`. **Do not push that name.** Before the first `git push`, rename the branch to match the repo's existing convention. Check `git log --all --oneline` for the pattern — typically `<type>/<short-slug>` like `feat/bootstrap-workspace-flag`, `docs/clarify-existing-repos`, `fix/lychee-placeholder-paths`.

```bash
git branch -m <new-name>
```

**Why:** PR titles are visible and reviewed; branch names show up in `git branch`, in PR URLs, in merge-commit messages, and in the repo's branch list long after the PR closes. A branch named `feat/bootstrap-workspace-flag` reads as deliberate; one named `claude/sharp-moore-05b6d9` reads as auto-generated noise. Both costs are small individually; both compound across a project's history.

**How to apply:**
- Before the first `git push -u origin <branch>` of a session, check `git log --all --oneline | grep -E '^\* |^[a-f0-9]+ '` — or just `gh pr list` — for the existing naming pattern.
- `git branch -m <type>/<short-slug>` to rename. The `<type>` should match the Conventional Commit type for the work (`feat`, `fix`, `docs`, `chore`, etc.).
- Apply on any repo where the existing branches follow a clear convention. If the convention isn't obvious from history, ask the user.
- This is a once-per-session check — after the rename, all subsequent pushes use the renamed branch.
