# Common setup/teardown and helper functions for bootstrap.sh bats tests.
#
# Each test file `load 'helpers'` and then calls `bootstrap_setup` /
# `bootstrap_teardown` in its own `setup` / `teardown` hooks.

KIT_ROOT="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
BOOTSTRAP="$KIT_ROOT/bootstrap.sh"

# Create an isolated sandbox per test:
#   TEST_TMP    — temp root (deleted in teardown)
#   TEST_HOME   — sandboxed $HOME so ~/.claude/projects/... writes don't escape
#   TEST_REPO   — a fake target repo with `git init` and an origin remote
#   TEST_WF     — the working-folder path that bootstrap should create
#
# After this runs, `cd` is the test repo.
bootstrap_setup() {
  TEST_TMP="$(mktemp -d)"
  TEST_HOME="$TEST_TMP/home"
  TEST_REPO="$TEST_TMP/repo"
  TEST_WF="$TEST_TMP/wf"
  mkdir -p "$TEST_HOME" "$TEST_REPO"
  git -C "$TEST_REPO" init -q
  git -C "$TEST_REPO" remote add origin "https://github.com/example/test-repo.git"
  export HOME="$TEST_HOME"
  cd "$TEST_REPO"
}

bootstrap_teardown() {
  [ -n "${TEST_TMP:-}" ] && rm -rf "$TEST_TMP"
}

# Echo the auto-memory path bootstrap will derive for the current TEST_REPO.
memory_dir() {
  local sanitized
  sanitized="$(echo "$TEST_REPO" | sed 's|/|-|g')"
  echo "$TEST_HOME/.claude/projects/${sanitized}/memory"
}

# Create a new fake repo WITHOUT a git remote — useful for testing REPO_SLUG
# graceful-fallback behavior.
setup_repo_without_remote() {
  rm -rf "$TEST_REPO/.git"
  git -C "$TEST_REPO" init -q
}
