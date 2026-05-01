#!/usr/bin/env bats
# scripts/install-commands.sh — install kit slash commands + agents to user
# (~/.claude/) or per-project (.claude/) location. Never overwrites existing
# files. Idempotent.

load 'helpers'

INSTALL="$KIT_ROOT/scripts/install-commands.sh"

setup() {
  TEST_TMP="$(mktemp -d)"
  TEST_HOME="$TEST_TMP/home"
  TEST_PROJECT="$TEST_TMP/project"
  mkdir -p "$TEST_HOME" "$TEST_PROJECT"
  export HOME="$TEST_HOME"
}

teardown() {
  [ -n "${TEST_TMP:-}" ] && rm -rf "$TEST_TMP"
}

@test "install-commands.sh -h prints usage" {
  run "$INSTALL" -h
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage: install-commands.sh"* ]]
  [[ "$output" == *"--global"* ]]
  [[ "$output" == *"--project"* ]]
}

@test "install-commands.sh errors when no destination is specified" {
  run "$INSTALL"
  [ "$status" -ne 0 ]
  [[ "$output" == *"must specify --global or --project"* ]]
}

@test "install-commands.sh errors when --global and --project both passed" {
  run "$INSTALL" --global --project "$TEST_PROJECT"
  [ "$status" -ne 0 ]
  [[ "$output" == *"mutually exclusive"* ]]
}

@test "install-commands.sh errors on unknown flag" {
  run "$INSTALL" --bogus
  [ "$status" -ne 0 ]
  [[ "$output" == *"unknown option"* ]]
}

@test "install-commands.sh --project errors on relative path" {
  run "$INSTALL" --project relative/path
  [ "$status" -ne 0 ]
  [[ "$output" == *"must be absolute"* ]]
}

@test "install-commands.sh --project errors when path doesn't exist" {
  run "$INSTALL" --project "$TEST_TMP/nonexistent"
  [ "$status" -ne 0 ]
  [[ "$output" == *"does not exist"* ]]
}

@test "install-commands.sh --global installs all commands and agents" {
  run "$INSTALL" --global
  [ "$status" -eq 0 ]

  for f in "$KIT_ROOT/templates/.claude/commands"/*.md; do
    name="$(basename "$f")"
    [ -f "$TEST_HOME/.claude/commands/$name" ]
  done
  for f in "$KIT_ROOT/templates/.claude/agents"/*.md; do
    name="$(basename "$f")"
    [ -f "$TEST_HOME/.claude/agents/$name" ]
  done
}

@test "install-commands.sh --project installs to <project>/.claude/" {
  run "$INSTALL" --project "$TEST_PROJECT"
  [ "$status" -eq 0 ]

  [ -f "$TEST_PROJECT/.claude/commands/session-start.md" ]
  [ -f "$TEST_PROJECT/.claude/agents/code-reviewer.md" ]
  # And NOT global
  [ ! -d "$TEST_HOME/.claude" ]
}

@test "install-commands.sh never overwrites existing files" {
  mkdir -p "$TEST_HOME/.claude/commands"
  echo "USER_CUSTOMIZED" > "$TEST_HOME/.claude/commands/session-start.md"

  run "$INSTALL" --global
  [ "$status" -eq 0 ]

  # File was preserved, not overwritten
  grep -q "USER_CUSTOMIZED" "$TEST_HOME/.claude/commands/session-start.md"
  # Other files still installed
  [ -f "$TEST_HOME/.claude/commands/session-end.md" ]
}

@test "install-commands.sh is idempotent — second run is no-op" {
  run "$INSTALL" --global
  [ "$status" -eq 0 ]

  run "$INSTALL" --global
  [ "$status" -eq 0 ]
  [[ "$output" == *"Already installed"* ]]
}

@test "install-commands.sh --dry-run writes nothing" {
  run "$INSTALL" --global --dry-run
  [ "$status" -eq 0 ]
  [[ "$output" == *"DRY RUN"* ]]
  [[ "$output" == *"would install"* ]]
  [[ "$output" == *"Re-run without --dry-run"* ]]

  [ ! -d "$TEST_HOME/.claude" ]
}

@test "install-commands.sh --project --dry-run writes nothing" {
  run "$INSTALL" --project "$TEST_PROJECT" --dry-run
  [ "$status" -eq 0 ]
  [ ! -d "$TEST_PROJECT/.claude" ]
}

@test "install-commands.sh handles tilde expansion for --project" {
  mkdir -p "$TEST_HOME/myrepo"

  run "$INSTALL" --project "~/myrepo"
  [ "$status" -eq 0 ]
  [ -f "$TEST_HOME/myrepo/.claude/commands/session-start.md" ]
}

@test "install-commands.sh installs the new session-handoff command" {
  run "$INSTALL" --global
  [ "$status" -eq 0 ]
  [ -f "$TEST_HOME/.claude/commands/session-handoff.md" ]
}
