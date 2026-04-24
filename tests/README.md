# Tests

[Bats](https://bats-core.readthedocs.io/) test suite for `bootstrap.sh`.

## Running locally

Install bats:
```bash
# macOS
brew install bats-core

# Debian/Ubuntu
sudo apt-get install bats

# Or vendored — see https://bats-core.readthedocs.io/en/stable/installation.html
```

Run the full suite from the kit root:
```bash
bats tests/
```

Run a single file:
```bash
bats tests/bootstrap_args.bats
```

Run a single test by name (substring match):
```bash
bats tests/ -f "tilde"
```

## Test layout

| File | Covers |
|---|---|
| `bootstrap_args.bats` | flag parsing, `--help`, unknown flags, missing values, validation (tracker/CI enums, absolute-path requirement, non-TTY missing-arg) |
| `bootstrap_memory.bats` | template copy, `phase-N → phase-0` rename, memory seeding, `--skip-memory`, placeholder substitution (`{{PROJECT_NAME}}`, `{{WORKING_FOLDER}}`, `{{REPO_PATH}}`, `{{REPO_SLUG}}`), `--force`, existing-memory safety, tilde expansion |
| `bootstrap_tracker.bats` | every `--tracker` variant (github/jira/linear/gitlab/shortcut/other/none), `{{JIRA_PROJECT_KEY}}` + `{{LINEAR_TEAM_KEY}}` substitution, `MEMORY.md` index append |
| `bootstrap_ci.bats` | every `--ci` variant (github-actions/gitlab-ci/jenkins/circleci/atlantis/ansible-cli/other/none), `MEMORY.md` index append, combined `--tracker` + `--ci` |
| `bootstrap_dry_run.bats` | `--dry-run` plan printout, no-side-effect guarantees, non-empty-folder warnings, `--skip-memory` interaction |

## What's NOT tested

- **Interactive mode** (the `read -p` prompts). Bats runs non-interactively (`[ -t 0 ]` is false), so interactive-mode paths aren't exercised. Manual-test interactive mode when touching those branches. The non-interactive mode error path (missing arg in non-TTY → exit 2) IS tested.
- **Visual / UX details** of printed output beyond specific substrings the tests assert on.

## Test isolation

Each test runs in a sandboxed temp directory:
- `HOME` is overridden to a per-test tempdir, so `~/.claude/projects/...` writes don't touch real auto-memory.
- A fresh `git init` repo is created per test as the target.
- `teardown()` deletes the temp dir.

See `tests/helpers.bash` for the setup/teardown mechanics.

## Adding a test

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
4. Commit — CI will run the full suite on PR.
