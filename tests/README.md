# Tests

Two suites cover `bootstrap.sh`:

- **Bats** — non-interactive paths (flags, memory seeding, tracker / CI variants, dry-run).
- **Expect** — interactive-mode paths (`read -p` prompts) that bats can't drive.

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

| File | Covers |
|---|---|
| `bootstrap_args.bats` | flag parsing, `--help`, unknown flags, missing values, validation (tracker/CI enums, absolute-path requirement, non-TTY missing-arg) |
| `bootstrap_memory.bats` | template copy, `phase-N → phase-0` rename, memory seeding, `--skip-memory`, placeholder substitution (`{{PROJECT_NAME}}`, `{{WORKING_FOLDER}}`, `{{REPO_PATH}}`, `{{REPO_SLUG}}`), `--force`, existing-memory safety, tilde expansion |
| `bootstrap_tracker.bats` | every `--tracker` variant (github/jira/linear/gitlab/shortcut/other/none), `{{JIRA_PROJECT_KEY}}` + `{{LINEAR_TEAM_KEY}}` substitution, `MEMORY.md` index append |
| `bootstrap_ci.bats` | every `--ci` variant (github-actions/gitlab-ci/jenkins/circleci/atlantis/ansible-cli/other/none), `MEMORY.md` index append, combined `--tracker` + `--ci` |
| `bootstrap_dry_run.bats` | `--dry-run` plan printout, no-side-effect guarantees, non-empty-folder warnings, `--skip-memory` interaction |
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

1. Pick the file that matches the code path you're touching (or add a new `bootstrap_<topic>.bats`).
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
