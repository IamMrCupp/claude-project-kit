# Claude Project Framework

A reusable scaffold for starting new projects with Claude. Battle-tested on real projects and generalized so it works for personal code, open-source, or work projects.

> **Heads up — Claude state for a bootstrapped project lives in three places, none of them your repo:**
> 1. **Kit checkout** (wherever you cloned this repo) — templates, `bootstrap.sh`, docs.
> 2. **Working folder** (you pick the path — [SETUP.md §1](SETUP.md#1-pick-a-working-folder-location) lists options) — per-project context.
> 3. **Auto-memory** at `~/.claude/projects/<sanitized-path>/memory/` (fixed by the Claude harness) — per-project preferences.
>
> The kit never modifies your repo. All three locations above are private and local.

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

## What's in here

```
.
├── README.md                ← you are here
├── SETUP.md                 ← step-by-step: starting a new project
├── CONVENTIONS.md           ← generic working rules (commits, PRs, etc.)
├── PROMPTS.md               ← ready-to-paste session-opening prompts
├── CHANGELOG.md             ← what's landed; upgrade notes for existing adopters
├── LICENSE
├── bootstrap.sh             ← one-command setup (see SETUP.md step 2)
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
│       ├── commands/        ← /close-phase, /session-end
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

## How to use (new or existing project)

Works the same for greenfield repos and ones you're adopting it on mid-stream — the kit never modifies the target repo, it just creates an external working folder and seeds per-project auto-memory.

1. Read [SETUP.md](SETUP.md) — it walks you through the full bootstrap in ~10 minutes.
2. Pick a private working folder location (e.g. `~/Documents/Claude/Projects/<Project Name>/`).
3. From your target repo root, run `bootstrap.sh` — either of:
   - **Interactive (hand-held):** `bootstrap.sh` with no arguments prompts for working-folder path, project name, whether to seed auto-memory, your issue tracker (GitHub Issues / JIRA / Linear / GitLab / Shortcut / other / none), and your primary CI/automation tool (GitHub Actions / GitLab CI / Jenkins / CircleCI / Atlantis / Ansible CLI / other / none). For JIRA and Linear, it also prompts for the project or team key.
   - **Non-interactive (scripted):** `bootstrap.sh <working-folder> [--tracker TYPE] [--jira-project KEY | --linear-team KEY] [--ci TYPE]` — see `bootstrap.sh -h` for the full flag list.
4. Open Claude Code in the target repo and say *"Follow the instructions in `<working-folder>/SEED-PROMPT.md`."* Claude deep-reads your repo, fills the templates, flags anything it inferred or can't derive, and stops for your review.
5. Answer Claude's questions, confirm the inferences, and start working. The normal per-session prompt lives in [PROMPTS.md](PROMPTS.md).

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
