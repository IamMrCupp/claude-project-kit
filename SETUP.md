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

> **One-time, per machine: tell Claude Code to trust the working-folder root.** Because the working folder lives outside any repo, Claude Code prompts for permission every time it reads or writes `CONTEXT.md` / `SESSION-LOG.md` / phase checklists. Add the **parent directory** of your working folders to `permissions.additionalDirectories` in `~/.claude/settings.json` once and the prompts stop — for every kit project that lives under that root, on both the macOS desktop app and the CLI.
>
> ```json
> {
>   "permissions": {
>     "additionalDirectories": [
>       "~/Documents/Claude/Projects/"
>     ]
>   }
> }
> ```
>
> Adjust the path to match wherever you keep your working folders (`~/claude-projects/`, a synced drive, etc.). One entry covers every project underneath it.
>
> **Two ways to set this:**
>
> 1. **Hand-edit** the JSON above (most explicit, no kit involvement). Restart Claude Code afterwards.
> 2. **Let bootstrap do it for you** with the opt-in flag `--trust-working-folder-root`, or accept the interactive prompt during `bootstrap.sh` setup. Bootstrap appends only the working-folder parent (idempotent — skip if already there), backs up the existing `~/.claude/settings.json` to `settings.json.bak.<timestamp>` before writing, and prints the diff before applying. You can also pass `--dry-run` to preview without writing. The kit *only* mutates `permissions.additionalDirectories` for the working-folder parent; nothing else in the file is touched.
>
> **If you use the kit on more than one machine** (work laptop + personal desktop, etc.), repeat the setup on each. `~/.claude/settings.json` is local user config, not part of the kit repo, so cloning the kit on a new machine won't bring it along.

> **Heads-up: `<repo>/.claude/settings.local.json`.** Claude Code writes this file in every project where you grant Bash / MCP / read-path permissions interactively. It is **per-project, machine-specific, and Claude-Code-managed** — the kit doesn't create or edit it. **Add it to your `.gitignore`** so machine-specific permissions don't get committed and follow the repo around. Two equivalent forms:
>
> ```bash
> # Per-repo (add this line to <repo>/.gitignore)
> .claude/settings.local.json
>
> # Once globally — covers every repo on this machine
> # (add this line to ~/.config/git/ignore)
> **/.claude/settings.local.json
> ```
>
> If a permission is one you want allowed in *every* kit project (e.g. `Bash(gh run *)` for CI watchers), graduate it from the per-project `.claude/settings.local.json` to the global `~/.claude/settings.json` by hand. The kit doesn't sync this for the same reason it doesn't write to `~/.claude/settings.json` for you — global config is yours to curate.

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
Bootstrap prompts for the working-folder path, project name, whether to seed auto-memory, your issue tracker (`github` / `jira` / `linear` / `gitlab` / `shortcut` / `other` / `none`, default `github`), and your primary CI/automation tool (`github-actions` / `gitlab-ci` / `jenkins` / `circleci` / `atlantis` / `ansible-cli` / `other` / `none`, default `none`). For `jira` and `linear`, it also prompts for the project/team key. It then shows a summary and asks to confirm before any file writes. Scripted invocations (piped/redirected stdin) without a path argument still error rather than hanging.

Both modes create the working folder, copy the templates, rename `phase-N-checklist.md` → `phase-0-checklist.md`, and seed the project's auto-memory at the Claude harness's expected path (`~/.claude/projects/<sanitized>/memory/`). When an issue tracker is selected, a `reference_issue_tracker.md` file is seeded into auto-memory with tracker-specific guidance.

Flags:
- `--skip-memory` — skip the memory-seeding step (leaves `~/.claude/projects/…` alone)
- `--project-name NAME` — override the auto-derived project name
- `--tracker TYPE` — issue tracker: `github`, `jira`, `linear`, `gitlab`, `shortcut`, `other`, or `none`. Skipped if omitted in non-interactive mode.
- `--jira-project KEY` — JIRA project key (e.g. `INFRA`). Implies `--tracker jira` if `--tracker` isn't also passed.
- `--linear-team KEY` — Linear team key (e.g. `ENG`). Implies `--tracker linear` if `--tracker` isn't also passed.
- `--ci TYPE` — primary CI/automation tool: `github-actions`, `gitlab-ci`, `jenkins`, `circleci`, `atlantis`, `ansible-cli`, `other`, or `none`. Skipped if omitted in non-interactive mode.
- `--force` — proceed even if the working folder is already non-empty
- `--dry-run` — print what would be created (paths, placeholder substitutions, tracker memory, MEMORY.md index line) and exit without writing anything. Safe to re-run.
- `--workspace` — treat `<working-folder>` as a workspace path (multi-repo mode). Bootstrap creates a per-repo subfolder for the current repo inside the workspace, and on first use also seeds `workspace-CONTEXT.md` and `tickets/`. See [Workspace mode](#workspace-mode-multi-repo-initiatives) below.
- `--trust-working-folder-root` — opt-in: append the working folder's parent directory to `permissions.additionalDirectories` in `~/.claude/settings.json` so Claude Code stops prompting on every read of `CONTEXT.md` / `SESSION-LOG.md` / phase checklists. Backs up the existing settings.json before writing; idempotent (skip if already present); honors `--dry-run`. In interactive mode, bootstrap also asks before doing this — the flag opts in for scripted runs. See §1 above for the manual alternative.
- `-h` / `--help` — show usage

**On `--tracker other` and `--ci other`:** these are escape hatches for tools the kit doesn't have a named variant for. Picking either seeds a placeholder-rich memory file (`reference_issue_tracker.md` for trackers, `reference_ci.md` for CI) with `{{tracker URL pattern}}`, `{{ticket reference format}}`, `{{CI config location}}`, etc. that need manual fill-in before the memory is useful. The bootstrap end-of-run output flags this; if you're scanning flags to plan an invocation, plan for the follow-up edit.

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

Open Claude in the repo and paste the **verbose form of Prompt 1 ("Starting work on a project that uses this kit")** from [PROMPTS.md](PROMPTS.md). It tells Claude to read your working folder's `CONTEXT.md` + `SESSION-LOG.md` + current phase checklist, then hand back a short summary — so you start every session grounded in real project state.

After your first session, your auto-memory has `reference_ai_working_folder.md` (seeded by bootstrap), which means Claude already knows where the working folder lives. From then on, your **daily-use prompt** collapses to one line:

> Load context and give me a 3-bullet summary of where we are.

That's the steady-state prompt for every subsequent session — short, paste-able, and discoverable in [PROMPTS.md §1](PROMPTS.md). The verbose form is still there for edge cases (no auto-memory yet, switching machines, debugging an unexpected response).

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

For a scaffolded version of this pass, paste **Prompt 3 ("Wrapping up a session")** from [PROMPTS.md](PROMPTS.md), or run the **`/session-end`** slash command. Both draft all four items and stop for your review before writing anything — easier than remembering each piece by hand.

**For interrupted sessions** (switching to Claude desktop, abrupt pause, context-window pressure), use **`/session-handoff`** instead — same drafting work but writes immediately, no confirmation gate. Persistence over polish; review on the next `/session-start`. Pairs with `bootstrap.sh`'s automatic Bootstrap entry — between the two, even an aborted bootstrap-and-seed-prompt session leaves a durable record on disk.

---

## Manual alternative

If you can't run `bootstrap.sh` (no Bash available, restricted environment, or you just want to see what it does) **or** you'd rather fill the templates by hand instead of running the seed prompt, perform the same work manually.

### Copy templates
```bash
mkdir -p "<working-folder>"
cp <framework-dir>/templates/*.md "<working-folder>/"
mv "<working-folder>/phase-N-checklist.md" "<working-folder>/phase-0-checklist.md"
[ -d "<framework-dir>/templates/.claude" ] && cp -R "<framework-dir>/templates/.claude" "<working-folder>/"
```

The `.claude/` directory holds starter agents and slash commands that match the kit's session-start, session-end, session-handoff, and phase-close conventions. **Recommended install: globally, once per machine** so they're available across every kit project:

```bash
<framework-dir>/scripts/install-commands.sh --global
```

The helper is idempotent and never overwrites existing files. To scope to one repo instead, use `--project <repo-path>`. See [`templates/.claude/README.md`](templates/.claude/README.md) for the full list (two agents + six slash commands), the kit-coupling caveat (most commands assume a kit working folder), and manual-copy alternatives.

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

For fully filled-in references, see [`examples/widget-tracker/CONTEXT.md`](examples/widget-tracker/CONTEXT.md) (a fictional Go CLI single-repo project, mid-Phase 1) and [`examples/lx-platform/`](examples/lx-platform/) (a fictional Terraform multi-repo workspace driven by JIRA tickets, with active + archived ticket scratchpads).

---

## Upgrading an existing project

`bootstrap.sh` is deliberately **write-once** — it won't touch a working folder or auto-memory dir that's already populated. When the kit evolves, existing adopters upgrade manually:

1. Check [`CHANGELOG.md`](CHANGELOG.md) to see what's landed since your bootstrap SHA (or since the last time you upgraded). Each entry has a **For existing adopters** section with specifics.
2. **New files in `templates/`** — copy into your working folder manually:
   ```bash
   cp <kit-dir>/templates/<NEW_FILE>.md <working-folder>/
   ```
3. **New files in `memory-templates/`** — easiest path is the sync helper, which copies any missing templates into your auto-memory without overwriting existing files:
   ```bash
   <kit-dir>/scripts/sync-memory.sh ~/.claude/projects/<sanitized-path>/memory
   ```
   Pass `--dry-run` first to preview. The helper skips `MEMORY.md`, `project_current.md`, and `user_role.md` (user-curated) and prints suggested `MEMORY.md` index lines for the new entries — paste the ones you want into your `MEMORY.md` by hand. To copy a single template by hand instead:
   ```bash
   cp <kit-dir>/memory-templates/<NEW_FILE>.md ~/.claude/projects/<sanitized-path>/memory/
   ```
4. **New files in `templates/.claude/`** — easiest path is to re-run the install helper, which adds any missing commands or agents without overwriting existing files:
   ```bash
   <kit-dir>/scripts/install-commands.sh --global   # or --project <repo-path>
   ```
   To copy a single file by hand instead:
   ```bash
   cp <kit-dir>/templates/.claude/<commands_or_agents>/<NEW_FILE>.md ~/.claude/<commands_or_agents>/
   ```
5. **Changed prose in kit-level files** (e.g. `CONVENTIONS.md`, `SETUP.md`, `README.md`) — re-read them. Your local copies of working-folder templates and memory files are yours; they don't auto-upgrade.
6. **New `bootstrap.sh` flags or behavior** — apply only to *new* projects you bootstrap going forward. Already-bootstrapped projects keep their current state.
7. **Don't re-run `bootstrap.sh`** on a populated working folder — it errors by design. If you really need to re-seed, clear the auto-memory dir manually and pass `--force` to the working folder, but you'll lose local customizations.

If a future change is *not* backwards-compatible (rare for a docs-only kit — only likely if a template structure fundamentally changes), the CHANGELOG entry will call that out explicitly.

---

## Workspace mode (multi-repo initiatives)

> **Run `bootstrap.sh --workspace` once from EACH repo's root.** Both the per-repo subfolder and auto-memory are keyed to each repo's path (auto-memory at `~/.claude/projects/<sanitized-repo-path>/memory/`), so every repo participating in the workspace needs its own bootstrap. The first run creates the workspace folder + `workspace-CONTEXT.md`; subsequent runs add new per-repo subfolders without recreating workspace-level files. Skip this step on a sibling repo and `/session-start` will fail there — the repo won't have `reference_ai_working_folder.md` in auto-memory.

When a single piece of work spans multiple repos (e.g. Terraform environment definitions in one repo and modules in another), use `--workspace` so bootstrap creates a workspace folder above per-repo subfolders. The model is documented in [ADR-0001](docs/adr/0001-multi-repo-folder-model.md); summary:

```
~/<projects-root>/<workspace-name>/
├── workspace-CONTEXT.md      ← cross-repo overview + current initiative
├── workspace-plan.md         ← initiative list (current, planned, completed)
├── tickets/                  ← per-ticket scratchpads
│   ├── <KEY>-<slug>.md
│   └── archive/
├── <repo-a>/                 ← per-repo subfolder (today's working-folder shape)
│   ├── CONTEXT.md, SESSION-LOG.md, plan.md, ...
└── <repo-b>/
    └── ...
```

### Single-initiative vs. long-running workspaces

Workspace mode supports two patterns at the same layout — pick the framing that matches your work:

- **Single-initiative workspace** — the workspace exists for one piece of work spanning multiple repos (e.g. "ship LX-1234 across envs + modules"). Once that work ships, the workspace's lifecycle ends. Use this for short-lived, scoped multi-repo changes.
- **Long-running multi-initiative workspace** — the workspace is a persistent program (e.g. "fdx-infrastructure", "platform observability"), hosting a sequence of initiatives over months or years. The active initiative changes over time; past initiatives are chronicled in `workspace-CONTEXT.md`'s "Past initiatives" section and `workspace-plan.md`'s "Completed initiatives" section.

The templates support both. For single-initiative use, fill in "Current Initiative" once and leave "Past initiatives" empty. For long-running use, update "Current Initiative" each time the active piece of work changes; old entries roll into "Past initiatives". `workspace-plan.md` mirrors per-repo `plan.md` at workspace scope — it's where initiative scope notes, planned-but-not-started work, and completed-initiative chronicles live.

If a workspace's purpose drifts substantially (e.g. an "fdx-infrastructure" workspace that started for Terraform now becoming a general program), consider whether the right move is a new workspace rather than retrofitting the old one.

### First repo in a new workspace

```bash
cd <repo-a>
<framework-dir>/bootstrap.sh --workspace ~/Documents/Claude/Projects/<initiative>/ \
  --tracker jira --jira-project <KEY> --ci <TOOL>
```

Bootstrap creates `<initiative>/`, drops `workspace-CONTEXT.md` and `tickets/archive/` at the workspace root, and creates `<initiative>/<repo-a>/` populated with the standard per-repo templates. Auto-memory still keys to the repo (`~/.claude/projects/<sanitized-repo-path>/memory/`) — workspace mode doesn't change memory pathing.

### Adding more repos to an existing workspace

```bash
cd <repo-b>
<framework-dir>/bootstrap.sh --workspace ~/Documents/Claude/Projects/<initiative>/
```

Bootstrap detects the existing workspace (via the presence of `workspace-CONTEXT.md`), preserves it, and adds `<initiative>/<repo-b>/` as a new per-repo subfolder. Repeat for each repo in the initiative.

### Pulling a ticket into the workspace

Once a workspace is set up with tracker config (`--tracker jira --jira-project LX`), the `/pull-ticket <KEY>` slash command (in `templates/.claude/commands/`) or the `pull-ticket.sh <KEY>` helper script at the kit root fetch ticket data from the configured tracker and seed `tickets/<KEY>-<slug>.md`. Read-only against the tracker — fetches summary / AC / status; never creates, edits, transitions, or comments.

```bash
# In Claude:  /pull-ticket LX-1234
# In a terminal:
~/Code/claude-project-kit/pull-ticket.sh LX-1234
```

Idempotence: both refuse to overwrite an existing scratchpad with the same `<KEY>-` prefix (active or archived). Re-pull by removing or archiving the old file first, or do it from Claude (the slash command can re-pull if you confirm).

### Renaming a workspace

A naive `mv` of the workspace folder works for the directory tree, but **leaves stale references** in per-repo auto-memory at `~/.claude/projects/<sanitized-repo-path>/memory/reference_ai_working_folder.md` (which pins the workspace path baked in at bootstrap time). Use the rename helper instead:

```bash
<framework-dir>/scripts/rename-workspace.sh \
  ~/Documents/Claude/Projects/<old-name>/ \
  ~/Documents/Claude/Projects/<new-name>/
```

The helper:

1. `mv`s the workspace directory.
2. Rewrites every auto-memory file across `~/.claude/projects/*/memory/*.md` that referenced the old path.
3. Backs each rewritten memory file up to `<file>.bak.<timestamp>` first.
4. Reports any old-path references **inside** the workspace tree (in `workspace-CONTEXT.md`, per-repo `CONTEXT.md`, etc.) — these are NOT auto-rewritten because prose may legitimately reference history. Review and edit by hand if appropriate.

Pass `--dry-run` to preview before committing:

```bash
<framework-dir>/scripts/rename-workspace.sh --dry-run \
  ~/Documents/Claude/Projects/<old-name>/ \
  ~/Documents/Claude/Projects/<new-name>/
```

### What `--workspace` does NOT do (yet)

- **Interactive workspace prompt** — `--workspace` requires the explicit flag. Interactive mode still defaults to single-repo. Use the flag-based form above for workspace bootstraps.

(Tracker config substitution into `CONTEXT.md` / `workspace-CONTEXT.md` and the Terraform sibling-repo prompt landed in v0.17.0. The interactive workspace prompt is the only remaining `--workspace` polish item.)

---

## Upgrading a single-repo working folder to a workspace

If you bootstrapped a single-repo working folder (the default shape) and later realize the work is going to span multiple repos, you can convert that folder into a workspace by hand. Both shapes coexist — there's no requirement to migrate.

Target shape per [ADR-0001](docs/adr/0001-multi-repo-folder-model.md):

```
~/<projects-root>/<initiative>/                ← was: ~/<projects-root>/<repo-a>/
├── workspace-CONTEXT.md                       ← new file
├── tickets/                                   ← new directory
│   └── archive/
└── <repo-a>/                                  ← your existing files move here
    ├── CONTEXT.md
    ├── SESSION-LOG.md
    ├── plan.md
    └── ...
```

### Steps

```bash
INITIATIVE=<initiative-name>                   # e.g. lx-platform
PROJECTS_ROOT=~/Documents/Claude/Projects      # wherever you keep working folders
REPO_A=<existing-folder-name>                  # the working folder you're upgrading

# 1. Rename the existing folder to act as the workspace
mv "$PROJECTS_ROOT/$REPO_A" "$PROJECTS_ROOT/$INITIATIVE"

# 2. Create the per-repo subfolder and move per-repo docs into it
cd "$PROJECTS_ROOT/$INITIATIVE"
mkdir "$REPO_A"
mv CONTEXT.md SESSION-LOG.md plan.md implementation.md research.md \
   acceptance-test-results*.md phase-*.md SEED-PROMPT.md \
   ".claude" "$REPO_A/" 2>/dev/null || true

# 3. Create the workspace-level scaffolding
touch workspace-CONTEXT.md
mkdir -p tickets/archive
```

### Edits required after the move

- **`workspace-CONTEXT.md`** — fill in the cross-repo overview: what initiative this is, why it exists, which repos belong to it. Link each repo's subfolder. Use [`templates/workspace/workspace-CONTEXT.md`](templates/workspace/workspace-CONTEXT.md) in the kit as a starting template.
- **`<repo-a>/CONTEXT.md`** — under "How to load this context," update the path: was `<initiative>/CONTEXT.md`, now `<initiative>/<repo-a>/CONTEXT.md`.
- **Auto-memory** (`~/.claude/projects/<sanitized-path>/memory/reference_ai_working_folder.md`) — update the working-folder path so Claude knows to read from `<initiative>/<repo-a>/` instead of the old single-repo location.

### Adding more repos

Once the workspace exists, additional repos bootstrap into it via `--workspace` (see [Workspace mode](#workspace-mode-multi-repo-initiatives) above).

---

## Troubleshooting

**Claude doesn't read the working folder automatically.** It has to be told each session. Either say it explicitly ("Read CONTEXT.md and SESSION-LOG.md…") or rely on the `reference_ai_working_folder.md` memory entry to remind it.

**Auto-memory path looks wrong.** If you can't find `~/.claude/projects/<sanitized-path>/memory/`, just launch `claude` once in the repo — the harness creates it. Then `ls ~/.claude/projects/` and find yours by mtime.

**Templates feel like too much structure for a small project.** You don't need all of them. Bare minimum for a weekend project: `CONTEXT.md` + `SESSION-LOG.md`. Add the rest when scope warrants.
