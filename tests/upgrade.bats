#!/usr/bin/env bats
# scripts/upgrade.sh — orchestrator that runs the kit upgrade flow end-to-end.
# Calls the existing per-script helpers (sync-memory, sync-templates,
# install-commands) with $PWD-inference. Tests use --skip-pull throughout to
# avoid hitting the real kit checkout's git state.

load 'helpers'

UPGRADE="$KIT_ROOT/scripts/upgrade.sh"

setup() { bootstrap_setup; }
teardown() { bootstrap_teardown; }

@test "upgrade.sh -h prints usage" {
  run "$UPGRADE" -h
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage: upgrade.sh"* ]]
  [[ "$output" == *"--dry-run"* ]]
  [[ "$output" == *"--skip-pull"* ]]
  [[ "$output" == *"--skip-commands"* ]]
}

@test "upgrade.sh errors on unknown flag" {
  run "$UPGRADE" --bogus
  [ "$status" -ne 0 ]
  [[ "$output" == *"unknown option"* ]]
}

@test "upgrade.sh errors on unexpected positional argument" {
  run "$UPGRADE" --skip-pull some-extra-arg
  [ "$status" -ne 0 ]
  [[ "$output" == *"unexpected positional argument"* ]]
}

@test "upgrade.sh errors when not in a kit-bootstrapped repo" {
  # Brand-new dir with no auto-memory
  NON_KIT="$TEST_TMP/random"
  mkdir -p "$NON_KIT"
  cd "$NON_KIT"

  run "$UPGRADE" --skip-pull
  [ "$status" -ne 0 ]
  [[ "$output" == *"not inside a kit-bootstrapped repo"* ]]
  [[ "$output" == *"cd into a kit-bootstrapped repo"* ]]
}

@test "upgrade.sh --dry-run prints plan and writes nothing" {
  # Bootstrap the test repo so auto-memory exists
  run "$BOOTSTRAP" "$TEST_WF"
  [ "$status" -eq 0 ]
  MEMORY_BEFORE="$(ls "$(memory_dir)" | sort)"

  run "$UPGRADE" --skip-pull --dry-run
  [ "$status" -eq 0 ]
  [[ "$output" == *"DRY RUN"* ]]
  [[ "$output" == *"Upgrade plan"* ]]
  [[ "$output" == *"Step 2 (memory)"* ]]
  [[ "$output" == *"(dry-run; no changes were made"* ]]

  # No new files in memory dir
  MEMORY_AFTER="$(ls "$(memory_dir)" | sort)"
  [ "$MEMORY_BEFORE" = "$MEMORY_AFTER" ]

  # No global commands dir created (would be at $TEST_HOME/.claude/commands)
  [ ! -d "$TEST_HOME/.claude/commands" ]
}

@test "upgrade.sh --skip-pull --skip-commands runs syncs only" {
  run "$BOOTSTRAP" "$TEST_WF"
  [ "$status" -eq 0 ]

  # Pre-bootstrap state — confirm a memory file we expect sync to NOT-add (already there)
  ls "$(memory_dir)/feedback_commit_format.md" >/dev/null

  run "$UPGRADE" --skip-pull --skip-commands
  [ "$status" -eq 0 ]
  [[ "$output" == *"Step 5 (commands):   SKIPPED"* ]]
  [[ "$output" == *"Upgrade complete"* ]]

  # Memory + templates should still have run; global commands dir not created
  [ ! -d "$TEST_HOME/.claude/commands" ]
}

@test "upgrade.sh --skip-pull happy path runs all steps" {
  run "$BOOTSTRAP" "$TEST_WF"
  [ "$status" -eq 0 ]

  run "$UPGRADE" --skip-pull
  [ "$status" -eq 0 ]
  [[ "$output" == *"Step 2 — syncing memory"* ]]
  [[ "$output" == *"Step 3 — syncing working-folder templates"* ]]
  [[ "$output" == *"Step 5 — installing global slash commands"* ]]
  [[ "$output" == *"Upgrade complete"* ]]
  [[ "$output" == *"Restart Claude.app"* ]]

  # Global commands dir should now exist in the sandboxed HOME
  [ -d "$TEST_HOME/.claude/commands" ]
  [ -f "$TEST_HOME/.claude/commands/session-start.md" ]
  [ -f "$TEST_HOME/.claude/agents/code-reviewer.md" ]
}

@test "upgrade.sh --skip-pull infers workspace mode and runs Step 4" {
  # Bootstrap a workspace + repo (Section D.4 / --workspace) — working folder
  # lands at $WS/<repo-name>, auto-memory is keyed off the source repo path.
  WS="$TEST_TMP/ws"
  run "$BOOTSTRAP" --workspace "$WS"
  [ "$status" -eq 0 ]

  # Stay in the source repo ($TEST_REPO from bootstrap_setup). upgrade.sh
  # infers the working folder from auto-memory and detects the workspace
  # root via the working folder's parent.
  cd "$TEST_REPO"

  run "$UPGRADE" --skip-pull --skip-commands
  [ "$status" -eq 0 ]
  [[ "$output" == *"Step 4 (workspace):  sync-templates.sh --workspace"* ]]
  [[ "$output" == *"Step 4 — syncing workspace templates"* ]]
}

@test "upgrade.sh shows --skip-pull skipped step in plan" {
  run "$BOOTSTRAP" "$TEST_WF"
  [ "$status" -eq 0 ]

  run "$UPGRADE" --skip-pull --dry-run
  [ "$status" -eq 0 ]
  [[ "$output" == *"Step 1 (pull):       SKIPPED (--skip-pull)"* ]]
}

@test "upgrade.sh shows --skip-commands skipped step in plan" {
  run "$BOOTSTRAP" "$TEST_WF"
  [ "$status" -eq 0 ]

  run "$UPGRADE" --skip-pull --skip-commands --dry-run
  [ "$status" -eq 0 ]
  [[ "$output" == *"Step 5 (commands):   SKIPPED (--skip-commands)"* ]]
}
