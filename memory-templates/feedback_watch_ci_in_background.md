---
name: Watch CI runs in the background
description: After pushing to a PR with active CI, spawn `gh run watch` in background mode. The task-notification system fires when CI completes — no polling.
type: feedback
---

After any `git push` to a branch with active CI, immediately start `gh run watch` in background mode:

```bash
sleep 3
RUN_ID=$(gh run list --branch <branch> --workflow "<Workflow Name>" --limit 1 --json databaseId --jq '.[0].databaseId')
gh run watch "$RUN_ID" --exit-status
```

Run with `run_in_background: true` on the Bash tool. The harness delivers a task-notification when CI completes.

**Why:** each CI iteration on a typical PR takes 3–10 minutes; over a multi-iteration session that's a lot of dead time if you're polling. Background watching converts every CI run into an async notification that lands exactly when it's ready to act on — so you can keep working on something else or end the session and come back when the ping fires.

**How to apply:**
- After every push to an actively-iterating PR, spawn the watcher
- `sleep 3–5s` before grabbing run ID — GitHub needs a moment to register the new push
- One watcher per push, picking the workflow that's being iterated on (usually the one whose config just changed). Don't spam multiple watchers.
- Each push creates new run IDs — re-spawn after each iteration push
- When a PR is finalized and all CI is green, no further watching needed
- Read the notification's output file to see the tail of `gh run watch` — it shows final step status
