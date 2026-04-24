# Changelog

All notable changes to `claude-project-kit`. Format loosely follows [Keep a Changelog](https://keepachangelog.com/). Tagged releases are published on [GitHub Releases](https://github.com/IamMrCupp/claude-project-kit/releases); entries below include version tags where applicable.

See [Upgrading an existing project](SETUP.md#upgrading-an-existing-project) for the general migration pattern. Each entry below has a **For existing adopters** section with specifics for that release.

---

## 2026-04-23 — End-of-session prompt and `--dry-run`

**Tag:** [v0.6.0](https://github.com/IamMrCupp/claude-project-kit/releases/tag/v0.6.0)

### Added
- `PROMPTS.md` — new **Prompt 3: Wrapping up a session**. Scaffolds the end-of-session hygiene from SETUP.md §7: drafts a `SESSION-LOG.md` entry, suggests `CONTEXT.md` status-line updates, flags checklist items missing PR numbers, and surfaces memory candidates — all in draft form, waiting on confirmation before writing. ([#17](https://github.com/IamMrCupp/claude-project-kit/pull/17))
- `bootstrap.sh --dry-run` — preview every action (paths, placeholder substitutions, tracker memory copy, MEMORY.md index append) and exit without writing anything. Safe to re-run. ([#17](https://github.com/IamMrCupp/claude-project-kit/pull/17))
- `SETUP.md §7` — pointer to Prompt 3 for users who want a scaffolded wrap-up rather than doing the checklist by hand. ([#17](https://github.com/IamMrCupp/claude-project-kit/pull/17))

### For existing adopters
- No breaking changes. `--dry-run` is opt-in; existing invocations behave identically.
- To use Prompt 3, pull the updated `PROMPTS.md` from the kit — the prompt is self-contained and doesn't require any memory or template changes in your project.

---

## 2026-04-23 — More tracker variants

**Tag:** [v0.5.0](https://github.com/IamMrCupp/claude-project-kit/releases/tag/v0.5.0)

### Added
- `memory-templates/trackers/linear.md`, `gitlab.md`, `shortcut.md` — three new reference-memory variants. Complements the existing `github.md` / `jira.md` / `other.md`. ([#16](https://github.com/IamMrCupp/claude-project-kit/pull/16))
- `bootstrap.sh` — `--tracker` now accepts `linear`, `gitlab`, `shortcut` in addition to the existing values. ([#16](https://github.com/IamMrCupp/claude-project-kit/pull/16))
- `bootstrap.sh` — new `--linear-team KEY` flag (analogous to `--jira-project`). Implies `--tracker linear`. Required in non-interactive mode when tracker is Linear. ([#16](https://github.com/IamMrCupp/claude-project-kit/pull/16))
- Interactive mode now lists all seven tracker options and prompts for the team key when Linear is selected. ([#16](https://github.com/IamMrCupp/claude-project-kit/pull/16))

### For existing adopters
- No breaking changes. Existing `--tracker github` / `--tracker jira` invocations behave identically.
- To add tracker awareness to an already-bootstrapped project using one of the new trackers, copy `memory-templates/trackers/<TYPE>.md` from the kit into your project's auto-memory folder as `reference_issue_tracker.md` and fill in placeholders by hand.

---

## 2026-04-23 — Issue tracker awareness

**Tag:** [v0.4.0](https://github.com/IamMrCupp/claude-project-kit/releases/tag/v0.4.0)

### Added
- `bootstrap.sh` — new `--tracker TYPE` (`github` | `jira` | `other` | `none`) and `--jira-project KEY` flags. In interactive mode, bootstrap prompts for tracker type (default: `github`) and, when `jira` is selected, the JIRA project key. Non-interactive invocations without either flag behave as before — no tracker file seeded. ([#15](https://github.com/IamMrCupp/claude-project-kit/pull/15))
- `memory-templates/trackers/` — three reference memory variants (`github.md`, `jira.md`, `other.md`). Bootstrap copies the selected variant into the project's auto-memory as `reference_issue_tracker.md`, substitutes `{{JIRA_PROJECT_KEY}}` when applicable, and appends an index line to `MEMORY.md`. ([#15](https://github.com/IamMrCupp/claude-project-kit/pull/15))

### For existing adopters
- No breaking changes. Non-interactive invocations without the new flags behave identically — no tracker file is seeded, no existing memory file is touched.
- To add tracker awareness to an already-bootstrapped project: copy the appropriate `memory-templates/trackers/<TYPE>.md` from the kit into your project's auto-memory folder as `reference_issue_tracker.md`, fill in `{{JIRA_PROJECT_KEY}}` / `{{PROJECT_NAME}}` / `{{REPO_SLUG}}` by hand, and add a line referencing it in your `MEMORY.md`.

---

## 2026-04-22 — Phase 2: zero manual-fill onboarding

**Tag:** [v0.2.0](https://github.com/IamMrCupp/claude-project-kit/releases/tag/v0.2.0)

### Added
- `templates/SEED-PROMPT.md` — one-shot project bootstrap instruction prompt. Claude deep-reads the target repo, classifies `CONTEXT.md` fields into derivable / `[CLAUDE-INFERRED]` / `[HUMAN-CONFIRM]` buckets, drafts `research.md` from code, summarizes, asks ≤5 targeted questions, and stops for user review. ([#7](https://github.com/IamMrCupp/claude-project-kit/pull/7))
- `bootstrap.sh` — auto-substitutes four memory-template placeholders post-copy: `{{WORKING_FOLDER}}`, `{{REPO_PATH}}`, `{{PROJECT_NAME}}` (default = basename of working folder), `{{REPO_SLUG}}` (opportunistic from `git remote get-url origin`, graceful fallback if no remote). ([#8](https://github.com/IamMrCupp/claude-project-kit/pull/8))
- `bootstrap.sh` — new `--project-name NAME` flag to override the auto-derived project name. ([#8](https://github.com/IamMrCupp/claude-project-kit/pull/8))

### Changed
- `bootstrap.sh` next-steps message leads with the seed-prompt invocation line (working-folder path pre-substituted). ([#7](https://github.com/IamMrCupp/claude-project-kit/pull/7))
- `README.md` + `SETUP.md` — onboarding flow rewritten around the seed-prompt; manual placeholder fill-in demoted to the `Manual alternative` appendix. SETUP.md §4 reframed around memory auto-fill. ([#7](https://github.com/IamMrCupp/claude-project-kit/pull/7), [#8](https://github.com/IamMrCupp/claude-project-kit/pull/8))

### For existing adopters
- **To use the seed-prompt flow:** copy `templates/SEED-PROMPT.md` into your existing working folder:
  ```bash
  cp <kit-dir>/templates/SEED-PROMPT.md <your-working-folder>/
  ```
- **Stale placeholders won't auto-upgrade.** If your `reference_ai_working_folder.md` in auto-memory still has `{{PROJECT_NAME}}` / `{{WORKING_FOLDER}}` / `{{REPO_PATH}}` / `{{REPO_SLUG}}` placeholders from a pre-#8 bootstrap, fill them manually once — future bootstraps on *new* projects will auto-fill them.
- The `--project-name` flag is opt-in and only affects new bootstraps; existing projects' behavior is unchanged.

---

## 2026-04-22 — CONVENTIONS: human-only commit attribution

*Included in [v0.2.0](https://github.com/IamMrCupp/claude-project-kit/releases/tag/v0.2.0).*

### Added
- `CONVENTIONS.md` — explicit rule forbidding AI co-author trailers on commits (complements the existing "single line, signed off, no body" rule). ([#6](https://github.com/IamMrCupp/claude-project-kit/pull/6))
- `memory-templates/feedback_no_ai_coauthor.md` — starter auto-memory file so new projects inherit the rule pre-seeded. ([#6](https://github.com/IamMrCupp/claude-project-kit/pull/6))

### For existing adopters
- Going forward, commit with `git commit -s -m "type(scope): description"` — single line, no HEREDOC body, no `Co-Authored-By` trailer.
- Optionally copy `memory-templates/feedback_no_ai_coauthor.md` into your project's auto-memory to bind the rule at the memory layer.
- **Do not rewrite already-merged history** to remove past trailers — destructive and visible to anyone with a clone.

---

## 2026-04-22 — Phase 1: polish + dogfood fixes

**Tag:** [v0.1.0](https://github.com/IamMrCupp/claude-project-kit/releases/tag/v0.1.0)

### Added
- `bootstrap.sh` — one-command onboarding helper. Creates the working folder, seeds auto-memory, prints next-steps. Flags: `--skip-memory`, `--force`, `-h`/`--help`. ([#2](https://github.com/IamMrCupp/claude-project-kit/pull/2))
- `examples/widget-tracker/` — filled-in reference project (fictional Go CLI, mid-Phase-1 snapshot) with `CONTEXT.md`, `plan.md`, `phase-1-checklist.md`, `SESSION-LOG.md`. ([#3](https://github.com/IamMrCupp/claude-project-kit/pull/3))
- `examples/README.md` — framing doc explaining the "read, don't copy" distinction between `templates/` and `examples/`. ([#3](https://github.com/IamMrCupp/claude-project-kit/pull/3))

### Fixed
- `README.md` memory-templates file list drift — replaced hard-coded `*_example.md` names with pattern-based listing that stays accurate as the starter set grows. ([#1](https://github.com/IamMrCupp/claude-project-kit/pull/1))
- `{{PLATFORM_TARGETS}}` placeholder added to `templates/CONTEXT.md` — was referenced in `SETUP.md` but didn't exist in the template. ([#1](https://github.com/IamMrCupp/claude-project-kit/pull/1))
- `{{REPO_URL}}` listed in `SETUP.md` step 3 fill-in — was in the template but missing from the fill-in instructions. ([#4](https://github.com/IamMrCupp/claude-project-kit/pull/4))
- `SETUP.md` + `README.md` — clarified that the kit works for existing repos, not just greenfield. ([#5](https://github.com/IamMrCupp/claude-project-kit/pull/5))

### For existing adopters
- Copy `bootstrap.sh` from the new kit checkout if you want the scripted flow — your existing manual-setup still works.
- New memory-templates files — copy any that apply into your project's auto-memory.
- Re-read `SETUP.md`: numbering and content shifted (manual alternative is now an appendix; `bootstrap.sh` is the primary flow).

---

## Initial — 2026-04-21 (`13fd99d`)

First commit. Seeded the kit with:

- `README.md`, `SETUP.md`, `CONVENTIONS.md`, `PROMPTS.md`, `LICENSE`
- `templates/` — `CONTEXT.md`, `SESSION-LOG.md`, `plan.md`, `implementation.md`, `phase-N-checklist.md`, `acceptance-test-results.md`, `research.md`
- `memory-templates/` — `MEMORY.md`, `user_role.md`, feedback starters (commit format, docs in sync, merge strategy, PR test plans, PR check-off, push branches, watch CI in background), `project_current.md`, `reference_ai_working_folder.md`
