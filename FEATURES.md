# Features

A feature-by-feature reference. For setup steps, see [SETUP.md](SETUP.md). For the high-level pitch, see [README.md](README.md).

## Contents

- [Bootstrap](#bootstrap)
- [Issue tracker awareness](#issue-tracker-awareness)
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

Two slash commands stage in `<working-folder>/.claude/commands/`. Same activation pattern — copy `.claude/` into your target repo.

- **`/close-phase`** — runs the phase-close writeback (checklist tick, `plan.md` status bump, `CONTEXT.md` update, optional acceptance-results archive). Takes a phase number or infers from `CONTEXT.md`.
- **`/session-end`** — packages Prompt 3 from `PROMPTS.md` as a slash command. Drafts the four end-of-session updates (SESSION-LOG entry, CONTEXT bump, checklist scan, memory candidates) and waits for confirmation before writing.

---

## Worked example

`examples/widget-tracker/` is a fictional Go CLI mid-Phase-1, with `CONTEXT.md`, `plan.md`, `phase-0-checklist.md`, `phase-1-checklist.md`, `SESSION-LOG.md`, and `implementation.md` filled in plausibly. Use it as a reference when you're not sure what a finished template should look like — read it, don't copy it.

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
- **Doesn't make network calls.** No telemetry, no auto-update check, no remote dependencies at runtime.
- **Doesn't manage your tracker / CI.** It seeds memory so Claude knows the conventions; it doesn't create JIRA projects, push GitHub Actions workflows, or open issues for you.
- **Doesn't replace `CLAUDE.md`.** They're complementary — the kit handles cross-session state and preferences; `CLAUDE.md` handles in-repo guidance Claude reads automatically.
- **Doesn't auto-upgrade installed projects.** When the kit ships new templates, existing adopters apply changes manually with the diff in [CHANGELOG.md](CHANGELOG.md). Bootstrap is write-once by design.
