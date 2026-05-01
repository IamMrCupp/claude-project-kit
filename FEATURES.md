# Features

A feature-by-feature reference. For setup steps, see [SETUP.md](SETUP.md). For the high-level pitch, see [README.md](README.md).

## Contents

- [Bootstrap](#bootstrap)
- [Workspace mode (multi-repo)](#workspace-mode-multi-repo)
- [Issue tracker awareness](#issue-tracker-awareness)
- [Per-ticket scratchpads](#per-ticket-scratchpads)
- [CI awareness](#ci-awareness)
- [Auto-memory seeding](#auto-memory-seeding)
- [Phase-based planning docs](#phase-based-planning-docs)
- [SEED-PROMPT auto-fill](#seed-prompt-auto-fill)
- [Starter agents](#starter-agents)
- [Starter slash commands](#starter-slash-commands)
- [Worked example](#worked-example)
- [Conventions baseline](#conventions-baseline)
- [Manual mode](#manual-mode)
- [What the kit does NOT do](#what-the-kit-does-not-do)

---

## Bootstrap

### Idempotent, write-once

`bootstrap.sh` is conservative on purpose — it refuses to clobber a populated working folder or auto-memory directory. Re-running on the same target prints what's already there and exits clean.

- `--dry-run` — preview every path that would be created, every placeholder substitution, the tracker memory file, and the `MEMORY.md` index line. Writes nothing. Safe to run repeatedly.
- `--force` — override the working-folder check (auto-memory is **still** protected; existing memory files are never overwritten).
- `--skip-memory` — seed the working folder only, leave `~/.claude/projects/<sanitized-path>/memory/` alone.

### Initial SESSION-LOG entry

Every successful run appends a factual "Bootstrap" entry to `<working-folder>/SESSION-LOG.md` capturing the date, mode (single-repo / workspace), working folder, repo path, tracker, CI, auto-memory location, kit version, and next-step pointers. Deterministic write — no LLM in the loop, no confirmation gate. The bootstrap-time state stays durable even if the user hands off before running `/session-end`. Pairs with `/session-handoff` to make the entire bootstrap-and-seed-prompt session resilient to interrupts.

```bash
bootstrap.sh ~/Documents/Claude/Projects/foo --dry-run
```

### Interactive vs. scripted modes

Run with no path argument and a TTY → **interactive**. Bootstrap prompts for working folder, project name, memory seeding, tracker, and CI, then shows a summary and asks to confirm before any file writes.

Run with a path argument → **non-interactive**. Flags drive everything; bootstrap errors fast on bad input rather than hanging. Piped or redirected stdin without a path argument also errors (no silent hang).

```bash
# Interactive
bootstrap.sh

# Scripted
bootstrap.sh ~/Documents/Claude/Projects/foo \
  --tracker jira --jira-project INFRA \
  --ci github-actions
```

### `--project-name`

Override the auto-derived project name used to fill `{{PROJECT_NAME}}` in seeded memory files. By default bootstrap uses the basename of `<working-folder>`; pass this when the basename doesn't match the human-friendly name you want.

```bash
bootstrap.sh ~/Documents/Claude/Projects/foo --project-name "Foo Service"
```

### Terraform sibling-repo detection

Bootstrap detects Terraform-shaped repos (signals: `*.tf`, `*.tfvars`, `.terraform.lock.hcl`, `terragrunt.hcl`, or `terraform/` / `modules/` subdirs containing `.tf` files) and prompts about a possible sibling envs/modules repo. In interactive mode it asks "Sibling envs/modules repo for this initiative?" and recommends `--workspace` if yes. In non-interactive mode it emits a one-line stderr hint. Suppressed under `--workspace`.

The signal list comes from [ADR-0001 §A.6](docs/adr/0001-multi-repo-folder-model.md). Pulumi (`Pulumi.yaml`) and CDK (`cdk.json`) are deferred — promote in a follow-up if the demand surfaces.

---

## Workspace mode (multi-repo)

`--workspace <path>` flips bootstrap into multi-repo mode for initiatives that span repos (the canonical case: Terraform environment definitions in one repo + Terraform modules in another). Bootstrap creates a workspace folder above per-repo subfolders:

```
~/Documents/Claude/Projects/<initiative>/
├── workspace-CONTEXT.md      ← cross-repo overview, shared tracker config
├── tickets/                  ← per-ticket scratchpads
│   └── archive/              ← closed tickets
├── <repo-a>/                 ← per-repo working folder (CONTEXT.md, SESSION-LOG.md, …)
└── <repo-b>/                 ← second repo joins via re-running bootstrap
```

```bash
# First repo in a new workspace
cd ~/Code/my-terraform-modules
~/Code/claude-project-kit/bootstrap.sh --workspace \
  ~/Documents/Claude/Projects/lx-platform/ \
  --tracker jira --jira-project LX --ci atlantis

# Second repo joins the same workspace
cd ~/Code/my-terraform-envs
~/Code/claude-project-kit/bootstrap.sh --workspace \
  ~/Documents/Claude/Projects/lx-platform/ \
  --tracker jira --jira-project LX --ci atlantis
```

Re-running against an existing workspace (detected via `workspace-CONTEXT.md` presence) is idempotent: per-repo subfolders get added without recreating workspace files. User edits to `workspace-CONTEXT.md` survive.

Tracker config flags (`--tracker jira --jira-project LX`) substitute into `workspace-CONTEXT.md`'s Tracker Configuration section AND into each per-repo `CONTEXT.md`. MCP availability and tracker link stay as prose hints for SEED-PROMPT or human fill.

Auto-memory keys to the repo (`~/.claude/projects/<sanitized-repo-path>/memory/`), not the workspace path. Workspace is a working-folder layout choice; memory stays per-repo.

For converting an existing single-repo working folder into a workspace by hand, see [SETUP.md §Upgrading a single-repo working folder to a workspace](SETUP.md#upgrading-a-single-repo-working-folder-to-a-workspace). The kit doesn't ship an automated migration helper — the manual flow is a handful of `mv` commands.

---

## Issue tracker awareness

`--tracker {github,jira,linear,gitlab,shortcut,other,none}` seeds a tracker-specific `reference_issue_tracker.md` into auto-memory. Each variant ships the conventions Claude needs to reference tickets correctly: URL pattern, ticket-reference format in commits / PRs, branch-naming convention, and the CLI tool of choice (`gh`, `jira`, `linear`, `glab`, etc.).

| Tracker | Key flag | Notes |
|---|---|---|
| `github` | — | Default. Issues live on the same repo. |
| `jira` | `--jira-project KEY` | Implies `--tracker jira`. JIRA MCP integration assumed if available. |
| `linear` | `--linear-team KEY` | Implies `--tracker linear`. |
| `gitlab` | — | Issues on the same project. |
| `shortcut` | — | Story IDs in commits / PRs. |
| `other` | — | Escape hatch — seeds a placeholder-rich file you fill in by hand. |
| `none` | — | Skips tracker memory entirely. |

In non-interactive mode, omitting `--tracker` is the same as `--tracker none` — bootstrap won't guess.

`--tracker` and `--jira-project` / `--linear-team` also fill `{{TRACKER_TYPE}}` and `{{TRACKER_KEY}}` in `CONTEXT.md` (and `workspace-CONTEXT.md` in workspace mode), so the working folder's Tracker Configuration section is pre-populated alongside the auto-memory file. MCP availability + tracker link stay as prose hints for SEED-PROMPT or human fill.

**Read-only constraint:** the kit never creates, edits, transitions, or comments on tracker resources. It captures references to existing trackers only — JIRA / Linear / GitHub Issues projects must exist before bootstrap. See [ADR-0001 §D3](docs/adr/0001-multi-repo-folder-model.md) and `CONVENTIONS.md` "Ticket-driven workflows → What the kit does NOT do with trackers".

---

## Per-ticket scratchpads

For ticket-driven work (JIRA, GitHub Issues, Linear, GitLab, Shortcut), the kit ships a per-ticket scratchpad pattern: `tickets/<KEY>-<slug>.md` accumulates working notes, branches, and PRs as the ticket progresses; the upstream tracker stays the source of truth.

Two entry points fetch tracker data and seed the scratchpad — both **read-only** against the tracker:

- **`/pull-ticket <KEY>` slash command** — reads tracker config from `CONTEXT.md` (or `../workspace-CONTEXT.md` in workspace mode), fetches via the relevant tracker MCP, fills `templates/workspace/ticket.md`, updates the workspace-CONTEXT "Active tickets" list, and stages a `SESSION-LOG.md` entry. Use from inside Claude.

- **`pull-ticket.sh <KEY>` helper script** — terminal-driven equivalent. Uses `gh issue view` for GitHub Issues, `jira` (jira-cli) for JIRA, `glab issue view` for GitLab; falls back to a placeholder stub for Linear / Shortcut / `other` (or if no CLI is available). Writes the scratchpad; doesn't update workspace-CONTEXT or SESSION-LOG.

Both refuse to overwrite an existing scratchpad with the same `<KEY>-` prefix (active or archived) — your working notes survive a re-pull.

```bash
# In Claude:  /pull-ticket LX-1234

# In a terminal:
cd ~/Code/my-terraform-modules
~/Code/claude-project-kit/pull-ticket.sh LX-1234
# → writes <workspace>/tickets/LX-1234-fix-lb-routing.md (or stub if no CLI)
```

`templates/workspace/ticket.md` defines the file shape: tracker link, status, summary, AC, working notes, branches/PRs across repos (for multi-repo tickets), decisions, cross-references. When the upstream ticket closes, move the file to `tickets/archive/` with a 1-2 sentence "what shipped" note — the archive becomes a grep-able record of what the team delivered for each ticket.

The branch / PR / commit conventions for ticket-driven work (JIRA-style key in the branch slug, PR title, and commit subject) are in `CONVENTIONS.md` "Ticket-driven workflows".

---

## CI awareness

`--ci {github-actions,gitlab-ci,jenkins,circleci,atlantis,ansible-cli,other,none}` seeds a CI-specific `reference_ci.md` into auto-memory: where the pipeline config lives, how to query status from CLI, what a passing build looks like, and the kit's "CI in the background" convention.

`atlantis` and `ansible-cli` cover the Terraform / infra-automation cases that don't fit a standard CI shape. `other` and `none` work the same as for trackers.

```bash
bootstrap.sh ~/Documents/Claude/Projects/foo --ci atlantis
```

---

## Auto-memory seeding

Bootstrap copies `memory-templates/` into the harness-expected path (`~/.claude/projects/<sanitized-path>/memory/`) and substitutes placeholders from the current repo:

- `{{PROJECT_NAME}}` — derived or `--project-name`
- `{{WORKING_FOLDER}}` — the path you provided
- `{{REPO_PATH}}` — absolute path to the target repo
- `{{REPO_SLUG}}` — derived from `git remote get-url origin` if available

Anything that can't be derived stays as `{{PLACEHOLDER}}` so it's grep-able. The end-of-run output flags any unsubstituted placeholders so you know what to fill in.

The memory files are **starters**, not commandments. Prune what doesn't apply, add your own, keep `MEMORY.md` (the index) in sync. The harness loads `MEMORY.md` into context every session, so it stays small (under ~150 lines is a reasonable target).

When the kit ships new starter rules, `scripts/sync-memory.sh <memory-dir>` copies any missing templates into an existing auto-memory dir without overwriting customized files. Skips `MEMORY.md`, `project_current.md`, and `user_role.md` (user-curated). See [SETUP.md §Upgrading an existing project](SETUP.md#upgrading-an-existing-project).

---

## Phase-based planning docs

The working-folder template includes a planning structure that scales from weekend project to multi-quarter work:

- **`plan.md`** — phases at a high level. One section per phase, with goals and exit criteria.
- **`phase-N-checklist.md`** — current phase's task list. Tick boxes, branch + PR per item.
- **`implementation.md`** — running design / decision log for the active phase.
- **`acceptance-test-results.md`** — end-of-phase verification record.
- **`research.md`** — exploratory notes, references, dead ends.

Bootstrap renames the phase-N template to `phase-0-checklist.md` so you can start filling it immediately. Subsequent phases follow the `phase-1-checklist.md`, `phase-2-checklist.md` pattern — the `/close-phase` slash command handles the writeback when one wraps.

You don't have to use all of these. Bare minimum for a small project: `CONTEXT.md` + `SESSION-LOG.md`. Add the rest when scope warrants.

---

## SEED-PROMPT auto-fill

Bootstrap drops `SEED-PROMPT.md` into the working folder. After bootstrap, open Claude Code in the target repo and say:

> Follow the instructions in `<working-folder>/SEED-PROMPT.md`.

Claude reads your README, package manifests, CI config, source layout, and recent git activity, then fills `CONTEXT.md` for you. Inferred fields are tagged `[CLAUDE-INFERRED: reasoning]`; fields it can't derive are tagged `[HUMAN-CONFIRM: question]`. It drafts an initial `research.md`, then **stops**, summarizes, and asks ≤5 targeted questions before going further.

Saves ~30 minutes of manual fill-in on a real project, and the inference markers make the human review pass fast (grep, confirm, move on).

---

## Starter agents

Two agents stage in `<working-folder>/.claude/agents/`. The kit doesn't modify your target repo — to activate, copy the directory in:

```bash
cp -r <working-folder>/.claude/ <your-repo>/.claude/
```

- **`code-reviewer`** — reviews diffs, branches, or files for security / correctness / performance / style. Project-agnostic; works anywhere.
- **`session-summarizer`** — drafts SESSION-LOG entries, CONTEXT.md status bumps, checklist scans, and memory candidates from the current session's activity. Specific to projects using the kit's working-folder pattern.

These are **starters**. Edit the frontmatter (model, tool allowlist), customize the prompts, write your own. The kit seeds the pattern, not the content. See [`templates/.claude/README.md`](templates/.claude/README.md) for the activation flow and how to add new ones.

---

## Starter slash commands

Six slash commands stage in `<working-folder>/.claude/commands/`. Same activation pattern — copy `.claude/` into your target repo.

- **`/session-start`** — packages Prompt 1 from `PROMPTS.md`. Loads `CONTEXT.md`, `SESSION-LOG.md`, and the current phase checklist; hands back a 3–5 bullet grounding summary. Use at the start of a fresh session.
- **`/refresh-context`** — re-reads the working folder mid-session, after a `/close-phase` or `/session-end` writeback or when a long session has drifted. Hands back a delta read against the latest state.
- **`/close-phase`** — runs the phase-close writeback (checklist tick, `plan.md` status bump, `CONTEXT.md` update, optional acceptance-results archive). Takes a phase number or infers from `CONTEXT.md`.
- **`/session-end`** — packages Prompt 3 from `PROMPTS.md`. Drafts the four end-of-session updates (SESSION-LOG entry, CONTEXT bump, checklist scan, memory candidates) and waits for confirmation before writing.
- **`/session-handoff`** — same drafting work as `/session-end`, but **writes immediately** without a confirmation gate. Use when waiting risks losing work: switching to Claude desktop, context-window pressure, abrupt pause. Persistence > polish; review on the next `/session-start`. Pairs with `bootstrap.sh`'s automatic Bootstrap entry — between the two, the bootstrap-and-seed-prompt session is durable end-to-end even if the user pauses without a clean wrap-up.
- **`/pull-ticket <KEY>`** — packages Prompt 6 from `PROMPTS.md`. Fetches a tracker ticket (JIRA / GitHub Issues / Linear / GitLab / Shortcut) via the relevant MCP, creates `tickets/<KEY>-<slug>.md` from the kit's ticket template, updates `workspace-CONTEXT.md` "Active tickets" list, stages a `SESSION-LOG.md` line. Read-only against the tracker. See [Per-ticket scratchpads](#per-ticket-scratchpads) for the full flow.

---

## Worked example

Two filled-in reference examples in `examples/`:

- **`widget-tracker/`** — a fictional Go CLI mid-Phase 1 (single-repo working folder). `CONTEXT.md`, `plan.md`, `phase-0-checklist.md`, `phase-1-checklist.md`, `SESSION-LOG.md`, `implementation.md`, plus a `memory-example/` snapshot. Best reference for phase-driven solo work.
- **`lx-platform/`** — a fictional AWS Terraform multi-repo workspace driven by JIRA tickets. `workspace-CONTEXT.md` + per-repo subfolders (`terraform-modules/`, `terraform-envs/`) with their own `CONTEXT.md` / `SESSION-LOG.md`, an active ticket scratchpad ([LX-1234](examples/lx-platform/tickets/LX-1234-fix-lb-routing.md)) showing branches/PRs across both repos, and an archived ticket ([LX-1100](examples/lx-platform/tickets/archive/LX-1100-add-vpc-module.md)). Best reference for ticket-driven multi-repo work.

Read, don't copy.

---

## Conventions baseline

`CONVENTIONS.md` captures defaults that have held up across projects: Conventional Commits, single-line commit messages, merge-commit PR strategy, detailed PR test plans, CI-in-background. Read once, keep what fits, drop what doesn't. For work projects, vet against employer policy first.

The kit's own development follows these conventions, so the repo is a worked example of the conventions in action.

---

## Manual mode

Every step has a manual alternative — see [SETUP.md §Manual alternative](SETUP.md#manual-alternative). Useful when Bash isn't available, you're in a restricted environment, or you just want to see what bootstrap would do without running it.

---

## What the kit does NOT do

- **Doesn't modify your target repo.** Templates land in the working folder; memory lands in the harness path. Your repo stays clean.
- **Doesn't write to `~/.claude/settings.json`.** That file is global, cross-project, and per-user-per-machine; the kit shouldn't silently mutate it, and it's not synced from the kit repo. To stop the per-read permission prompts on the working folder, add its parent directory to `permissions.additionalDirectories` once by hand on each machine you work from — see [SETUP.md §1](SETUP.md#1-pick-a-working-folder-location) for the exact JSON.
- **Doesn't create or manage `<repo>/.claude/settings.local.json`.** That file is written by Claude Code itself when you grant Bash / MCP / read-path permissions interactively; it is per-project and machine-specific. The kit doesn't create it, edit it, or have an opinion on its contents. **Recommend gitignoring it** — see [SETUP.md §1](SETUP.md#1-pick-a-working-folder-location) for the exact pattern. To graduate a frequently-used permission so it applies across every project, hand-edit `~/.claude/settings.json` (the global counterpart).
- **Doesn't make network calls.** No telemetry, no auto-update check, no remote dependencies at runtime.
- **Doesn't manage your tracker / CI.** It seeds memory so Claude knows the conventions; it doesn't create JIRA projects, push GitHub Actions workflows, or open issues for you. Tracker integration (`/pull-ticket`, `pull-ticket.sh`) is **one-way read** — fetches summary / AC / status, never creates / edits / transitions / comments. See [ADR-0001 §D3](docs/adr/0001-multi-repo-folder-model.md).
- **Doesn't replace `CLAUDE.md`.** They're complementary — the kit handles cross-session state and preferences; `CLAUDE.md` handles in-repo guidance Claude reads automatically.
- **Doesn't auto-upgrade installed projects.** When the kit ships new templates, existing adopters apply changes manually with the diff in [CHANGELOG.md](CHANGELOG.md). Bootstrap is write-once by design.
