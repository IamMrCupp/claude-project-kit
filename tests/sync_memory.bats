#!/usr/bin/env bats
# scripts/sync-memory.sh — copy missing memory templates into a target
# auto-memory dir without overwriting existing files. Closes the dogfood-drift
# class of bug (kit ships new starter rules; existing adopters' memory
# silently falls behind).

load 'helpers'

SYNC="$KIT_ROOT/scripts/sync-memory.sh"

setup() {
  TEST_TMP="$(mktemp -d)"
  TARGET="$TEST_TMP/memory"
  mkdir -p "$TARGET"
}

teardown() {
  [ -n "${TEST_TMP:-}" ] && rm -rf "$TEST_TMP"
}

# Set up an isolated $HOME with a kit-bootstrapped fake repo so inference
# tests can run sync-memory.sh without an explicit path arg.
inferred_setup() {
  TEST_HOME="$TEST_TMP/home"
  TEST_REPO="$TEST_TMP/repo"
  mkdir -p "$TEST_HOME" "$TEST_REPO"
  git -C "$TEST_REPO" init -q
  export HOME="$TEST_HOME"
  local sanitized
  sanitized="$(echo "$TEST_REPO" | sed 's|/|-|g')"
  INFERRED_MEMORY="$HOME/.claude/projects/${sanitized}/memory"
  mkdir -p "$INFERRED_MEMORY"
}

@test "sync-memory.sh -h prints usage" {
  run "$SYNC" -h
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage: sync-memory.sh"* ]]
  [[ "$output" == *"--dry-run"* ]]
}

@test "sync-memory.sh errors on unknown flag" {
  run "$SYNC" --bogus "$TARGET"
  [ "$status" -ne 0 ]
  [[ "$output" == *"unknown option"* ]]
}

@test "sync-memory.sh errors on relative path" {
  run "$SYNC" relative/path
  [ "$status" -ne 0 ]
  [[ "$output" == *"must be an absolute path"* ]]
}

@test "sync-memory.sh errors when target dir does not exist" {
  run "$SYNC" "$TEST_TMP/does-not-exist"
  [ "$status" -ne 0 ]
  [[ "$output" == *"target memory dir does not exist"* ]]
}

@test "sync-memory.sh copies all generic templates into empty target" {
  run "$SYNC" "$TARGET"
  [ "$status" -eq 0 ]

  # Every shipped template (except user-customized) should land in the target
  for src in "$KIT_ROOT/memory-templates/"*.md; do
    name="$(basename "$src")"
    case "$name" in
      MEMORY.md|project_current.md|user_role.md) continue ;;
    esac
    [ -f "$TARGET/$name" ]
  done
}

@test "sync-memory.sh skips MEMORY.md, project_current.md, user_role.md" {
  run "$SYNC" "$TARGET"
  [ "$status" -eq 0 ]

  [ ! -f "$TARGET/MEMORY.md" ]
  [ ! -f "$TARGET/project_current.md" ]
  [ ! -f "$TARGET/user_role.md" ]
}

@test "sync-memory.sh never overwrites an existing file" {
  # Pre-seed target with a customized version of a known template
  cat > "$TARGET/feedback_commit_format.md" <<'EOF'
---
name: customized
---
USER_EDITED_CONTENT
EOF
  ORIGINAL_HASH="$(md5 -q "$TARGET/feedback_commit_format.md" 2>/dev/null || md5sum "$TARGET/feedback_commit_format.md" | awk '{print $1}')"

  run "$SYNC" "$TARGET"
  [ "$status" -eq 0 ]

  # File contents preserved
  AFTER_HASH="$(md5 -q "$TARGET/feedback_commit_format.md" 2>/dev/null || md5sum "$TARGET/feedback_commit_format.md" | awk '{print $1}')"
  [ "$ORIGINAL_HASH" = "$AFTER_HASH" ]
  grep -q "USER_EDITED_CONTENT" "$TARGET/feedback_commit_format.md"
}

@test "sync-memory.sh is idempotent — second run is a no-op" {
  run "$SYNC" "$TARGET"
  [ "$status" -eq 0 ]

  run "$SYNC" "$TARGET"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Already in sync"* ]]
}

@test "sync-memory.sh --dry-run writes nothing" {
  run "$SYNC" --dry-run "$TARGET"
  [ "$status" -eq 0 ]
  [[ "$output" == *"DRY RUN"* ]]
  [[ "$output" == *"would copy"* ]]
  [[ "$output" == *"Re-run without --dry-run"* ]]

  # Nothing actually written
  [ -z "$(ls -A "$TARGET" 2>/dev/null)" ]
}

@test "sync-memory.sh prints suggested MEMORY.md additions for copied files" {
  run "$SYNC" "$TARGET"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Suggested MEMORY.md additions"* ]]
  # Index lines come from memory-templates/MEMORY.md, e.g. push_branches
  [[ "$output" == *"feedback_push_branches.md"* ]]
  [[ "$output" == *"MEMORY.md is user-curated"* ]]
}

@test "sync-memory.sh tilde expansion works" {
  HOME_BACKUP="$HOME"
  export HOME="$TEST_TMP"
  mkdir -p "$HOME/mem"

  run "$SYNC" "~/mem"
  [ "$status" -eq 0 ]
  [ -f "$HOME/mem/feedback_commit_format.md" ]

  export HOME="$HOME_BACKUP"
}

@test "sync-memory.sh against a partially-populated target only copies missing" {
  cp "$KIT_ROOT/memory-templates/feedback_commit_format.md" "$TARGET/"
  cp "$KIT_ROOT/memory-templates/feedback_merge_strategy.md" "$TARGET/"

  run "$SYNC" "$TARGET"
  [ "$status" -eq 0 ]

  # Pre-existing files NOT mentioned as copied
  [[ "$output" != *"copied feedback_commit_format.md"* ]]
  [[ "$output" != *"copied feedback_merge_strategy.md"* ]]
  # Other files DID get copied
  [[ "$output" == *"copied feedback_push_branches.md"* ]]
}

# ─── Inference tests (issue #163) ─────────────────────────────────────────

@test "sync-memory.sh inferred mode works when run from a kit-bootstrapped repo" {
  HOME_BACKUP="$HOME"
  inferred_setup

  cd "$TEST_REPO"
  run "$SYNC"

  [ "$status" -eq 0 ]
  [[ "$output" == *"(inferred from \$PWD)"* ]]
  [ -f "$INFERRED_MEMORY/feedback_commit_format.md" ]

  export HOME="$HOME_BACKUP"
}

@test "sync-memory.sh inferred mode walks up to find repo root from a subdir" {
  HOME_BACKUP="$HOME"
  inferred_setup
  mkdir -p "$TEST_REPO/src/deep"

  cd "$TEST_REPO/src/deep"
  run "$SYNC"

  [ "$status" -eq 0 ]
  # Inferred memory should be the repo's, NOT a subdirectory's
  [ -f "$INFERRED_MEMORY/feedback_commit_format.md" ]

  export HOME="$HOME_BACKUP"
}

@test "sync-memory.sh inferred mode errors when not in a kit-bootstrapped repo" {
  HOME_BACKUP="$HOME"
  TEST_HOME="$TEST_TMP/home"
  NON_KIT="$TEST_TMP/random"
  mkdir -p "$TEST_HOME" "$NON_KIT"
  export HOME="$TEST_HOME"

  cd "$NON_KIT"
  run "$SYNC"

  [ "$status" -ne 0 ]
  [[ "$output" == *"couldn't find an auto-memory dir"* ]]
  [[ "$output" == *"cd into a kit-bootstrapped repo"* ]]

  export HOME="$HOME_BACKUP"
}
