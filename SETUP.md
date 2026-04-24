# Setup — adopting this framework on a project

Target: you have a repo (new, or existing and already in flight) and want Claude sessions productive from day one. The steps are identical either way — for an existing repo, `CONTEXT.md` should describe the *current* architecture, conventions, and in-flight work rather than a greenfield plan.

> **Before you start — three locations get populated** (none is your repo):
> - **Kit checkout** (wherever you cloned this repo) — templates and `bootstrap.sh`; you interact with it only when running the script or pulling updates.
> - **Working folder** — you pick the path in step 1 below (several options listed); per-project context lives here.
> - **Auto-memory** at `~/.claude/projects/<sanitized-path>/memory/` — fixed by the Claude harness, derived from your repo path; per-project preferences live here.
>
> Step 2's `bootstrap.sh` creates the working folder and seeds auto-memory in one pass.

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

From the root of the project repo you're bootstrapping, run bootstrap in whichever mode fits:

**Non-interactive (scripted):**
```bash
cd <project-repo>
<framework-dir>/bootstrap.sh <working-folder> [options]
```

**Interactive (hand-held — omit the path argument):**
```bash
cd <project-repo>
<framework-dir>/bootstrap.sh
```
Bootstrap prompts for the working-folder path, project name, whether to seed auto-memory, and your issue tracker (`github` / `jira` / `linear` / `gitlab` / `shortcut` / `other` / `none`, default `github`). For `jira` and `linear`, it also prompts for the project/team key. It then shows a summary and asks to confirm before any file writes. Scripted invocations (piped/redirected stdin) without a path argument still error rather than hanging.

Both modes create the working folder, copy the templates, rename `phase-N-checklist.md` → `phase-0-checklist.md`, and seed the project's auto-memory at the Claude harness's expected path (`~/.claude/projects/<sanitized>/memory/`). When an issue tracker is selected, a `reference_issue_tracker.md` file is seeded into auto-memory with tracker-specific guidance.

Flags:
- `--skip-memory` — skip the memory-seeding step (leaves `~/.claude/projects/…` alone)
- `--project-name NAME` — override the auto-derived project name
- `--tracker TYPE` — issue tracker: `github`, `jira`, `linear`, `gitlab`, `shortcut`, `other`, or `none`. Skipped if omitted in non-interactive mode.
- `--jira-project KEY` — JIRA project key (e.g. `INFRA`). Implies `--tracker jira` if `--tracker` isn't also passed.
- `--linear-team KEY` — Linear team key (e.g. `ENG`). Implies `--tracker linear` if `--tracker` isn't also passed.
- `--force` — proceed even if the working folder is already non-empty
- `-h` / `--help` — show usage

Prefer to see what's happening step-by-step? See [Manual alternative](#manual-alternative) at the bottom of this doc.

---

## 3. Run the seed prompt

`bootstrap.sh` dropped a `SEED-PROMPT.md` into your working folder alongside the other templates. Open Claude Code in your target repo and say:

> Follow the instructions in `<working-folder>/SEED-PROMPT.md`.

Claude will:

- Read your target repo's README, package manifests, CI config, top-level source layout, and recent git activity.
- Fill every field in `CONTEXT.md` that it can derive directly from the code or git state (project name, stack, CI platform, build commands, repo URL, etc.).
- Mark fields it had to interpret with `[CLAUDE-INFERRED: <reasoning>]` — architecture summary, key dependencies — so you can confirm or correct in one pass.
- Mark fields it can't derive with `[HUMAN-CONFIRM: <question>]` — project goals, stakeholders, phase status — things only you know.
- Draft an initial `research.md` from what it read of the code.
- **Stop**, summarize, and ask ≤5 targeted questions. It won't proceed past the draft pass without your confirmation.

Answer the questions, sweep the `[CLAUDE-INFERRED]` / `[HUMAN-CONFIRM]` markers, and the working folder is ready.

For a fully filled-in reference to compare against, see [`examples/widget-tracker/CONTEXT.md`](examples/widget-tracker/CONTEXT.md). The other docs (`plan.md`, `implementation.md`, etc.) can stay mostly skeletal until you're ready to plan real work.

Prefer to fill everything by hand? See [Manual alternative](#manual-alternative) at the bottom.

---

## 4. Tune your auto-memory

`bootstrap.sh` already dropped the starter memory files into your project's memory folder and auto-filled the common placeholders (`{{WORKING_FOLDER}}`, `{{REPO_PATH}}`, `{{PROJECT_NAME}}`, and `{{REPO_SLUG}}` if your repo has a `git remote origin`). What's left is optional personalization:

- `user_role.md` — your role and background *as it relates to this project* (Claude uses this to calibrate explanations)
- `project_current.md` — if `bootstrap.sh` couldn't derive `{{REPO_SLUG}}` (e.g. no git remote yet), fill it manually
- `reference_ai_working_folder.md` — review the `{{public/private}}` marker and decide visibility
- Prune feedback/project files that don't apply; tune the ones that do
- Keep `MEMORY.md` in sync with whatever files you end up with

Pass `--project-name "<name>"` to `bootstrap.sh` if the working folder basename doesn't match the project name you want in memory.

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

If you can't run `bootstrap.sh` (no Bash available, restricted environment, or you just want to see what it does) **or** you'd rather fill the templates by hand instead of running the seed prompt, perform the same work manually.

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

### Fill placeholders by hand

Every template uses `{{PLACEHOLDER}}` markers. Search-and-replace in your editor. Start with `CONTEXT.md` — it drives everything else. Minimum fill-in:

- `{{PROJECT_NAME}}` — human-friendly name
- `{{REPO_SLUG}}` — e.g. `owner/repo`
- `{{REPO_URL}}` — full URL, e.g. `https://github.com/owner/repo`
- `{{REPO_PATH}}` — absolute local path
- `{{WORKING_FOLDER}}` — path to this folder
- `{{ONE_PARAGRAPH_DESCRIPTION}}` — what the project is, in plain English
- `{{PLATFORM_TARGETS}}` — macOS / Linux / Windows / web / etc.

For a fully filled-in reference, see [`examples/widget-tracker/CONTEXT.md`](examples/widget-tracker/CONTEXT.md) — a fictional Go CLI project at a plausible mid-phase state.

---

## Upgrading an existing project

`bootstrap.sh` is deliberately **write-once** — it won't touch a working folder or auto-memory dir that's already populated. When the kit evolves, existing adopters upgrade manually:

1. Check [`CHANGELOG.md`](CHANGELOG.md) to see what's landed since your bootstrap SHA (or since the last time you upgraded). Each entry has a **For existing adopters** section with specifics.
2. **New files in `templates/`** — copy into your working folder manually:
   ```bash
   cp <kit-dir>/templates/<NEW_FILE>.md <working-folder>/
   ```
3. **New files in `memory-templates/`** — copy into your auto-memory dir:
   ```bash
   cp <kit-dir>/memory-templates/<NEW_FILE>.md ~/.claude/projects/<sanitized-path>/memory/
   ```
4. **Changed prose in kit-level files** (e.g. `CONVENTIONS.md`, `SETUP.md`, `README.md`) — re-read them. Your local copies of working-folder templates and memory files are yours; they don't auto-upgrade.
5. **New `bootstrap.sh` flags or behavior** — apply only to *new* projects you bootstrap going forward. Already-bootstrapped projects keep their current state.
6. **Don't re-run `bootstrap.sh`** on a populated working folder — it errors by design. If you really need to re-seed, clear the auto-memory dir manually and pass `--force` to the working folder, but you'll lose local customizations.

If a future change is *not* backwards-compatible (rare for a docs-only kit — only likely if a template structure fundamentally changes), the CHANGELOG entry will call that out explicitly.

---

## Troubleshooting

**Claude doesn't read the working folder automatically.** It has to be told each session. Either say it explicitly ("Read CONTEXT.md and SESSION-LOG.md…") or rely on the `reference_ai_working_folder.md` memory entry to remind it.

**Auto-memory path looks wrong.** If you can't find `~/.claude/projects/<sanitized-path>/memory/`, just launch `claude` once in the repo — the harness creates it. Then `ls ~/.claude/projects/` and find yours by mtime.

**Templates feel like too much structure for a small project.** You don't need all of them. Bare minimum for a weekend project: `CONTEXT.md` + `SESSION-LOG.md`. Add the rest when scope warrants.
