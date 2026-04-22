# Claude Project Framework

A reusable scaffold for starting new projects with Claude. Battle-tested on real projects and generalized so it works for personal code, open-source, or work projects.

## Why this works

The templates aren't the point — what they do *to* Claude is:

- **External docs survive sessions.** `CONTEXT.md` and `SESSION-LOG.md` act as durable memory that persists across every new session. You stop re-explaining scope, decisions, and current status every time Claude starts fresh.
- **Auto-memory encodes preferences.** Commit style, PR conventions, merge strategy, test-plan expectations — all land in memory once and apply automatically. No "and remember to use merge commits" tacked onto every prompt.
- **Phase-based planning docs anchor the work.** `plan.md` + `phase-N-checklist.md` + `implementation.md` turn ambiguous goals into numbered, scoped tasks Claude can execute against, one branch at a time.

Net effect: prompts get more responsive and code output tightens up, because Claude spends fewer tokens figuring out what you want and more tokens doing it. The setup front-loads the context work so every subsequent prompt can be short.

## The idea, in one paragraph

Every project gets **two parallel sets of files**:

1. **A private AI working folder** (outside the repo) — the canonical source of truth across sessions. Holds `CONTEXT.md`, `SESSION-LOG.md`, plan docs, phase checklists.
2. **Auto-memory** at `~/.claude/projects/<hash>/memory/` — durable facts about *you* and *how you want to work*: feedback, preferences, references, project context. One file per fact, indexed by `MEMORY.md`.

The working folder is project-specific knowledge ("what are we building, how far are we, what landed last week"). Auto-memory is cross-session behavior ("always use merge commits", "I prefer terse responses"). Neither is committed to the repo.

## What's in here

```
.
├── README.md                ← you are here
├── SETUP.md                 ← step-by-step: starting a new project
├── CONVENTIONS.md           ← generic working rules (commits, PRs, etc.)
├── PROMPTS.md               ← ready-to-paste session-opening prompts
├── LICENSE
├── bootstrap.sh             ← one-command setup (see SETUP.md step 2)
├── templates/               ← copy these into a new working folder
│   ├── CONTEXT.md
│   ├── SESSION-LOG.md
│   ├── plan.md
│   ├── implementation.md
│   ├── phase-N-checklist.md
│   ├── acceptance-test-results.md
│   └── research.md
├── examples/                ← filled-in reference — read, don't copy
│   └── widget-tracker/      ← fictional Go CLI, mid-Phase-1 snapshot
└── memory-templates/        ← starter auto-memory for a new project
    ├── MEMORY.md            ← index of memory files
    ├── user_role.md         ← who you are, how to calibrate
    ├── feedback_*.md        ← rules & preferences (commits, PRs, CI, etc.)
    ├── project_*.md         ← project context
    └── reference_*.md       ← external pointers (working folder, etc.)
```

## How to use (new or existing project)

Works the same for greenfield repos and ones you're adopting it on mid-stream — the kit never modifies the target repo, it just creates an external working folder and seeds per-project auto-memory.

1. Read [SETUP.md](SETUP.md) — it walks you through the full bootstrap in ~10 minutes.
2. Pick a private working folder location (e.g. `~/Documents/Claude/Projects/<Project Name>/`).
3. Copy templates, fill in placeholders (marked `{{LIKE_THIS}}`).
4. Seed auto-memory with relevant starters from `memory-templates/` — edit to match the project.
5. Open a Claude session and use a prompt from [PROMPTS.md](PROMPTS.md) to load project context before you start working.

## When to update this framework

Treat this kit as a living template. If a pattern or rule proves useful on a real project, fold it back in here so future projects start ahead. Conversely, if something in here turns out to be dead weight, prune it.

## Scope & assumptions

The conventions and tooling notes are written assuming **Git + GitHub + GitHub Actions**. They translate cleanly to GitLab (MRs, `glab ci`, pipelines), Jenkins, Azure DevOps, etc. — adapt the specifics, keep the principles.

## License

MIT — see [LICENSE](LICENSE). Use it, fork it, strip out what doesn't fit your context.
