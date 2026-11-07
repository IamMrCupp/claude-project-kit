# Tests

Two suites cover `bootstrap.sh`, the helper scripts, the hooks, the slash commands, and the templates:

- **Bats** — everything non-interactive (flags, memory seeding, tracker / CI variants, dry-run, scripts, hooks, template content).
- **Expect** — `bootstrap.sh`'s interactive-mode paths (`read -p` prompts) that bats can't drive.

## Running locally

### Bats suite

Install [bats](https://bats-core.readthedocs.io/):
```bash
# macOS
brew install bats-core

# Debian/Ubuntu
sudo apt-get install bats
```

Run from the kit root:
```bash
bats tests/                          # full suite
bats tests/bootstrap_args.bats       # one file
bats tests/ -f "tilde"               # by name (substring match)
```

### Expect suite (interactive mode)

Install `expect`:
```bash
# macOS
brew install expect

# Debian/Ubuntu
sudo apt-get install -y expect
```

Run from the kit root:
```bash
tests/interactive/run.sh                          # all interactive tests
tests/interactive/run.sh 02-tracker-jira.exp      # one file
```

Each test runs in its own sandbox (`HOME` override + fresh fake repo), same isolation pattern as the bats helpers.

## Test layout

Every `.bats` file under `tests/` and every `.exp` under `tests/interactive/` appears below — `memory_example_in_sync.bats` fails if one is added without a row here (or a row names a file that's gone).

### `bootstrap.sh`

| File | Covers |
|---|---|
| `bootstrap_args.bats` | flag parsing, `--help`, unknown flags, missing values, validation (tracker/CI enums, absolute-path requirement, non-TTY missing-arg) |
| `bootstrap_memory.bats` | template copy, `phase-N → phase-0` rename, memory seeding, `--skip-memory`, placeholder substitution (`{{PROJECT_NAME}}`, `{{WORKING_FOLDER}}`, `{{REPO_PATH}}`, `{{REPO_SLUG}}`), `--force`, existing-memory safety, tilde expansion |
| `bootstrap_tracker.bats` | every `--tracker` variant (github/jira/linear/gitlab/shortcut/other/none), `{{JIRA_PROJECT_KEY}}` + `{{LINEAR_TEAM_KEY}}` substitution, `MEMORY.md` index append |
| `bootstrap_ci.bats` | every `--ci` variant (github-actions/gitlab-ci/jenkins/circleci/atlantis/ansible-cli/other/none), `MEMORY.md` index append, combined `--tracker` + `--ci` |
| `bootstrap_dry_run.bats` | `--dry-run` plan printout, no-side-effect guarantees, non-empty-folder warnings, `--skip-memory` interaction |
| `bootstrap_constraints.bats` | defensive assertions — bootstrap never creates tracker, CI, or remote resources |
| `bootstrap_gitignore.bats` | marker-bracketed managed block in the target repo's `.gitignore`, `--no-gitignore`, idempotent re-runs |
| `bootstrap_labels.bats` | `--with-labels` opt-in triage label scheme |
| `bootstrap_session_log.bats` | factual "Bootstrap" entry appended to the working folder's `SESSION-LOG.md` |
| `bootstrap_shared.bats` | `--shared` / `--reference` flags for repos used by several workspaces |
| `bootstrap_terraform.bats` | Terraform-shape detection and the sibling-repo prompt |
| `bootstrap_trust_kit_paths.bats` | `--trust-kit-paths` (and its deprecated `--trust-working-folder-root` alias) |
| `bootstrap_workspace.bats` | `--workspace` mechanics: workspace folder, per-repo subfolder, workspace templates |

### Helper scripts (`scripts/`)

| File | Covers |
|---|---|
| `archive_ticket.bats` | `archive-ticket.sh` — move a resolved ticket scratchpad into `tickets/archive/` |
| `check_convention_drift.bats` | `check-convention-drift.sh` — `CONTEXT.md` vs auto-memory convention drift |
| `convert_to_shared.bats` | `convert-to-shared.sh` — migrate a per-repo working folder out of a workspace |
| `infer_working_folder.bats` | `lib/infer.sh::infer_working_folder` — read the auto-memory pointer |
| `install_commands.bats` | `install-commands.sh` — install slash commands + agents, `--force-update` |
| `install_scripts.bats` | `install-scripts.sh` — install runtime helper scripts under `~/.claude/scripts/` |
| `print_memory_pointer.bats` | `kit-print-memory-pointer.sh` — absolute path of the auto-memory pointer file |
| `pull_ticket.bats` | `pull-ticket.sh` — pull a tracker ticket into a per-ticket scratchpad |
| `rename_workspace.bats` | `rename-workspace.sh` — rename a workspace folder and fix up its pointers |
| `sanitize_dotted_paths.bats` | auto-memory path sanitization replaces both `/` and `.` |
| `sync_memory.bats` | `sync-memory.sh` — copy missing memory templates, report drift, never overwrite |
| `sync_templates.bats` | `sync-templates.sh` — copy missing working-folder / workspace templates |
| `upgrade.bats` | `upgrade.sh` — the one-command upgrade orchestrator |

### Hooks

| File | Covers |
|---|---|
| `block_edit_on_protected_branch.bats` | `block-edit-on-protected-branch.sh` — PreToolUse Edit/Write hook (branch-first) |
| `commit_format_hook.bats` | `block-forbidden-commit-patterns.sh` — PreToolUse Bash hook (forbidden commit patterns) |

### Slash commands + agents

| File | Covers |
|---|---|
| `dogfood_claude_in_sync.bats` | the kit's own `.claude/commands/` + `.claude/agents/` match `templates/.claude/` |
| `precheck_in_commands.bats` | every kit-coupled slash command and the session-summarizer agent carry the precheck |
| `precheck_worktree_handling.bats` | the precheck resolves worktrees to the parent repo before sanitizing |
| `session_start_shared_repo.bats` | `/session-start` surfaces the shared-repo `## Referenced by` section |
| `run_acceptance.bats` | `/run-acceptance` — AT execution + writeback surface |
| `phase_acceptance_enforcement.bats` | `/close-phase` refuses to close without acceptance-test results |

### Templates + conventions

| File | Covers |
|---|---|
| `convention_single_source.bats` | mutable conventions single-sourced in auto-memory, not restated in `CONTEXT.md` |
| `issue_first_defaults.bats` | issue-first defaults when the user owns the tracker |
| `memory_templates_overrides.bats` | `MEMORY.md` index lines flag harness-default overrides |
| `memory_template_chips.bats` | `feedback_chips_use_the_kit.md` starter; every shipped memory template is indexed |
| `memory_example_in_sync.bats` | the widget-tracker memory example and this table match what the kit ships |

### Interactive (expect)

| File | Covers |
|---|---|
| `interactive/01-default-flow.exp` | accept defaults end-to-end, default github tracker memory seeded |
| `interactive/02-tracker-jira.exp` | jira tracker + JIRA project key prompt |
| `interactive/03-tracker-linear.exp` | linear tracker + Linear team key prompt |
| `interactive/04-ci-variant.exp` | CI prompt; `atlantis` variant memory seeded |
| `interactive/05-proceed-decline.exp` | answer `n` at the final Proceed prompt; abort path; no working folder created |

## What's NOT tested

- **Visual / UX details** of printed output beyond specific substrings the tests assert on.
- **Every combination** of tracker × CI in interactive mode — the bats suite covers the full Cartesian product non-interactively. The expect suite samples each interactive prompt branch once.

## Test isolation

Both suites use the same per-test sandbox pattern:
- `HOME` is overridden to a per-test tempdir, so `~/.claude/projects/...` writes don't touch real auto-memory.
- A fresh `git init` repo is created per test as the target, with a stub `origin` remote.
- The tempdir is deleted on teardown.

For bats, see `tests/helpers.bash`. For expect, see `tests/interactive/run.sh` (sandbox lives in the bash runner) and `tests/interactive/helpers.exp` (sourced by every `.exp`; sets timeout + failure handler).

## Adding a test

### Non-interactive (bats)

1. Pick the file that matches the code path you're touching, or add a new `<topic>.bats` (`bootstrap_<topic>.bats` for bootstrap paths) — and add its row to the table above.
2. Structure:
   ```bash
   @test "one-line description of what's asserted" {
     run "$BOOTSTRAP" <args>
     [ "$status" -eq 0 ]
     [[ "$output" == *"expected substring"* ]]
     [ -f "$TEST_WF/expected-file" ]
   }
   ```
3. Run `bats tests/<file>.bats` to verify.

### Interactive (expect)

1. Add a numbered file under `tests/interactive/` (e.g. `06-skip-memory.exp`). The numeric prefix sets run order.
2. Structure (see existing `*.exp` files for full template):
   ```tcl
   #!/usr/bin/env expect
   source [file dirname [info script]]/helpers.exp

   spawn $::kit_root/bootstrap.sh
   expect "Path";  send -- "$::test_wf\r"
   expect "Project name";  send -- "\r"
   # ... drive remaining prompts ...
   expect "Proceed";  send -- "\r"
   expect "Copied template files"
   expect eof
   catch wait result
   exit [lindex $result 3]
   ```
3. Run `tests/interactive/run.sh 06-skip-memory.exp` to verify.

CI runs both suites on PRs that touch `bootstrap.sh`, `memory-templates/`, `templates/`, or `tests/`.
