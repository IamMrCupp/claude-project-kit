# Prompts

Ready-to-paste prompts for starting Claude sessions in common scenarios. Copy the prompt, fill in any `<placeholders>`, paste into a fresh session.

---

## 1. Starting work on a project that uses this kit

Use this when opening a fresh Claude session in a repo you've already bootstrapped with the kit's templates and memory starters. The prompt points Claude at your persistent working folder so it picks up project state from where the last session left off.

```
Before we start, read these files in my AI working folder, in order:

1. `<working-folder>/CONTEXT.md` — project overview, working rules, current phase
2. `<working-folder>/SESSION-LOG.md` — chronological session history
3. The current phase's checklist (e.g. `<working-folder>/phase-<N>-checklist.md`)

These are my persistent project context — they live outside the repo and hold
scope, decisions, and current status. Don't edit them unless I ask; updates
happen at session end.

Once read, give me a 3–5 bullet summary of: where we are in the project, what
landed most recently, and any open threads. Then wait for my next instruction.
```

**Notes:**
- Replace `<working-folder>` with the actual path (e.g. `~/Documents/Claude/Projects/my-project/`)
- **Once you've set up `memory-templates/reference_ai_working_folder.md` for the project**, the memory tells Claude where to look automatically — you can shorten the prompt to *"Load context and give me a 3-bullet summary of where we are."*
- If you're resuming mid-PR, add a line: *"I also had a branch `<branch-name>` open — check its state before suggesting next steps."*

---

## 2. Starting work on the kit itself

Use this when opening a fresh Claude session inside this repo (`claude-project-kit`) to improve the kit itself — add templates, refine conventions, fix docs. Fully self-contained; no prior conversation required.

```
Hi Claude. I'm working on `claude-project-kit` (the repo this session is
opened in — confirm with `pwd`). It's a scaffolding kit for starting
Claude-assisted projects: working-folder templates, auto-memory starters,
and cross-project conventions.

## Before we work — read these in order

1. `README.md` — what the kit is, why it works, what's inside
2. `SETUP.md` — how the kit is meant to be used for a new project
3. `CONVENTIONS.md` — the working rules the kit advocates; the kit itself
   should follow them (eat our own dogfood)
4. `PROMPTS.md` — the session-opening prompts the kit provides
5. One file each from `templates/` and `memory-templates/` so you've seen
   the concrete shape of what the kit produces

## Rules of engagement

- **Follow `CONVENTIONS.md` for this repo's own work** — Conventional Commits
  single-line with `-s` sign-off, branch name proposed before coding,
  merge-commit PR strategy, detailed manual test plans where applicable.
- If I ask for something that contradicts the kit's own conventions, flag it.
  A kit that preaches X while itself doing Y is a credibility leak.
- This repo is docs + templates — no runtime code — so "test plans" usually
  reduce to "did the README still render correctly, are template placeholders
  consistent across files," etc.

## To start

Read the files above, then give me a tight 5-bullet read on the repo:
what's strong, what's weak, where you'd expect a first-time user to get
confused. Don't make changes yet — align on direction first.
```

**Notes:**
- This prompt is deliberately verbose because it starts fully cold — no prior conversation, no memory on the kit repo.
- After a few sessions, if you want continuity across kit-development work, bootstrap the kit using its own templates: create `~/Documents/Claude/Projects/claude-project-kit/` with its own `CONTEXT.md` + `SESSION-LOG.md`, and then you can switch to the shorter prompt #1 above. Meta, but useful — and a live demo that the kit works.

---

## When to write a new prompt

Add one here whenever you find yourself typing similar setup instructions into a fresh session for the third time. A good prompt is:

- **Self-contained** — assumes no memory of prior conversations
- **Specific about what to read** — don't make Claude guess
- **Explicit about rules of engagement** — merge strategy, commit format, test expectations
- **Ends with a concrete first action** — a summary, a plan, a question — so Claude has something to do before it asks "what do you want?"
