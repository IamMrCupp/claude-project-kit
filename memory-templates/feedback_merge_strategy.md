---
name: PR merge strategy — always merge commits
description: Always use "Create a merge commit" when merging PRs. Preserves branch topology and Conventional Commits that changelog tooling consumes. Never squash or rebase-merge.
type: feedback
---

When merging PRs, always choose **"Create a merge commit"** (the default first option in GitHub's merge dropdown). Never squash-merge. Never rebase-merge.

**Why:** squash-merging collapses all the granular Conventional Commits on a branch into one — which defeats changelog tooling (git-cliff, release-please) that parses per-commit messages to categorize changes. Rebase-merge linearizes history but loses the branch/merge topology that makes bisecting and reverting cleaner. Merge commits keep both: granular per-commit history and clear "what PR introduced this" boundaries.

**How to apply:**
- In GitHub: when clicking "Merge pull request", the dropdown should default to "Create a merge commit"
- If a repo has "Allow merge commits" disabled, re-enable it (Settings → Pull Requests)
- For work projects that mandate squash-merge — override this rule **by editing this memory file itself** (flip the body *and* the frontmatter `description:` together), not by copying a contradicting line into `CONTEXT.md`. Memory is the single source of truth for merge strategy; a second copy in `CONTEXT.md` drifts and can silently override this one (see `CONVENTIONS.md` → *Auto-memory*, and [#258](https://github.com/IamMrCupp/claude-project-kit/issues/258))
- Never force-push over someone else's merge commit to "clean up" — you'll rewrite history others may have pulled
