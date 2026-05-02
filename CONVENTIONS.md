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
- **Run the automatable test-plan items + post results back, by default.** When the user asks you to run the test plan (or "verify this PR", "kick off the tests", "check the ATs"), the default workflow is:
  1. Attempt the automatable items yourself (see *Automating acceptance tests where it makes sense* below for the heuristic).
  2. Tick the matching checkboxes in the PR body via `gh pr edit <PR> --body-file <path>` and paste measured evidence inline (log line, timing, run ID, diff snippet — whatever proves the check passed).
  3. If the test corresponds to an item in `acceptance-test-results.md`, update the Actual / Result fields there too.

  Posting back is the **default** when the user invokes a run — not an opt-in, not a "ask if you want me to update the PR" follow-up. The single best defense against "I thought we tested that" is making the evidence durable on the PR itself.
- **Pure-CI / docs PRs:** short plan is fine, but still explicit — "no runtime change; verification is CI alone."

### Automating acceptance tests where it makes sense

When running an AT plan, classify each item before reaching for the human:

- **Run automatically.** Anything scriptable: bats / pytest / jest / shell commands; link-check or lint runs; CLI invocations whose expected output is grep-able; template renders that can be diffed against a fixture.
- **Run with confirmation.** Anything that mutates external state: `gh pr edit`, `git push`, `gh release create`, hitting a real tracker, publishing to a registry. Propose the exact command, wait for the nod, then run.
- **Defer to human.** Visual rendering on GitHub.com, behavior in a UI, anything requiring human judgment ("does this prose feel right?"). Surface explicitly with rationale — don't silently skip.

When something fails, report the exact command, the exact output, and a candidate fix — not "❌ FAIL" alone. The user shouldn't have to re-run the failing command to see what broke.

### How to post test results back to the PR

The mechanics:

1. Edit the PR body via `gh pr edit <PR> --body-file <path-to-updated-body>` (writing the full body once is more reliable than patching individual lines).
2. Tick the corresponding checkboxes (`- [ ]` → `- [x]`) and paste evidence inline. Good evidence shapes:
   - Log line that proves a behavior fired (e.g. `grep -c "^ok" output → 218`)
   - Run ID + link for CI workflows (e.g. `[Run 25246443649](...) — passed`)
   - Diff or `wc -l` output for content checks
   - Screenshot link for UI verifications
3. If an item failed, mark `❌ FAIL` and paste the exact failure output + your hypothesis. A failed-but-documented item is better than silence.
4. Items the human still owns (e.g. visual GH render checks) stay unticked, with an explicit "Aaron to verify" or similar tag.

Goal: any reviewer reading the PR body should be able to tell "what was tested, how, and what the result was" without rerunning anything.

## CI

**Principle:** after a push on an iterating PR, fire off an async watcher so CI completion pings you — don't poll, and don't move on until you've seen the result.

**Hard rule:** a PR isn't ready, complete, or "open for review" until checks pass. If you push and report the PR back without first watching CI, you'll either claim success on a red check or force the reviewer to spot the failure for you. Both cost trust. The watcher is how you avoid this — spawn it the same turn as the push, surface failures the moment the watcher reports them, and re-watch after every fix push.

**GitHub Actions + `gh` CLI:**
```bash
RUN_ID=$(gh run list --branch <branch> --workflow "<name>" --limit 1 --json databaseId --jq '.[0].databaseId')
gh run watch "$RUN_ID" --exit-status
```
Run with `run_in_background: true` on the Bash tool. Sleep 3–5 s before grabbing the run ID so the new push has time to register. One watcher per push (pick the workflow you're iterating on, don't spam) — or one per workflow if multiple are likely to fail independently (e.g. lint + test).

**Other platforms:**
- **GitLab CI:** `glab ci watch` on the pipeline for the latest commit
- **Jenkins:** poll the job's `/wfapi/runs/<N>/describe` endpoint, or use the Jenkins CLI if configured
- **Azure Pipelines:** `az pipelines runs show --id <N> --open` or poll the REST API
- **Any platform:** if the CLI doesn't expose a blocking "wait for completion" command, a small shell loop polling the run's status endpoint every 15–30 s works and still feeds Claude's notification system when the script exits

## Ticket-driven workflows

When working against an external tracker (JIRA, GitHub Issues, Linear, etc.), the conventions above extend with a ticket key woven through branches, PR titles, commits, and PR bodies. Examples below use a JIRA-style key (`ACME-1234`); substitute your tracker's format.

### Branch / PR / commit conventions

- **Branch:** `<type>/<KEY>-<short-slug>` — e.g. `feat/ACME-1234-fix-lb-path-routing`. The same ticket key is reused across multiple repos when a single ticket drives work in both (e.g. a Terraform envs change + a modules change both against `ACME-1234`). Multi-repo initiatives keep one key, not one per repo.
- **PR title:** Conventional Commits with the key in parens — e.g. `feat(modules): add VPC module (ACME-1234)`. **No `Closes` / `Fixes` keyword** unless your tracker has auto-transitions configured AND you want them; many orgs (including JIRA without explicit setup) don't, and the keyword does nothing useful in that case.
- **PR body:** dedicated `## JIRA` (or `## Linear`, `## Issue`, etc.) section linking the ticket plus the usual Summary / Test plan sections. No transition magic — humans transition the ticket.
- **Commits:** Conventional Commits with the key in the subject — e.g. `feat(modules): add VPC module — ACME-1234`. The single-line `-m` rule from `## Git & commits` still applies; the key goes in the subject, not a body.
- **Smart Commits** (`#time`, `#comment`, `#transition` for trackers that support them) — **opt-in per project**, not part of the default convention. If your team uses them, document the local conventions in `CONTEXT.md` so contributors don't accidentally trigger transitions.

### What the kit does NOT do with trackers

- **Never creates tracker projects, labels, workflows, or sprint scaffolding** on your behalf. JIRA projects, GitHub Project boards, Linear teams, etc. are owned by PMs and the business — bootstrap captures *references* to projects that already exist (project key, MCP availability, link), never creates them.
- **Creating individual issues/tickets inside an existing project** is only on the table when you explicitly ask for it. The kit's own GitHub repo is the exception (a personal project), not the rule.

## Documentation (in the working folder)

- **Keep planning docs in sync as work lands** — not only at phase boundaries.
  - `phase-N-checklist.md` gets branch + PR number as soon as a PR merges.
  - `implementation.md` gets amended when a task's approach materially changes mid-flight.
  - `plan.md` status line bumps when a phase transitions.
- **End every session with a `SESSION-LOG.md` entry.** Append-only. Date, focus, branches/PRs, decisions, anything non-obvious for future-you.
- **`CONTEXT.md` is the "read first" doc.** Keep it ≤300 lines. If it grows beyond that, the content belongs in one of the other docs and `CONTEXT.md` should link to it.

## Acceptance tests at phase boundaries

Acceptance tests verify *user-visible behavior* of a phase's slice. Green CI alone only proves code correctness, not feature correctness — the two diverge often enough that the kit treats acceptance tests as load-bearing, not aspirational.

- **Every phase MUST have a non-empty `acceptance-test-results.md`** (or archived `acceptance-test-results-phase-N.md`) before the phase can close. The phase checklist's `## Acceptance testing` section lists the tests; the results file records Goal / Setup / Steps / Expected / Actual / Result for each.
- **One escape hatch — explicit, documented, never silent.** If a phase legitimately has nothing to acceptance-test (e.g. pure-CI work, internal refactor with zero user-visible change), record the rationale on a single line in the phase checklist's `## Phase exit` block:

  > `Acceptance tests intentionally skipped — rationale: {{one sentence}}`

  The rationale gets surfaced in the SESSION-LOG entry that closes the phase. Skipping without a rationale is a convention violation, not a customization.
- **The `/close-phase` slash command enforces both rules.** It refuses to close when neither condition is met (no non-empty results file AND no skip-rationale line), and refuses if the checklist's `## Acceptance testing` section was deleted. The convention is the source of truth; the slash command makes it operationally hard to skip silently.

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
