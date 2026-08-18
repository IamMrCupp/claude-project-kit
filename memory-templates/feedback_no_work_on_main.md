---
name: Branch first — never start work on main
description: Before editing tracked files, check the current branch; if it's main / the default branch, propose a `<type>/<slug>` branch and switch to it before writing any code.
type: feedback
---

Before editing any tracked file, check the current branch (`git branch --show-current`). If it's `main` (or the repo's default branch), **stop** — propose a `<type>/<slug>` branch name, create it, and only then start editing.

```bash
git checkout -b <type>/<slug>   # feat/…, fix/…, docs/…, ci/…, chore/…
```

**Why:** the harness edits whatever branch is checked out, and a fresh session usually opens on `main`. Editing on `main` means no PR, no review, no CI gate, and a dirty default branch that has to be unwound by hand. Naming the branch *before* writing code also forces the "is this one PR or two?" decision up front, instead of discovering mid-session that the work should have been split. The rule lives in `CONVENTIONS.md` ("Branch name first, then code"), but a session that only loads the memory index — not the linked files — needs it surfaced here. See also [[feedback_branch_naming]] (naming convention) and [[feedback_push_branches]] (pushing once a branch exists).

**How to apply:**
- First edit of a work session: if `git branch --show-current` is the default branch, propose a branch name and switch *before* touching tracked files. Don't ask permission to *check* the branch — just check, and propose if needed.
- Read-only work (reading files, `git log`, `git diff`, `gh` queries) is fine on `main` — the rule is about *edits* to tracked files.
- Working-folder files (the private `CONTEXT.md` / `SESSION-LOG.md` outside the repo) aren't tracked repo files — editing those doesn't require a branch.
- If the user explicitly authorizes a direct commit to `main` for a specific one-off, that's their call — but surface the branch option first and let them override.

**Structural enforcement (recommended).** The kit ships a `PreToolUse` Edit/Write hook (`scripts/block-edit-on-protected-branch.sh`) that the harness uses to deny edits to in-repo files when the current branch is `main` / `master`. Wire it once per machine — see `SETUP.md` → *Optional: branch-first enforcement hook*. With the hook installed, this memory entry becomes a "why the harness just blocked me" reference rather than a guidance reminder. Sibling of the commit-format hook (`feedback_commit_format`).

**The hook does not enforce *base* branch.** By blocking edits on `main` it creates pressure to stay off it — which can turn into branching off whatever feature branch is already checked out. See [[feedback_branch_base]]: return to `main` and pull *before* `git checkout -b`, every time.
