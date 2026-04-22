---
name: Push branches to origin by default
description: After committing to a feature branch, push to origin without asking. Still confirm for force-push or push-to-main.
type: feedback
---

After a normal `git commit` on a feature branch, immediately run:

```bash
git push -u origin <branch>
```

No confirmation prompt needed for the first push or subsequent pushes on the same branch.

**Why:** pushing a feature branch is low-risk and high-value — CI starts running, the PR's diff updates, the backup is off-machine. Asking "should I push?" every time adds friction with no safety upside. Destructive pushes (force-push, push to main/default branch) are the only ones that need a second look.

**How to apply:**
- Normal push of a feature branch: just do it
- Force-push (`--force`, `--force-with-lease`): confirm first — say what you're about to force-push and why
- Push to `main` / default branch: refuse unless explicitly authorized for this specific push. Prefer a PR.
- If the push fails (non-fast-forward, auth, etc.), surface the error — don't auto-retry with `--force`
