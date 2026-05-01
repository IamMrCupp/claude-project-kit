#!/usr/bin/env bats
# scripts/sync-templates.sh — copy missing templates/*.md (default mode) or
# templates/workspace/*.md (--workspace) into a target folder. Write-once.
# Reports outdated existing files; never auto-overwrites.

load 'helpers'

SYNC="$KIT_ROOT/scripts/sync-templates.sh"

setup() {
  TEST_TMP="$(mktemp -d)"
  TARGET="$TEST_TMP/wf"
  mkdir -p "$TARGET"
}

teardown() {
  [ -n "${TEST_TMP:-}" ] && rm -rf "$TEST_TMP"
}

@test "sync-templates.sh -h prints usage" {
  run "$SYNC" -h
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage: sync-templates.sh"* ]]
  [[ "$output" == *"--workspace"* ]]
  [[ "$output" == *"--dry-run"* ]]
}

@test "sync-templates.sh errors when no target arg" {
  run "$SYNC"
  [ "$status" -ne 0 ]
  [[ "$output" == *"missing <target-folder> argument"* ]]
}

@test "sync-templates.sh errors on relative path" {
  run "$SYNC" relative/path
  [ "$status" -ne 0 ]
  [[ "$output" == *"must be an absolute path"* ]]
}

@test "sync-templates.sh errors when target doesn't exist" {
  run "$SYNC" "$TEST_TMP/nonexistent"
  [ "$status" -ne 0 ]
  [[ "$output" == *"target folder does not exist"* ]]
}

@test "sync-templates.sh errors on unknown flag" {
  run "$SYNC" --bogus "$TARGET"
  [ "$status" -ne 0 ]
  [[ "$output" == *"unknown option"* ]]
}

@test "default mode copies all templates/*.md into empty target" {
  run "$SYNC" "$TARGET"
  [ "$status" -eq 0 ]

  for src in "$KIT_ROOT/templates/"*.md; do
    name="$(basename "$src")"
    [ -f "$TARGET/$name" ]
  done
}

@test "default mode does NOT copy templates/workspace/ contents" {
  run "$SYNC" "$TARGET"
  [ "$status" -eq 0 ]

  [ ! -f "$TARGET/workspace-CONTEXT.md" ]
  [ ! -f "$TARGET/workspace-plan.md" ]
}

@test "--workspace copies templates/workspace/*.md into target" {
  run "$SYNC" --workspace "$TARGET"
  [ "$status" -eq 0 ]

  [ -f "$TARGET/workspace-CONTEXT.md" ]
  [ -f "$TARGET/workspace-plan.md" ]
  # And does NOT copy single-repo templates
  [ ! -f "$TARGET/CONTEXT.md" ]
  [ ! -f "$TARGET/SESSION-LOG.md" ]
}

@test "sync-templates.sh never overwrites identical files" {
  cp "$KIT_ROOT/templates/CONTEXT.md" "$TARGET/CONTEXT.md"

  run "$SYNC" "$TARGET"
  [ "$status" -eq 0 ]

  # CONTEXT.md still matches the kit's template (unchanged)
  cmp -s "$KIT_ROOT/templates/CONTEXT.md" "$TARGET/CONTEXT.md"
  # Other files were copied
  [ -f "$TARGET/SESSION-LOG.md" ]
}

@test "sync-templates.sh never overwrites customized files" {
  echo "USER_CUSTOMIZED_CONTENT" > "$TARGET/CONTEXT.md"
  ORIGINAL_HASH="$(md5 -q "$TARGET/CONTEXT.md" 2>/dev/null || md5sum "$TARGET/CONTEXT.md" | awk '{print $1}')"

  run "$SYNC" "$TARGET"
  [ "$status" -eq 0 ]

  # User content preserved
  AFTER_HASH="$(md5 -q "$TARGET/CONTEXT.md" 2>/dev/null || md5sum "$TARGET/CONTEXT.md" | awk '{print $1}')"
  [ "$ORIGINAL_HASH" = "$AFTER_HASH" ]
  grep -q "USER_CUSTOMIZED_CONTENT" "$TARGET/CONTEXT.md"
}

@test "sync-templates.sh reports outdated files (exist but differ from kit)" {
  echo "USER_CUSTOMIZED_CONTENT" > "$TARGET/CONTEXT.md"

  run "$SYNC" "$TARGET"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Outdated files"* ]]
  [[ "$output" == *"CONTEXT.md"* ]]
  [[ "$output" == *"NOT modified"* ]]
}

@test "sync-templates.sh is idempotent — second run is no-op" {
  run "$SYNC" "$TARGET"
  [ "$status" -eq 0 ]

  run "$SYNC" "$TARGET"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Already in sync"* ]]
}

@test "sync-templates.sh --dry-run writes nothing in default mode" {
  run "$SYNC" --dry-run "$TARGET"
  [ "$status" -eq 0 ]
  [[ "$output" == *"DRY RUN"* ]]
  [[ "$output" == *"would copy"* ]]
  [[ "$output" == *"Re-run without --dry-run"* ]]

  # Nothing actually written
  [ -z "$(ls -A "$TARGET" 2>/dev/null)" ]
}

@test "sync-templates.sh --dry-run writes nothing in workspace mode" {
  run "$SYNC" --workspace --dry-run "$TARGET"
  [ "$status" -eq 0 ]

  [ -z "$(ls -A "$TARGET" 2>/dev/null)" ]
}

@test "sync-templates.sh tilde expansion works" {
  HOME_BACKUP="$HOME"
  export HOME="$TEST_TMP"
  mkdir -p "$HOME/wf2"

  run "$SYNC" "~/wf2"
  [ "$status" -eq 0 ]
  [ -f "$HOME/wf2/CONTEXT.md" ]

  export HOME="$HOME_BACKUP"
}

@test "sync-templates.sh handles partially-populated target — only copies missing" {
  cp "$KIT_ROOT/templates/CONTEXT.md" "$TARGET/CONTEXT.md"
  cp "$KIT_ROOT/templates/SESSION-LOG.md" "$TARGET/SESSION-LOG.md"

  run "$SYNC" "$TARGET"
  [ "$status" -eq 0 ]

  # Pre-existing files NOT mentioned as copied
  [[ "$output" != *"copied CONTEXT.md"* ]]
  [[ "$output" != *"copied SESSION-LOG.md"* ]]
  # Other files DID get copied
  [[ "$output" == *"copied plan.md"* ]] || [[ "$output" == *"copied SEED-PROMPT.md"* ]]
}
