# Setup — adopting this framework on a project

Target: you have a repo (new, or existing and already in flight) and want Claude sessions productive from day one. The steps are identical either way — for an existing repo, `CONTEXT.md` should describe the *current* architecture, conventions, and in-flight work rather than a greenfield plan.

---

## 1. Pick a working-folder location

**Private, outside the repo, persistent across sessions.** Common choices:

- `~/claude-projects/<project-name>/` — simple, machine-local
- `~/Documents/Claude/Projects/<project-name>/` — if you want it grouped with other Claude docs
- A private synced folder (OneDrive / Google Drive / Dropbox) if you want the context on multiple machines
- A team-shared drive if multiple people collaborate on the same project and need shared context

Avoid:
- Any folder auto-synced to a **public** cloud location
- The repo itself (the working folder is deliberately separate)
- For work projects: anywhere that violates your employer's data-handling policy

Whatever you pick, the **repo stays the repo; the working folder stays separate**. Never commit it.

> Throughout this guide, `<framework-dir>` means wherever you've cloned/extracted this kit (e.g. `~/Code/claude-project-kit`), and `<working-folder>` means the path you just picked above.

---

## 2. Run `bootstrap.sh`

From the root of the project repo you're bootstrapping:

```bash
cd <project-repo>
<framework-dir>/bootstrap.sh <working-folder>
```

That creates the working folder, copies the templates, renames `phase-N-checklist.md` → `phase-0-checklist.md`, and seeds the project's auto-memory at the Claude harness's expected path (`~/.claude/projects/<sanitized>/memory/`).

Flags:
- `--skip-memory` — skip the memory-seeding step (leaves `~/.claude/projects/…` alone)
- `--force` — proceed even if the working folder is already non-empty
- `-h` / `--help` — show usage

Prefer to see what's happening step-by-step? See [Manual alternative](#manual-alternative) at the bottom of this doc.

---

## 3. Fill in placeholders

Every template uses `{{PLACEHOLDER}}` markers. Search-and-replace in your editor, or edit by hand. Start with `CONTEXT.md` — it drives everything else. Minimum fill-in:

- `{{PROJECT_NAME}}` — human-friendly name
- `{{REPO_SLUG}}` — e.g. `owner/repo`
- `{{REPO_URL}}` — full URL, e.g. `https://github.com/owner/repo`
- `{{REPO_PATH}}` — absolute local path
- `{{WORKING_FOLDER}}` — path to this folder
- `{{ONE_PARAGRAPH_DESCRIPTION}}` — what the project is, in plain English
- `{{PLATFORM_TARGETS}}` — macOS / Linux / Windows / web / etc.

For a fully filled-in reference, see [`examples/widget-tracker/CONTEXT.md`](examples/widget-tracker/CONTEXT.md) — a fictional Go CLI project at a plausible mid-phase state. The matching `plan.md`, `SESSION-LOG.md`, and `phase-1-checklist.md` live alongside it. Read them when you want to see what "populated" looks like rather than what the template dictates.

The other docs (`plan.md`, `implementation.md`, etc.) can stay mostly skeletal until you're ready to plan real work.

---

## 4. Tune your auto-memory

`bootstrap.sh` already dropped the starter memory files into your project's memory folder. Now edit them to match your actual rules and tooling:

- `reference_ai_working_folder.md` — fill in `{{WORKING_FOLDER}}` and `{{PROJECT_NAME}}` so Claude knows where to look
- `user_role.md` — your role and background *as it relates to this project* (Claude uses this to calibrate explanations)
- Prune feedback/project files that don't apply; tune the ones that do
- Keep `MEMORY.md` in sync with whatever files you end up with

If you ran bootstrap with `--skip-memory`, see the [Manual alternative](#manual-alternative) for how to seed it by hand.

---

## 5. Review [CONVENTIONS.md](CONVENTIONS.md)

It captures the non-negotiables that have held up across projects: Conventional Commits, single-line commit messages, merge-commit PR strategy, detailed PR test plans, CI-in-background. Not every rule applies to every project — read through, keep what fits, drop what doesn't.

For work projects especially, vet each rule against your employer's policies before keeping it.

---

## 6. First session

Open Claude in the repo and paste **Prompt 1 ("Starting work on a project that uses this kit")** from [PROMPTS.md](PROMPTS.md). That prompt tells Claude to read your working folder's `CONTEXT.md` + `SESSION-LOG.md` + current phase checklist, then hand back a short summary — so you start every session grounded in real project state.

For quick reference, the bare minimum version is:

> Read `CONTEXT.md` and `SESSION-LOG.md` in `<working-folder>` before we start.

…but the full PROMPTS.md version handles edge cases (what to summarize, when to wait, not editing the working folder) and scales to more scenarios as you find them.

From there, the normal flow:

1. **Plan** — flesh out `plan.md` into phases. Ask Claude to help if the scope is fuzzy.
2. **Phase 0** — scaffold the phase-0 checklist (repo setup, CI, license, initial build).
3. **Iterate** — branch → commit → PR → merge → tick the checklist.
4. **At session end** — append a `SESSION-LOG.md` entry describing what happened.

---

## 7. End-of-session hygiene

Every working session should end with:

1. An append to `SESSION-LOG.md` (date, focus, branches/PRs merged, decisions, open threads)
2. `CONTEXT.md` status line bumped if anything material changed
3. Checklist items ticked with branch name + PR number
4. Auto-memory refreshed — if a rule came up twice, save it as feedback

The habit that makes this work: the **last thing you do** before quitting is update these docs. It takes two minutes and rescues the next session from "where was I?"

---

## Manual alternative

If you can't run `bootstrap.sh` (no Bash available, restricted environment, or you just want to see what it does), perform the same work by hand.

### Copy templates
```bash
mkdir -p "<working-folder>"
cp <framework-dir>/templates/*.md "<working-folder>/"
mv "<working-folder>/phase-N-checklist.md" "<working-folder>/phase-0-checklist.md"
```

### Seed auto-memory
The harness expects memory at `~/.claude/projects/<sanitized-path>/memory/`. Sanitization rule: absolute repo path with `/` replaced by `-`, prefixed with `-`. Example: `/Users/you/Code/acme/foo` → `-Users-you-Code-acme-foo`.

```bash
PROJECT_MEMORY=~/.claude/projects/<sanitized-path>/memory
mkdir -p "$PROJECT_MEMORY"
cp <framework-dir>/memory-templates/*.md "$PROJECT_MEMORY/"
```

---

## Troubleshooting

**Claude doesn't read the working folder automatically.** It has to be told each session. Either say it explicitly ("Read CONTEXT.md and SESSION-LOG.md…") or rely on the `reference_ai_working_folder.md` memory entry to remind it.

**Auto-memory path looks wrong.** If you can't find `~/.claude/projects/<sanitized-path>/memory/`, just launch `claude` once in the repo — the harness creates it. Then `ls ~/.claude/projects/` and find yours by mtime.

**Templates feel like too much structure for a small project.** You don't need all of them. Bare minimum for a weekend project: `CONTEXT.md` + `SESSION-LOG.md`. Add the rest when scope warrants.
