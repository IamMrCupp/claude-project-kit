#!/usr/bin/env bats
# scripts/kit-print-memory-pointer.sh — emits the absolute path of the
# current project's auto-memory pointer file (reference_ai_working_folder.md).
#
# The worktree-aware behavior is covered end-to-end by precheck_worktree_handling.bats
# (which runs the script through real `git worktree add`-created worktrees).
# This file covers the unit-level invariants that belong to the script
# itself: clean stdout shape, exit code, no stderr noise on the happy path,
# proper $HOME respect, and a stable single-line output contract.

load 'helpers'

SCRIPT="$KIT_ROOT/scripts/kit-print-memory-pointer.sh"

setup() {
  TEST_TMP="$(cd "$(mktemp -d)" && pwd -P)"
  TEST_HOME="$TEST_TMP/home"
  TEST_REPO="$TEST_TMP/repo"
  mkdir -p "$TEST_HOME" "$TEST_REPO"
  export HOME="$TEST_HOME"
  git -C "$TEST_REPO" init -q
  git -C "$TEST_REPO" -c user.email=t@t.t -c user.name=t commit --allow-empty -m init -q
}

teardown() {
  [ -n "${TEST_TMP:-}" ] && rm -rf "$TEST_TMP"
}

@test "script is executable" {
  [ -x "$SCRIPT" ]
}

@test "script emits exactly one line to stdout" {
  cd "$TEST_REPO"
  run "$SCRIPT"
  [ "$status" -eq 0 ]
  [ "$(echo "$output" | wc -l | tr -d ' ')" = "1" ]
}

@test "script output ends with reference_ai_working_folder.md" {
  cd "$TEST_REPO"
  run "$SCRIPT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"/memory/reference_ai_working_folder.md" ]]
}

@test "script output begins with \$HOME (absolute path, no tilde)" {
  cd "$TEST_REPO"
  run "$SCRIPT"
  [ "$status" -eq 0 ]
  [[ "$output" == "$TEST_HOME"/* ]]
  # Explicitly NOT tilde — the Read tool doesn't expand it.
  [[ "$output" != "~"* ]]
}

@test "script output includes sanitized repo path as the project key" {
  cd "$TEST_REPO"
  run "$SCRIPT"
  [ "$status" -eq 0 ]
  # Resolve symlinks in TEST_REPO the way git rev-parse does
  RESOLVED_REPO="$(cd "$TEST_REPO" && pwd -P)"
  EXPECTED_KEY="$(echo "$RESOLVED_REPO" | sed 's|[/.]|-|g')"
  [[ "$output" == *"/.claude/projects/$EXPECTED_KEY/memory/"* ]]
}

@test "script writes nothing to stderr on the happy path" {
  cd "$TEST_REPO"
  STDERR=$("$SCRIPT" 2>&1 1>/dev/null)
  [ -z "$STDERR" ]
}

@test "script silences git's not-a-repo error when run outside a git repo" {
  NON_GIT="$TEST_TMP/not-a-repo"
  mkdir -p "$NON_GIT"
  cd "$NON_GIT"
  # No "fatal: not a git repository" leakage on stderr.
  STDERR=$("$SCRIPT" 2>&1 1>/dev/null)
  [ -z "$STDERR" ]
}

@test "script exit code is 0 outside a git repo (falls back to PWD)" {
  NON_GIT="$TEST_TMP/not-a-repo"
  mkdir -p "$NON_GIT"
  cd "$NON_GIT"
  run "$SCRIPT"
  [ "$status" -eq 0 ]
  EXPECTED_KEY="$(echo "$NON_GIT" | sed 's|[/.]|-|g')"
  [[ "$output" == *"/.claude/projects/$EXPECTED_KEY/memory/reference_ai_working_folder.md" ]]
}
