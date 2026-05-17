#!/usr/bin/env bats
# Behavioral check — the worktree-aware precheck must resolve to the parent
# repo's auto-memory path regardless of whether the session is running in
# the main worktree, a linked worktree under <repo>/.claude/worktrees/, or
# a linked worktree elsewhere on disk. Closes #210.
#
# As of #218 the precheck logic lives in scripts/kit-print-memory-pointer.sh
# (extracted from the inline compound Bash so Claude Code's permission
# matcher can allowlist the invocation). This test runs the script directly
# against real `git worktree add`-created worktrees so the worktree-aware
# behavior stays locked in regardless of where the logic lives.

load 'helpers'

setup() {
  # macOS resolves /var/folders/... -> /private/var/folders/... via symlink.
  # `git rev-parse` returns the resolved path, so we need TEST_TMP to be the
  # resolved form for string comparisons to work.
  TEST_TMP="$(cd "$(mktemp -d)" && pwd -P)"
  TEST_HOME="$TEST_TMP/home"
  PARENT_REPO="$TEST_TMP/parent-repo"
  mkdir -p "$TEST_HOME" "$PARENT_REPO"
  export HOME="$TEST_HOME"

  git -C "$PARENT_REPO" init -q
  git -C "$PARENT_REPO" -c user.email=t@t.t -c user.name=t commit \
    --allow-empty -m "init" -q
}

teardown() {
  [ -n "${TEST_TMP:-}" ] && rm -rf "$TEST_TMP"
}

# Run the precheck script from inside $1 and echo its stdout. The script
# IS what every kit-coupled slash command invokes — no inline duplication.
run_precheck_in() {
  local cwd="$1"
  ( cd "$cwd" && "$KIT_ROOT/scripts/kit-print-memory-pointer.sh" )
}

@test "precheck inside the main worktree resolves to the parent repo's memory path" {
  expected="$HOME/.claude/projects/$(echo "$PARENT_REPO" | sed 's|[/.]|-|g')/memory/reference_ai_working_folder.md"
  run run_precheck_in "$PARENT_REPO"
  [ "$status" -eq 0 ]
  [ "$output" = "$expected" ]
}

@test "precheck inside a nested .claude/worktrees/ worktree resolves to the parent repo's memory path" {
  # Worktree under <parent>/.claude/worktrees/<name> — the kit's own chip
  # mechanism creates worktrees here.
  WT="$PARENT_REPO/.claude/worktrees/feature-x"
  mkdir -p "$(dirname "$WT")"
  git -C "$PARENT_REPO" worktree add -q "$WT" 2>/dev/null

  expected="$HOME/.claude/projects/$(echo "$PARENT_REPO" | sed 's|[/.]|-|g')/memory/reference_ai_working_folder.md"
  run run_precheck_in "$WT"
  [ "$status" -eq 0 ]
  [ "$output" = "$expected" ]
}

@test "precheck inside a worktree elsewhere on disk resolves to the parent repo's memory path" {
  # Worktree at an arbitrary location, not nested under the parent repo.
  WT="$TEST_TMP/detached-worktree"
  git -C "$PARENT_REPO" worktree add -q "$WT" 2>/dev/null

  expected="$HOME/.claude/projects/$(echo "$PARENT_REPO" | sed 's|[/.]|-|g')/memory/reference_ai_working_folder.md"
  run run_precheck_in "$WT"
  [ "$status" -eq 0 ]
  [ "$output" = "$expected" ]
}

@test "precheck outside any git repo falls back to PWD" {
  # No git repo — should sanitize PWD itself.
  NON_GIT="$TEST_TMP/not-a-repo"
  mkdir -p "$NON_GIT"

  expected="$HOME/.claude/projects/$(echo "$NON_GIT" | sed 's|[/.]|-|g')/memory/reference_ai_working_folder.md"
  run run_precheck_in "$NON_GIT"
  [ "$status" -eq 0 ]
  [ "$output" = "$expected" ]
}

@test "precheck handles dotted username + worktree (combined #205 + #210 case)" {
  # Real-world case that surfaced #210: Aaron's `aaron.cupp` work account
  # plus a chip-spawned worktree. The dot in the username must still be
  # sanitized (#205), and the worktree must still walk up (#210).
  DOTTED="$TEST_TMP/Users/aaron.cupp/Code/myrepo"
  mkdir -p "$DOTTED"
  git -C "$DOTTED" init -q
  git -C "$DOTTED" -c user.email=t@t.t -c user.name=t commit \
    --allow-empty -m "init" -q

  WT="$DOTTED/.claude/worktrees/feature-y"
  mkdir -p "$(dirname "$WT")"
  git -C "$DOTTED" worktree add -q "$WT" 2>/dev/null

  expected="$HOME/.claude/projects/$(echo "$DOTTED" | sed 's|[/.]|-|g')/memory/reference_ai_working_folder.md"
  run run_precheck_in "$WT"
  [ "$status" -eq 0 ]
  [ "$output" = "$expected" ]
  # Sanity check: the resolved path must NOT contain the worktree subdir name
  # (i.e. the precheck successfully walked up before sanitizing).
  [[ "$output" != *"feature-y"* ]]
  # And the dot in `aaron.cupp` must have become a `-`.
  [[ "$output" == *"aaron-cupp"* ]]
  [[ "$output" != *"aaron.cupp"* ]]
}
