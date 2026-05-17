#!/usr/bin/env bats
# scripts/install-scripts.sh — install kit runtime helper scripts (currently
# just kit-print-memory-pointer.sh) to user-level (~/.claude/scripts/) or
# per-project (.claude/scripts/) location. Mirrors install-commands.sh's
# write-once + --force-update + --dry-run semantics.

load 'helpers'

INSTALL="$KIT_ROOT/scripts/install-scripts.sh"
SHIPPED_SCRIPT="kit-print-memory-pointer.sh"

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

@test "install-scripts.sh -h prints usage" {
  run "$INSTALL" -h
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage: install-scripts.sh"* ]]
  [[ "$output" == *"--global"* ]]
  [[ "$output" == *"--project"* ]]
  [[ "$output" == *"--force-update"* ]]
}

@test "install-scripts.sh errors when no destination is specified" {
  run "$INSTALL"
  [ "$status" -ne 0 ]
  [[ "$output" == *"must specify --global or --project"* ]]
}

@test "install-scripts.sh errors when --global and --project both passed" {
  run "$INSTALL" --global --project "$TEST_PROJECT"
  [ "$status" -ne 0 ]
  [[ "$output" == *"mutually exclusive"* ]]
}

@test "install-scripts.sh errors on unknown flag" {
  run "$INSTALL" --bogus
  [ "$status" -ne 0 ]
  [[ "$output" == *"unknown option"* ]]
}

@test "install-scripts.sh --project errors on relative path" {
  run "$INSTALL" --project relative/path
  [ "$status" -ne 0 ]
  [[ "$output" == *"must be absolute"* ]]
}

@test "install-scripts.sh --project errors when path doesn't exist" {
  run "$INSTALL" --project "$TEST_TMP/nonexistent"
  [ "$status" -ne 0 ]
  [[ "$output" == *"does not exist"* ]]
}

@test "install-scripts.sh --global installs the precheck helper script" {
  run "$INSTALL" --global
  [ "$status" -eq 0 ]
  [ -f "$TEST_HOME/.claude/scripts/$SHIPPED_SCRIPT" ]
  [ -x "$TEST_HOME/.claude/scripts/$SHIPPED_SCRIPT" ]
  # Contents must match the kit's source-of-truth copy byte-for-byte.
  cmp -s "$KIT_ROOT/scripts/$SHIPPED_SCRIPT" "$TEST_HOME/.claude/scripts/$SHIPPED_SCRIPT"
}

@test "install-scripts.sh --project installs into <project>/.claude/scripts/" {
  run "$INSTALL" --project "$TEST_PROJECT"
  [ "$status" -eq 0 ]
  [ -f "$TEST_PROJECT/.claude/scripts/$SHIPPED_SCRIPT" ]
  [ -x "$TEST_PROJECT/.claude/scripts/$SHIPPED_SCRIPT" ]
}

@test "install-scripts.sh --global is write-once by default — does not overwrite local edits" {
  run "$INSTALL" --global
  [ "$status" -eq 0 ]
  # Simulate a local edit.
  echo "# local edit" >> "$TEST_HOME/.claude/scripts/$SHIPPED_SCRIPT"
  EDITED_HASH="$(md5 -q "$TEST_HOME/.claude/scripts/$SHIPPED_SCRIPT" 2>/dev/null || md5sum "$TEST_HOME/.claude/scripts/$SHIPPED_SCRIPT" | awk '{print $1}')"

  # Re-run without --force-update — local edit must be preserved.
  run "$INSTALL" --global
  [ "$status" -eq 0 ]
  POST_HASH="$(md5 -q "$TEST_HOME/.claude/scripts/$SHIPPED_SCRIPT" 2>/dev/null || md5sum "$TEST_HOME/.claude/scripts/$SHIPPED_SCRIPT" | awk '{print $1}')"
  [ "$EDITED_HASH" = "$POST_HASH" ]
  [[ "$output" == *"write-once"* ]] || [[ "$output" == *"already in sync"* ]]
}

@test "install-scripts.sh --force-update --yes overwrites with a backup" {
  run "$INSTALL" --global
  [ "$status" -eq 0 ]
  # Local edit
  echo "# local edit" >> "$TEST_HOME/.claude/scripts/$SHIPPED_SCRIPT"

  # Force-update with --yes (non-interactive)
  run "$INSTALL" --global --force-update --yes
  [ "$status" -eq 0 ]

  # File now matches the kit's source-of-truth.
  cmp -s "$KIT_ROOT/scripts/$SHIPPED_SCRIPT" "$TEST_HOME/.claude/scripts/$SHIPPED_SCRIPT"
  # And a .bak.<timestamp> backup of the edited file exists.
  ls "$TEST_HOME/.claude/scripts/$SHIPPED_SCRIPT.bak."* >/dev/null
  BACKUP="$(ls "$TEST_HOME/.claude/scripts/$SHIPPED_SCRIPT.bak."* | head -1)"
  grep -q "# local edit" "$BACKUP"
}

@test "install-scripts.sh --force-update --yes is a no-op when target already matches kit" {
  run "$INSTALL" --global
  [ "$status" -eq 0 ]

  run "$INSTALL" --global --force-update --yes
  [ "$status" -eq 0 ]
  # No backup created when content is already identical.
  ! ls "$TEST_HOME/.claude/scripts/$SHIPPED_SCRIPT.bak."* 2>/dev/null
  [[ "$output" == *"identical"* ]] || [[ "$output" == *"already in sync"* ]]
}

@test "install-scripts.sh --global --dry-run writes nothing" {
  run "$INSTALL" --global --dry-run
  [ "$status" -eq 0 ]
  [ ! -d "$TEST_HOME/.claude/scripts" ]
  [[ "$output" == *"DRY RUN"* ]]
  [[ "$output" == *"$SHIPPED_SCRIPT"* ]]
}

@test "install-scripts.sh preserves user scripts not shipped by the kit" {
  # Pre-existing user-authored script
  mkdir -p "$TEST_HOME/.claude/scripts"
  echo "#!/usr/bin/env bash" > "$TEST_HOME/.claude/scripts/my-custom.sh"
  chmod +x "$TEST_HOME/.claude/scripts/my-custom.sh"

  run "$INSTALL" --global --force-update --yes
  [ "$status" -eq 0 ]

  # User's script must still be there, untouched.
  [ -f "$TEST_HOME/.claude/scripts/my-custom.sh" ]
  grep -q "#!/usr/bin/env bash" "$TEST_HOME/.claude/scripts/my-custom.sh"
}

@test "install-scripts.sh --yes without --force-update warns and is harmless" {
  run "$INSTALL" --global --yes
  [ "$status" -eq 0 ]
  [[ "$output" == *"warning"* ]] && [[ "$output" == *"--yes"* ]]
}
