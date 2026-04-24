# Conventions — working rules that travel well

Project-agnostic habits that have proven out across real work. Start from these, keep what fits the project, drop what doesn't. For work projects, reconcile with employer policy before adopting.

> **Tooling assumptions:** examples are written for **Git + GitHub + GitHub Actions + the `gh` CLI**. Principles translate cleanly to GitLab (MRs, `glab`), Bitbucket, Jenkins, Azure Pipelines, etc. — swap the commands, keep the habits.

---

## Git & commits

- **Conventional Commits**, single line, signed off.
  - Format: `type(scope): description`
  - Common types: `feat`, `fix`, `ci`, `docs`, `chore`, `refactor`, `test`, `perf`, `build`
  - Example: `fix(auth): handle expired refresh tokens on retry`
  - Always `git commit -s -m "…"` with one `-m` — no body, no bullets. Context lives in the PR, not the commit.
  - **No AI co-author trailers.** Commits are attributed to the human committer only — tool assistance is a workflow detail, not an authorship claim. Don't append `Co-Authored-By: Claude …` (or any agent attribution) via a HEREDOC body. The single-line `-m` rule above makes this a non-issue if you stick to it.
  - **Commit types drive releases.** `feat` → minor bump, `fix` → patch bump, `feat!:` or `BREAKING CHANGE:` → major bump. Other types (`docs`, `chore`, `test`, etc.) don't trigger a release unless paired with a `feat`/`fix`. See `release-please-config.json` for the full type → section mapping.
- **Branches + PRs only** — no direct pushes to `main` / default branch. Enforce with branch protection when possible.
- **Branch name first, then code.** Before writing code, propose the branch name (`feat/…`, `fix/…`, `ci/…`) and get a nod. Prevents "wait, this should have been two PRs" regret mid-session.
- **Merge commit strategy** for PRs. Preserves the granular Conventional Commits that changelog tooling (git-cliff, release-please, etc.) consumes. Never squash or rebase-merge unless the project explicitly prefers one — decide once per repo.
- **Push branches to origin by default** after committing (`git push -u origin <branch>`). Still confirm before force-push or push-to-main.
- **Git from the Claude sandbox is fine** for read-only ops (`git status`, `git log`, `git diff`, `gh`). Confirm before destructive ops: `push --force`, `reset --hard`, `branch -D`, `clean -f`.

## PRs

- **Provide PR title + body proactively** when a branch is ready — don't wait to be asked.
- **Keep titles under 70 chars.** Detail lives in the body.
- **Include a detailed manual test plan** for any PR that touches runtime behavior. Not "CI passes" — actual numbered steps with:
  - Setup commands
  - Steps (copy-pasteable)
  - Expected outcomes (log lines to grep for, timing thresholds, state transitions)
  - Pass / fail criteria (concrete)
- **Check off the test plan after passing.** `gh pr edit` the body to tick checkboxes, paste measured evidence inline, mark ✅ PASS sections. This is the single best defense against "I thought we tested that."
- **Pure-CI / docs PRs:** short plan is fine, but still explicit — "no runtime change; verification is CI alone."

## CI

**Principle:** after a push on an iterating PR, fire off an async watcher so CI completion pings you — don't poll.

**GitHub Actions + `gh` CLI:**
```bash
RUN_ID=$(gh run list --branch <branch> --workflow "<name>" --limit 1 --json databaseId --jq '.[0].databaseId')
gh run watch "$RUN_ID" --exit-status
```
Run with `run_in_background: true` on the Bash tool. Sleep 3–5 s before grabbing the run ID so the new push has time to register. One watcher per push (pick the workflow you're iterating on, don't spam).

**Other platforms:**
- **GitLab CI:** `glab ci watch` on the pipeline for the latest commit
- **Jenkins:** poll the job's `/wfapi/runs/<N>/describe` endpoint, or use the Jenkins CLI if configured
- **Azure Pipelines:** `az pipelines runs show --id <N> --open` or poll the REST API
- **Any platform:** if the CLI doesn't expose a blocking "wait for completion" command, a small shell loop polling the run's status endpoint every 15–30 s works and still feeds Claude's notification system when the script exits

## Documentation (in the working folder)

- **Keep planning docs in sync as work lands** — not only at phase boundaries.
  - `phase-N-checklist.md` gets branch + PR number as soon as a PR merges.
  - `implementation.md` gets amended when a task's approach materially changes mid-flight.
  - `plan.md` status line bumps when a phase transitions.
- **End every session with a `SESSION-LOG.md` entry.** Append-only. Date, focus, branches/PRs, decisions, anything non-obvious for future-you.
- **`CONTEXT.md` is the "read first" doc.** Keep it ≤300 lines. If it grows beyond that, the content belongs in one of the other docs and `CONTEXT.md` should link to it.

## Auto-memory

- **Save feedback from both corrections and confirmations.** Corrections are easy to notice; quiet "yes exactly, keep doing that" moments are what keep you from drifting away from validated approaches.
- **Structure feedback/project memories as:** the rule, then **Why:** (reason), then **How to apply:** (when/where). The `why` lets future-you judge edge cases instead of blindly following.
- **Don't memorize what the code already tells you.** File paths, architecture, function signatures belong in the code, not in memory. Memory is for rules, preferences, external references, and project context that isn't derivable from the repo.
- **Convert relative dates to absolute** when saving. "Thursday" becomes "2026-03-05" — memories outlive their natural time reference.

## Shell / environment

- **Call out the shell.** If you use Homebrew bash instead of zsh (macOS), or fish, or PowerShell, say so in `CONTEXT.md`. Terminal instructions that assume the wrong shell are a papercut that compounds.
- **Avoid `sudo` in Claude-run commands** unless you've explicitly opted into it for a specific project. Sandbox commands can't prompt interactively.

## File editing

- **When the repo is in the working directory, Claude reads + edits directly.** Don't copy-paste code through chat — it loses fidelity and wastes cycles.
- **When the repo is NOT selected, flag it immediately** before doing any file work.

## What *not* to adopt blindly

These are worth thinking about per-project, not defaulted:

- **Worktree vs. working-in-place.** Worktrees isolate changes cleanly, but they can block a manual build/test loop that expects the main checkout. Decide based on how you test.
- **DCO sign-off (`-s`) on commits.** Some projects require it (Linux kernel, OBS, many OSS), some don't, some forbid it on internal work. Match the project.
- **Squash vs. merge vs. rebase PRs.** Depends on what downstream tooling consumes commits. Pick once per repo and stick to it.
