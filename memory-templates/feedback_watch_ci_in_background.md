---
name: Watch CI runs in the background and surface failures before the user does
description: After pushing to a PR with active CI, spawn `gh run watch --exit-status` in background mode. A PR isn't "done" until checks are green — never claim success without watching.
type: feedback
---

After any `git push` to a branch with active CI, immediately start `gh run watch` in background mode in the same turn as the push:

```bash
sleep 3
RUN_ID=$(gh run list --branch <branch> --workflow "<Workflow Name>" --limit 1 --json databaseId --jq '.[0].databaseId')
gh run watch "$RUN_ID" --exit-status
```

Run with `run_in_background: true` on the Bash tool. The harness delivers a task-notification when CI completes.

**Why:** two reasons, both load-bearing.
1. **Trust.** A PR isn't ready, complete, or "open for review" until checks pass. If you push and report the PR back without watching, you'll either claim success on a red check or force the reviewer to spot the failure for you. Both cost trust the kit's whole pacing relies on.
2. **Productivity.** Each CI iteration takes 3–10 minutes; over a multi-iteration session that's a lot of dead time if you're polling. Background watching converts every CI run into an async notification that lands exactly when it's ready to act on — so you can keep working on something else or end the session and come back when the ping fires.

**How to apply:**
- After every push to an actively-iterating PR, spawn the watcher in the **same turn** as the push — not the next turn, not after summarizing the PR.
- `sleep 3–5s` before grabbing run ID — GitHub needs a moment to register the new push.
- One watcher per push, picking the workflow that's being iterated on (usually the one whose config just changed). Spawn one per workflow if multiple are likely to fail independently (e.g. lint + test).
- Each push creates new run IDs — re-spawn after each iteration push.
- If a check fails, surface it immediately with the failing log, propose a fix, and re-watch after the fix push. Don't wait for the user to ask.
- When a PR is finalized and all CI is green, no further watching needed.
- Read the notification's output file to see the tail of `gh run watch` — it shows final step status.
