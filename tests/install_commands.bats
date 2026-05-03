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
  [[ "$output" == *"Already in sync"* ]]
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

# ─── --force-update tests (issue #170) ────────────────────────────────────

@test "install-commands.sh -h documents --force-update + --yes flags" {
  run "$INSTALL" -h
  [ "$status" -eq 0 ]
  [[ "$output" == *"--force-update"* ]]
  [[ "$output" == *"--yes"* ]]
  [[ "$output" == *".bak."* ]]
}

@test "install-commands.sh --yes alone (no --force-update) prints a warning" {
  run "$INSTALL" --global --yes
  [ "$status" -eq 0 ]
  [[ "$output" == *"--yes has no effect without --force-update"* ]]
}

@test "install-commands.sh --force-update --yes overwrites kit-shipped files when content differs" {
  # First, install
  run "$INSTALL" --global
  [ "$status" -eq 0 ]
  [ -f "$HOME/.claude/commands/session-start.md" ]

  # Customize a kit-shipped command locally
  echo "USER_CUSTOMIZATION" > "$HOME/.claude/commands/session-start.md"

  # Force-update with --yes — should overwrite + create backup
  run "$INSTALL" --global --force-update --yes
  [ "$status" -eq 0 ]
  [[ "$output" == *"overwrote commands/session-start.md"* ]]
  [[ "$output" == *"backup:"* ]]

  # File is now the kit's version
  ! grep -q "USER_CUSTOMIZATION" "$HOME/.claude/commands/session-start.md"
  cmp -s "$KIT_ROOT/templates/.claude/commands/session-start.md" \
         "$HOME/.claude/commands/session-start.md"

  # Backup file exists with the customized content
  ls "$HOME/.claude/commands/session-start.md.bak."* >/dev/null
  BAK="$(ls "$HOME/.claude/commands/session-start.md.bak."* | head -1)"
  grep -q "USER_CUSTOMIZATION" "$BAK"
}

@test "install-commands.sh --force-update preserves user-added commands not in kit's templates" {
  # Install kit commands first
  run "$INSTALL" --global
  [ "$status" -eq 0 ]

  # User adds their own custom command that's NOT in the kit's templates
  echo "MY_CUSTOM_COMMAND" > "$HOME/.claude/commands/my-personal-cmd.md"

  # Force-update — should NOT touch the user-added file
  run "$INSTALL" --global --force-update --yes
  [ "$status" -eq 0 ]

  # User's custom file is still there, untouched
  [ -f "$HOME/.claude/commands/my-personal-cmd.md" ]
  grep -q "MY_CUSTOM_COMMAND" "$HOME/.claude/commands/my-personal-cmd.md"
  # No .bak file for it (never overwrote)
  [ -z "$(ls "$HOME/.claude/commands/my-personal-cmd.md.bak."* 2>/dev/null || true)" ]
}

@test "install-commands.sh --force-update skips files identical to kit's templates" {
  run "$INSTALL" --global
  [ "$status" -eq 0 ]

  # Now force-update without changing anything — files are identical to kit
  run "$INSTALL" --global --force-update --yes
  [ "$status" -eq 0 ]
  [[ "$output" == *"Already in sync"* ]] || [[ "$output" == *"identical to kit"* ]]
  # No .bak files created for identical content
  [ -z "$(ls "$HOME/.claude/commands/"*.bak.* 2>/dev/null || true)" ]
}

@test "install-commands.sh --force-update --dry-run writes nothing" {
  run "$INSTALL" --global
  [ "$status" -eq 0 ]
  echo "USER_CUSTOMIZATION" > "$HOME/.claude/commands/session-start.md"
  HASH_BEFORE="$(md5 -q "$HOME/.claude/commands/session-start.md" 2>/dev/null || md5sum "$HOME/.claude/commands/session-start.md" | awk '{print $1}')"

  run "$INSTALL" --global --force-update --yes --dry-run
  [ "$status" -eq 0 ]
  [[ "$output" == *"DRY RUN"* ]]
  [[ "$output" == *"would overwrite"* ]]

  # File NOT actually overwritten
  HASH_AFTER="$(md5 -q "$HOME/.claude/commands/session-start.md" 2>/dev/null || md5sum "$HOME/.claude/commands/session-start.md" | awk '{print $1}')"
  [ "$HASH_BEFORE" = "$HASH_AFTER" ]
  # No backup created
  [ -z "$(ls "$HOME/.claude/commands/session-start.md.bak."* 2>/dev/null || true)" ]
}

@test "install-commands.sh --force-update declined (no --yes, /dev/tty unavailable) leaves files alone" {
  run "$INSTALL" --global
  [ "$status" -eq 0 ]
  echo "USER_CUSTOMIZATION" > "$HOME/.claude/commands/session-start.md"

  # Without --yes and with no controlling TTY (bats run), the read defaults to
  # empty input → "no" → file not overwritten
  run "$INSTALL" --global --force-update
  [ "$status" -eq 0 ]
  [[ "$output" == *"local version differs from kit's"* ]]
  [[ "$output" == *"declined"* ]]

  # File preserved (no overwrite)
  grep -q "USER_CUSTOMIZATION" "$HOME/.claude/commands/session-start.md"
  # No .bak created (declined)
  [ -z "$(ls "$HOME/.claude/commands/session-start.md.bak."* 2>/dev/null || true)" ]
}
