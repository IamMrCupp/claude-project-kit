# Claude Project Framework

[![Release](https://img.shields.io/github/v/release/IamMrCupp/claude-project-kit?display_name=tag&sort=semver)](https://github.com/IamMrCupp/claude-project-kit/releases)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Tested on macOS / Linux](https://img.shields.io/badge/tested%20on-macOS%20%7C%20Linux-lightgrey)](#requirements)

A reusable scaffold for starting new projects with Claude. Battle-tested on real projects and generalized so it works for personal code, open-source, or work projects.

<p align="center">
  <img src="https://github.com/user-attachments/assets/48ab501b-46d8-47d6-950c-88ba6721232d" alt="bootstrap.sh interactive walkthrough — runs in ~22 seconds" width="800">
</p>

> **Heads up — Claude state for a bootstrapped project lives in three places, none of them your repo:**
>
> ```
>   ┌────────────────────┐    templates copied   ┌──────────────────────┐
>   │   Kit checkout     │ ───────────────────▶  │   Working folder     │
>   │  (this repo)       │                       │  (per-project state) │
>   │  templates/        │                       │  CONTEXT.md          │
>   │  bootstrap.sh      │                       │  SESSION-LOG.md      │
>   │  docs              │                       │  plan.md, …          │
>   └────────────────────┘                       └──────────────────────┘
>            │                                              ▲
>            │ memory seeded                                │ Claude reads
>            ▼                                              │ each session
>   ┌────────────────────────────────────────────────────────────┐
>   │                       Auto-memory                          │
>   │   ~/.claude/projects/<sanitized-path>/memory/              │
>   │   (per-project preferences, persistent across sessions)    │
>   └────────────────────────────────────────────────────────────┘
> ```
>
> The kit never modifies your repo. All three locations are private and local.

## Contents

- [Quickstart](#quickstart)
- [Features](#features)
- [What this is / isn't](#what-this-is--isnt)
- [Why this works](#why-this-works)
- [The idea, in one paragraph](#the-idea-in-one-paragraph)
- [How to use](#how-to-use-new-or-existing-project)
- [The lifecycle](#the-lifecycle)
- [What's in here](#whats-in-here)
- [Requirements](#requirements)
- [Related docs](#related-docs)
- [Support](#support)
- [License](#license)

## Quickstart

```bash
git clone https://github.com/IamMrCupp/claude-project-kit ~/Code/claude-project-kit
cd <your-repo>                                   # the project you want to bootstrap
~/Code/claude-project-kit/bootstrap.sh           # interactive — asks you everything
```

That kicks off interactive mode: it asks for the working-folder path, project name, issue tracker, and CI tool, then seeds everything in one pass. Full walkthrough in [SETUP.md](SETUP.md). Full flag list: `bootstrap.sh -h`.

## Features

- **Idempotent bootstrap** — write-once by default, with `--dry-run` (preview), `--force` (override the empty-folder check), and `--skip-memory` (working folder only).
- **Issue tracker awareness** — `--tracker {github,jira,linear,gitlab,shortcut,other,none}` seeds tracker-specific memory. JIRA and Linear take a project / team key.
- **CI awareness** — `--ci {github-actions,gitlab-ci,jenkins,circleci,atlantis,ansible-cli,other,none}` seeds CI-specific memory.
- **Auto-memory seeding** — starter memory files for role, conventions, project context, and external references, with placeholder substitution from your repo (`{{PROJECT_NAME}}`, `{{REPO_SLUG}}`, etc.).
- **Phase-based planning docs** — `plan.md` + per-phase checklist + `implementation.md` give Claude scoped, numbered tasks instead of a wall of intent.
- **SEED-PROMPT auto-fill** — point Claude at one file and it deep-reads your repo, fills `CONTEXT.md`, drafts `research.md`, flags inferences, and stops for your review.
- **Starter agents** — `code-reviewer` (universal) and `session-summarizer` (kit-aware), staged in the working folder; copy into your repo to activate.
- **Starter slash commands** — `/session-start` (load working-folder context), `/refresh-context` (re-read mid-session), `/close-phase` (phase-close writeback), and `/session-end` (end-of-session log + memory pass).
- **Worked example** — `examples/widget-tracker/` is a fictional Go CLI mid-Phase-1 with all docs filled in plausibly.
- **Conventions baseline** — Conventional Commits, merge-only PRs, test-plan format, etc. Read once, drop or keep per project.
- **No surprises** — MIT licensed, no telemetry, no network calls, kit never modifies your target repo.

See [FEATURES.md](FEATURES.md) for one-paragraph-per-feature detail with example invocations.

## What this is / isn't

- **Is:** a workflow scaffold layered on top of Claude Code — templates, memory starters, conventions, two starter agents, four starter slash commands.
- **Isn't:** a Claude Code plugin, a replacement for `CLAUDE.md`, or a project tracker. It complements all three.

## Why this works

The templates aren't the point — what they do *to* Claude is:

- **External docs survive sessions.** `CONTEXT.md` and `SESSION-LOG.md` act as durable memory that persists across every new session. You stop re-explaining scope, decisions, and current status every time Claude starts fresh.
- **Auto-memory encodes preferences.** Commit style, PR conventions, merge strategy, test-plan expectations — all land in memory once and apply automatically. No "and remember to use merge commits" tacked onto every prompt.
- **Phase-based planning docs anchor the work.** `plan.md` + `phase-N-checklist.md` + `implementation.md` turn ambiguous goals into numbered, scoped tasks Claude can execute against, one branch at a time.

Net effect: prompts get more responsive and code output tightens up, because Claude spends fewer tokens figuring out what you want and more tokens doing it. The setup front-loads the context work so every subsequent prompt can be short.

## The idea, in one paragraph

Every project gets **two parallel sets of files**:

1. **A private AI working folder** (outside the repo) — the canonical source of truth across sessions. Holds `CONTEXT.md`, `SESSION-LOG.md`, plan docs, phase checklists.
2. **Auto-memory** at `~/.claude/projects/<sanitized-path>/memory/` — durable facts about *you* and *how you want to work*: feedback, preferences, references, project context. One file per fact, indexed by `MEMORY.md`.

The working folder is project-specific knowledge ("what are we building, how far are we, what landed last week"). Auto-memory is cross-session behavior ("always use merge commits", "I prefer terse responses"). Neither is committed to the repo.

## How to use (new or existing project)

Works the same for greenfield repos and ones you're adopting it on mid-stream — the kit never modifies the target repo, it just creates an external working folder and seeds per-project auto-memory.

1. Read [SETUP.md](SETUP.md) — it walks you through the full bootstrap in ~10 minutes.
2. Pick a private working folder location (e.g. `~/Documents/Claude/Projects/<Project Name>/`).
3. From your target repo root, run `bootstrap.sh` — either of:
   - **Interactive (hand-held):** `bootstrap.sh` with no arguments prompts for working-folder path, project name, whether to seed auto-memory, your issue tracker (GitHub Issues / JIRA / Linear / GitLab / Shortcut / other / none), and your primary CI/automation tool (GitHub Actions / GitLab CI / Jenkins / CircleCI / Atlantis / Ansible CLI / other / none). For JIRA and Linear, it also prompts for the project or team key.
   - **Non-interactive (scripted):** `bootstrap.sh <working-folder> [--tracker TYPE] [--jira-project KEY | --linear-team KEY] [--ci TYPE]` — see `bootstrap.sh -h` for the full flag list.
4. Open Claude Code in the target repo and say *"Follow the instructions in `<working-folder>/SEED-PROMPT.md`."* Claude deep-reads your repo, fills the templates, flags anything it inferred or can't derive, and stops for your review.
5. Answer Claude's questions, confirm the inferences, and start working. From the next session onward (once `reference_ai_working_folder.md` is in auto-memory, which bootstrap seeds for you), the daily-use prompt is just *"Load context and give me a 3-bullet summary of where we are."* — full prompt library, including the verbose first-session form and mid-PR resume, in [PROMPTS.md](PROMPTS.md).

## The lifecycle

```
  bootstrap → seed prompt → first session → iterate → session-end → upgrade
   (once)      (once)        (once)         (loop)    (each end)   (per kit release)
```

- **Bootstrap** — once per project. Creates the working folder, seeds memory, drops `SEED-PROMPT.md`.
- **Seed prompt** — once, immediately after. Claude fills the templates, flags inferences, stops for review.
- **First session** — confirm inferences, start phase 0.
- **Iterate** — branch → commit → PR → merge → tick the checklist.
- **Session-end** — `SESSION-LOG.md` entry + `CONTEXT.md` status bump + checklist tick + memory pass. `/session-end` automates this.
- **Upgrade** — when the kit ships new templates / memory / commands, see [SETUP.md §Upgrading](SETUP.md#upgrading-an-existing-project).

## What's in here

<details>
<summary>File tree</summary>

```
.
├── README.md                ← you are here
├── SETUP.md                 ← step-by-step: starting a new project
├── FEATURES.md              ← feature-by-feature reference
├── CONVENTIONS.md           ← generic working rules (commits, PRs, etc.)
├── PROMPTS.md               ← ready-to-paste session-opening prompts
├── CHANGELOG.md             ← what's landed; upgrade notes for existing adopters
├── CONTRIBUTING.md          ← contributor onboarding
├── SECURITY.md              ← reporting vulnerabilities
├── LICENSE
├── bootstrap.sh             ← one-command setup (see SETUP.md step 2)
├── docs/adr/                ← Architecture Decision Records (see README inside)
├── templates/               ← copied into a new working folder
│   ├── SEED-PROMPT.md       ← instructions for Claude to auto-fill the rest
│   ├── CONTEXT.md
│   ├── SESSION-LOG.md
│   ├── plan.md
│   ├── implementation.md
│   ├── phase-N-checklist.md
│   ├── acceptance-test-results.md
│   ├── research.md
│   └── .claude/             ← starter agents + slash commands (staged in WF)
│       ├── agents/          ← code-reviewer, session-summarizer
│       ├── commands/        ← /session-start, /refresh-context, /close-phase, /session-end
│       └── README.md        ← how to copy into your target repo
├── examples/                ← filled-in reference — read, don't copy
│   └── widget-tracker/      ← fictional Go CLI, mid-Phase-1 snapshot
└── memory-templates/        ← starter auto-memory for a new project
    ├── MEMORY.md            ← index of memory files
    ├── user_role.md         ← who you are, how to calibrate
    ├── feedback_*.md        ← rules & preferences (commits, PRs, CI, etc.)
    ├── project_*.md         ← project context
    ├── reference_*.md       ← external pointers (working folder, etc.)
    ├── trackers/            ← per-tracker reference memory (github / jira / linear / gitlab / shortcut / other)
    └── ci/                  ← per-CI reference memory (github-actions / gitlab-ci / jenkins / circleci / atlantis / ansible-cli / other)
```

</details>

## Requirements

- **Bash 3.2+** — the macOS default works.
- **git** — `git remote get-url origin` is used to derive `{{REPO_SLUG}}`. Bootstrap still runs without it; you'll fill that placeholder by hand.
- **Claude Code CLI** — [install instructions](https://docs.claude.com/en/docs/claude-code).
- **Tested on:** macOS and Linux. Should work on WSL2; not currently tested on native Windows.

## Related docs

| Doc | What it covers |
|---|---|
| [SETUP.md](SETUP.md) | Full bootstrap walkthrough (interactive + scripted), upgrade flow, manual alternative, troubleshooting |
| [FEATURES.md](FEATURES.md) | Feature-by-feature reference with example invocations |
| [PROMPTS.md](PROMPTS.md) | Session-opening / session-end prompt library |
| [CONVENTIONS.md](CONVENTIONS.md) | Commit / PR / CI rules the kit assumes |
| [CHANGELOG.md](CHANGELOG.md) | What's shipped, with **For existing adopters** notes per release |
| [CONTRIBUTING.md](CONTRIBUTING.md) | Adding tracker / CI variants, running the Bats suite, PR shape |
| [SECURITY.md](SECURITY.md) | Vulnerability reporting |
| [docs/adr/](docs/adr/) | Architecture Decision Records — why the kit's structural decisions look the way they do |

## When to update this framework

Treat this kit as a living template. If a pattern or rule proves useful on a real project, fold it back in here so future projects start ahead. Conversely, if something in here turns out to be dead weight, prune it.

## Scope & assumptions

The conventions and tooling notes are written assuming **Git + GitHub + GitHub Actions**. They translate cleanly to GitLab (MRs, `glab ci`, pipelines), Jenkins, Azure DevOps, etc. — adapt the specifics, keep the principles.

## Support

If this kit saved you time and you'd like to throw a coffee my way:

- [ko-fi.com/iammrcupp](https://ko-fi.com/iammrcupp)
- [buymeacoffee.com/iammrcupp](https://buymeacoffee.com/iammrcupp)

No pressure — the kit's MIT-licensed and will stay that way regardless.

## License

MIT — see [LICENSE](LICENSE). Use it, fork it, strip out what doesn't fit your context.
