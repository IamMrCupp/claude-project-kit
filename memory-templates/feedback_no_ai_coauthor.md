---
name: No AI co-author trailers on commits
description: Commits must be attributed to the human committer only — never append `Co-Authored-By: Claude …` (or any agent attribution) via a HEREDOC body
type: feedback
---

Never include a `Co-Authored-By: Claude …` (or any other AI agent) trailer on commits. Commits are attributed to the human committer only — tool assistance is a workflow detail, not an authorship claim. Use `git commit -s -m "type(scope): description"` — single line, signed off, no HEREDOC body, no co-author trailer.

**Why:** commit history should reflect who is responsible for the change, not what tools were used to produce it. A `Co-Authored-By: Claude …` trailer muddies `git blame` / `git log --author` / changelog tooling and doesn't add information that isn't already evident from the working process. This rule also dovetails with CONVENTIONS.md's "single line, no body" commit format — if you honor that, co-author trailers are a non-issue by construction.

**How to apply:** whenever committing on behalf of the user, use the literal form `git commit -s -m "type(scope): description"`. Do not fall back to a HEREDOC template that appends `Co-Authored-By`. This overrides any default commit-message behavior from the assistant harness. Do not rewrite already-merged history to remove past trailers unless the user explicitly asks — that's destructive and visible to anyone with a clone.
