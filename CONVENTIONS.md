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

**Hook-side enforcement (recommended).** Memory and prose are guidance — Claude *usually* honors the rules above, but the kit ships an optional `PreToolUse` Bash hook (`scripts/block-forbidden-commit-patterns.sh`) that **blocks** commands carrying forbidden commit-format patterns at the harness level (Co-Authored-By trailers, "Generated with Claude Code" / 🤖 markers, `--no-verify` / `--no-gpg-sign` / `commit.gpgsign=false` bypasses). Memory is a suggestion; the hook is the structural guarantee. Wire it once per machine — see [SETUP.md → Optional: commit-format enforcement hook](SETUP.md#optional-commit-format-enforcement-hook).

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
- **A merged PR is the trigger to write the SESSION-LOG entry** — not "the session is ending." Run `/session-end` (or `/session-handoff` if you're carrying on) as part of merging, while the branch name, PR number, commit list, and the reasoning are all still in front of you. Waiting for the session to end loses entries: a long-running session has no moment that feels like the end, so the trigger never fires, and everything that only lived in the conversation is gone. Code-recoverable state survives that; decisions don't.

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

### Issue-first when you own the tracker

**Bright line: tracker authority decides the default.**

- **You own the tracker** (your personal GitHub repo's Issues, your own Linear team, etc.) → **issue-first by default**. Trackable work gets an issue *before* you start. The local `phase-N-checklist.md` is the working view; the tracker is the public/durable view. Both should agree.
- **Someone else owns the tracker** (work JIRA, upstream OSS) → read-only. See *What the kit does NOT do with trackers* below — the rule is unchanged for externally-owned trackers.

When in doubt about who owns it, ask. Default to assuming externally-owned.

#### Mechanics — when you own the tracker

- **Granularity:** one issue ≈ one phase-checklist item. Phase-level umbrella issues are optional — only worth creating when the phase has 5+ items or spans multiple repos.
- **Cross-linking:**
  - Phase checklist items record `Issue:` + `Branch:` + `PR:` so all three views point at each other.
  - PR body includes `Closes #N` (or your tracker's auto-close keyword) so merge auto-closes the issue.
  - Commits may reference the issue (`feat(svg): regenerate from brand.toml (#12)`) but it isn't required — the PR body carries the link.
- **Working-folder-only items** (local sanity checks, internal verifications with no PR) still get an issue when the tracker is yours. Title or label them so it's obvious no PR is expected; close manually after the verification lands in `SESSION-LOG.md`.
- **Confirm before bulk-create.** When carving a phase checklist into issues, propose the full list (titles + bodies + labels if any) and wait for the nod before running `gh issue create` (or equivalent). Don't auto-create silently — the user's seeing the proposed shape *before* it lands in their tracker is the load-bearing step.
- **Verify auto-close.** After a PR merges, check the linked issue actually closed. If the auto-close keyword didn't fire (wrong keyword, cross-repo edge case, branch protection quirk), close the issue manually with a one-line summary.

#### Why

- **Survives loss of the working folder.** The local checklist is durable for you; the tracker is durable for everyone — future-you, collaborators, anyone reading the repo without your private working folder.
- **Visible to the world.** A populated Issues tab signals "this project is alive and being worked on" in a way `phase-N-checklist.md` can't.
- **Native cross-linking.** GitHub / Linear / JIRA all link issues ↔ commits ↔ PRs natively in their UI. You get that integration for free once the issue exists.

### What the kit does NOT do with trackers

- **Never creates tracker projects, workflows, or sprint scaffolding** on your behalf. JIRA projects, GitHub Project boards, Linear teams, etc. are owned by PMs and the business — bootstrap captures *references* to projects that already exist (project key, MCP availability, link), never creates them.
- **Labels are the one opt-in exception, and only on a repo you own.** `bootstrap.sh --with-labels` creates a standard triage scheme (`type:*`, `priority:P0–P2`, `blocker`, `decision-needed`, `phase-0`/`phase-1`) on the current GitHub repo via `gh label create`. It is **off by default**, skips labels that already exist, no-ops cleanly without `gh` or a remote, and never touches an externally-owned tracker. Rationale: labels on your own repo are low-stakes and reversible, and the kit already ships an opinionated triage vocabulary worth seeding — but only when you ask. Everything else structural (workflows, sprint config, Project boards) stays hands-off.
- **Creating individual issues/tickets inside an existing project** depends on tracker authority — see *Issue-first when you own the tracker* above. For trackers you own, issue creation is the default (with confirmation before bulk-create). For externally-owned trackers, it's only on the table when you explicitly ask, and never structural artifacts (workflows, sprint config).

## Documentation (in the working folder)

- **Keep planning docs in sync as work lands** — not only at phase boundaries.
  - `phase-N-checklist.md` gets branch + PR number as soon as a PR merges.
  - `implementation.md` gets amended when a task's approach materially changes mid-flight.
  - `plan.md` status line bumps when a phase transitions.
- **End every session with a `SESSION-LOG.md` entry.** Append-only. Date, focus, branches/PRs, decisions, anything non-obvious for future-you.
- **`CONTEXT.md` is the "read first" doc.** Keep it ≤300 lines. If it grows beyond that, the content belongs in one of the other docs and `CONTEXT.md` should link to it. **Its "Working Rules" section points at auto-memory `feedback_*` for mutable conventions — it does not restate them** (see *Auto-memory* below for why).
- **Archive resolved ticket scratchpads.** Once a ticket's work is done, move `tickets/<KEY>-<slug>.md` into `tickets/archive/` so a long-running workspace's `tickets/` folder stays scannable. Use `/archive-ticket <KEY>` (it also notes the archival in `SESSION-LOG.md`) or the terminal helper `archive-ticket.sh <KEY>`. The move never touches the external tracker — transition the ticket there yourself.

## Acceptance tests at phase boundaries

Acceptance tests verify *user-visible behavior* of a phase's slice. Green CI alone only proves code correctness, not feature correctness — the two diverge often enough that the kit treats acceptance tests as load-bearing, not aspirational.

- **Every phase MUST have a non-empty `acceptance-test-results.md`** (or archived `acceptance-test-results-phase-N.md`) before the phase can close. The phase checklist's `## Acceptance testing` section lists the tests; the results file records Goal / Setup / Steps / Expected / Actual / Result for each.
- **One escape hatch — explicit, documented, never silent.** If a phase legitimately has nothing to acceptance-test (e.g. pure-CI work, internal refactor with zero user-visible change), record the rationale on a single line in the phase checklist's `## Phase exit` block:

  > `Acceptance tests intentionally skipped — rationale: {{one sentence}}`

  The rationale gets surfaced in the SESSION-LOG entry that closes the phase. Skipping without a rationale is a convention violation, not a customization.
- **The `/close-phase` slash command enforces both rules.** It refuses to close when neither condition is met (no non-empty results file AND no skip-rationale line), and refuses if the checklist's `## Acceptance testing` section was deleted. The convention is the source of truth; the slash command makes it operationally hard to skip silently.

## Test-first where it fits

Test-first (write the failing test *before* the implementation) is **encouraged, not enforced** — and only where the code shape rewards it.

- **Reach for it** on code with a clear input/output contract: app logic, APIs, library functions, component behavior. Writing the test first sharpens the acceptance criteria, surfaces bad interfaces early, and pairs naturally with the phase-checklist model — the failing test *is* the AC, made executable.
- **Skip it** for IaC (Terraform / Helm / Ansible), shell glue, one-shot scripts, and exploratory spikes. Forcing test-first there produces checkbox tests that don't catch real bugs; post-implementation `bats` / integration tests are the right level for that work.

This layers on top of *automated tests preferred over manual* — that rule governs *whether* tests exist; this one governs *when* they're written relative to the code, for the subset of work where it pays off.

**The loop, inside a phase:** for an app-shaped behavior change, make the first checklist item *"write a failing test for the AC"* (red), implement until it's green, then refactor with the test as a safety net. Each step is small and reviewable, and the test merges in the same PR as the behavior. Stay framework-neutral — Jest / Vitest / Pytest / Go's `testing` / etc. are the project's call, not the kit's.

## Auto-memory

- **Auto-memory `feedback_*` files are the source of truth for mutable conventions.** Commit style, branch naming, merge strategy, and PR rules live in memory and load every session via `MEMORY.md`. **Do not also restate them in `CONTEXT.md`** — `CONTEXT.md`'s "Working Rules" should *point* at the memory (`Merge strategy → feedback_merge_strategy`), never copy the rule text. Duplicated convention prose drifts: when a rule changes, one copy goes stale, and a stale `CONTEXT.md` line can silently override the live memory an agent already loaded ([#258](https://github.com/IamMrCupp/claude-project-kit/issues/258) — a stale "squash" line in CONTEXT overrode a correct "merge commit" memory and a prod PR got squash-merged against the rule). Project-specific rules with *no* memory file are the one exception — those live in CONTEXT.md's *Project-specific* block.
- **When a rule flips, flip the frontmatter `description:` with the body.** A memory whose headline says "merge commit" but whose `description:` still says "squash" is internally contradictory and the `description:` is what gets scanned for relevance — half-finished edits are how a correct memory still steers wrong. Edit both, or neither.
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

## Subagent fan-out (parallel delegation)

Claude Code can spawn multiple subagents in parallel. Fan-out — firing several at once on **independent** pieces of a task — is powerful but expensive, so reach for it deliberately.

- **Worth it when** the pieces are genuinely independent and each is non-trivial: researching three options at once, drafting tests while another agent drafts docs, reviewing several unrelated files in parallel. The kit ships a `research-question` starter agent tuned for exactly this — fire a few, each on one question, then merge the briefs.
- **Not worth it when** there are sequential dependencies (B needs A's output), or the tasks are small enough that coordination + merge cost exceeds the time saved. One capable agent beats five that each do a sliver and hand you five drafts to reconcile.
- **Brief for mergeable output.** Each subagent starts cold — give it a self-contained prompt, an explicit return format, and hard scope boundaries, so the briefs slot together without you re-reading sources. (See the `research-question` agent's "Hand back" shape for the pattern.)
- **Mind the cost.** Fan-out burns tokens fast and produces *drafts that need human merging*, not finished work. The win is wall-clock time on independent research / drafting — it doesn't remove the synthesis, which is still yours.

See [`examples/fan-out-walkthrough.md`](examples/fan-out-walkthrough.md) for an end-to-end research-phase example.

## What *not* to adopt blindly

These are worth thinking about per-project, not defaulted:

- **Worktree vs. working-in-place.** Worktrees isolate changes cleanly, but they can block a manual build/test loop that expects the main checkout. Decide based on how you test.
- **DCO sign-off (`-s`) on commits.** Some projects require it (Linux kernel, OBS, many OSS), some don't, some forbid it on internal work. Match the project.
- **Squash vs. merge vs. rebase PRs.** Depends on what downstream tooling consumes commits. Pick once per repo and stick to it.
