# Setup — starting a new project with this framework

Target: you have a new repo (or idea) and want Claude sessions productive from day one.

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

## 2. Copy the templates

```bash
mkdir -p "<working-folder>"
cp <framework-dir>/templates/*.md "<working-folder>/"
```

Rename `phase-N-checklist.md` → `phase-0-checklist.md` to start.

---

## 3. Fill in placeholders

Every template uses `{{PLACEHOLDER}}` markers. Search-and-replace in your editor, or edit by hand. Start with `CONTEXT.md` — it drives everything else. Minimum fill-in:

- `{{PROJECT_NAME}}` — human-friendly name
- `{{REPO_SLUG}}` — e.g. `owner/repo`
- `{{REPO_PATH}}` — absolute local path
- `{{WORKING_FOLDER}}` — path to this folder
- `{{ONE_PARAGRAPH_DESCRIPTION}}` — what the project is, in plain English
- `{{PLATFORM_TARGETS}}` — macOS / Linux / Windows / web / etc.

The other docs (`plan.md`, `implementation.md`, etc.) can stay mostly skeletal until you're ready to plan real work.

---

## 4. Seed auto-memory

Find the project's memory folder. When you launch `claude` in the repo for the first time, the harness creates:

```
~/.claude/projects/<sanitized-repo-path>/memory/
```

The sanitization rule: absolute path with `/` replaced by `-`, prefixed with `-`. For example `/Users/you/Code/acme/foo` → `-Users-you-Code-acme-foo`.

Copy starter memory files:

```bash
PROJECT_MEMORY=~/.claude/projects/<sanitized-path>/memory
mkdir -p "$PROJECT_MEMORY"
cp <framework-dir>/memory-templates/*.md "$PROJECT_MEMORY/"
```

Then edit each one: delete what doesn't apply, tune what does. Especially:
- `reference_ai_working_folder.md` — point it at the working folder you picked in step 1
- `user_role.md` — your role and background *as it relates to this project* (Claude uses this to calibrate explanations)
- `MEMORY.md` — keep the index in sync with whatever files you end up with

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

## Troubleshooting

**Claude doesn't read the working folder automatically.** It has to be told each session. Either say it explicitly ("Read CONTEXT.md and SESSION-LOG.md…") or rely on the `reference_ai_working_folder.md` memory entry to remind it.

**Auto-memory path looks wrong.** If you can't find `~/.claude/projects/<sanitized-path>/memory/`, just launch `claude` once in the repo — the harness creates it. Then `ls ~/.claude/projects/` and find yours by mtime.

**Templates feel like too much structure for a small project.** You don't need all of them. Bare minimum for a weekend project: `CONTEXT.md` + `SESSION-LOG.md`. Add the rest when scope warrants.
