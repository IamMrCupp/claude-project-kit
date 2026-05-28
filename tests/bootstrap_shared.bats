#!/usr/bin/env bats
# bootstrap.sh --shared / --reference flags (#199 PR A).
#
# Two new flags + two new optional template sections:
#   --shared              — keeps CONTEXT.md "Referenced by" section in the seeded WF
#   --workspace + --reference <path> — keeps workspace-CONTEXT.md "Shared repos"
#                                       section and populates one bullet per --reference
#
# Default behavior (neither flag) strips both optional sections, so non-shared
# repos and non-referencing workspaces don't see clutter from features that
# don't apply to them.

load 'helpers'

setup() { bootstrap_setup; }
teardown() { bootstrap_teardown; }

# --- Help text ---

@test "bootstrap.sh -h documents --shared and --reference" {
  run "$BOOTSTRAP" -h
  [ "$status" -eq 0 ]
  [[ "$output" == *"--shared"* ]]
  [[ "$output" == *"--reference PATH"* ]]
  [[ "$output" == *"Mutually exclusive with --workspace"* ]]
}

# --- Default (no --shared, no --reference) — both optional sections stripped ---

@test "default bootstrap strips the 'Referenced by' section from CONTEXT.md" {
  run "$BOOTSTRAP" "$TEST_WF" --skip-memory --skip-scripts --no-gitignore
  [ "$status" -eq 0 ]
  ! grep -q "BEGIN OPTIONAL: REFERENCED_BY" "$TEST_WF/CONTEXT.md"
  ! grep -q "^## Referenced by$" "$TEST_WF/CONTEXT.md"
}

@test "default workspace bootstrap strips the 'Shared repos' section from workspace-CONTEXT.md" {
  WS="$TEST_TMP/ws"
  run "$BOOTSTRAP" --workspace "$WS" --skip-memory --skip-scripts --no-gitignore
  [ "$status" -eq 0 ]
  ! grep -q "BEGIN OPTIONAL: SHARED_REPOS" "$WS/workspace-CONTEXT.md"
  ! grep -q "^## Shared repos$" "$WS/workspace-CONTEXT.md"
}

# --- --shared keeps the section ---

@test "--shared keeps the 'Referenced by' section in CONTEXT.md (markers stripped, content retained)" {
  run "$BOOTSTRAP" "$TEST_WF" --shared --skip-memory --skip-scripts --no-gitignore
  [ "$status" -eq 0 ]
  grep -q "^## Referenced by$" "$TEST_WF/CONTEXT.md"
  ! grep -q "BEGIN OPTIONAL: REFERENCED_BY" "$TEST_WF/CONTEXT.md"
  ! grep -q "END OPTIONAL: REFERENCED_BY" "$TEST_WF/CONTEXT.md"
}

# --- Mutual exclusion + dependency errors ---

@test "--shared + --workspace errors with a clear message" {
  WS="$TEST_TMP/ws"
  run "$BOOTSTRAP" --shared --workspace "$WS"
  [ "$status" -eq 2 ]
  [[ "$output" == *"--shared and --workspace are mutually exclusive"* ]]
}

@test "--reference without --workspace errors" {
  run "$BOOTSTRAP" --reference "$TEST_TMP/shared-wf" "$TEST_WF"
  [ "$status" -eq 2 ]
  [[ "$output" == *"--reference requires --workspace"* ]]
}

@test "--reference without a path argument errors" {
  run "$BOOTSTRAP" --reference --workspace "$TEST_TMP/ws"
  [ "$status" -eq 2 ]
  # Either "requires a path" (preferred) or "unknown option" (fallback) is acceptable —
  # both signal the same problem and exit non-zero. Just verify it doesn't silently swallow.
}

# --- --workspace --reference populates the Shared repos section ---

@test "--workspace --reference populates the 'Shared repos' section with one entry" {
  WS="$TEST_TMP/ws"
  SHARED="$TEST_TMP/shared-flux-config"
  run "$BOOTSTRAP" --workspace "$WS" --reference "$SHARED" --skip-memory --skip-scripts --no-gitignore
  [ "$status" -eq 0 ]
  grep -q "^## Shared repos$" "$WS/workspace-CONTEXT.md"
  ! grep -q "BEGIN OPTIONAL: SHARED_REPOS" "$WS/workspace-CONTEXT.md"
  grep -q "shared-flux-config — \`$SHARED\`" "$WS/workspace-CONTEXT.md"
}

@test "--reference is repeatable and preserves argument order" {
  WS="$TEST_TMP/ws"
  S1="$TEST_TMP/shared-alpha"
  S2="$TEST_TMP/shared-bravo"
  S3="$TEST_TMP/shared-charlie"
  run "$BOOTSTRAP" --workspace "$WS" \
    --reference "$S1" --reference "$S2" --reference "$S3" \
    --skip-memory --skip-scripts --no-gitignore
  [ "$status" -eq 0 ]
  # Extract Shared repos bullet lines in file order
  ORDER=$(grep -E '^- shared-' "$WS/workspace-CONTEXT.md" | awk -F' — ' '{print $1}' | tr '\n' ',')
  [ "$ORDER" = "- shared-alpha,- shared-bravo,- shared-charlie," ]
}

# --- Re-run against an existing workspace appends new --reference entries ---

@test "re-running --workspace --reference on an existing workspace appends new entries" {
  WS="$TEST_TMP/ws"
  S1="$TEST_TMP/shared-first"
  S2="$TEST_TMP/shared-second"

  # First run creates the workspace + populates S1
  run "$BOOTSTRAP" --workspace "$WS" --reference "$S1" --skip-memory --skip-scripts --no-gitignore
  [ "$status" -eq 0 ]
  grep -q "shared-first" "$WS/workspace-CONTEXT.md"

  # Second run from a different "repo" cwd adds S2 to the same workspace
  OTHER="$TEST_TMP/other-repo"
  mkdir -p "$OTHER" && git -C "$OTHER" init -q
  cd "$OTHER"
  run "$BOOTSTRAP" --workspace "$WS" --reference "$S2" --skip-memory --skip-scripts --no-gitignore
  [ "$status" -eq 0 ]
  grep -q "shared-first" "$WS/workspace-CONTEXT.md"
  grep -q "shared-second" "$WS/workspace-CONTEXT.md"
}

# --- Dry-run shows the plan without writing ---

@test "--shared --dry-run previews 'Referenced by' kept and writes nothing" {
  run "$BOOTSTRAP" "$TEST_WF" --shared --dry-run --skip-memory --skip-scripts --no-gitignore
  [ "$status" -eq 0 ]
  [[ "$output" == *"keep CONTEXT.md 'Referenced by' section"* ]]
  [ ! -d "$TEST_WF" ] || [ -z "$(ls -A "$TEST_WF" 2>/dev/null)" ]
}

@test "default --dry-run mentions stripping the 'Referenced by' section" {
  run "$BOOTSTRAP" "$TEST_WF" --dry-run --skip-memory --skip-scripts --no-gitignore
  [ "$status" -eq 0 ]
  [[ "$output" == *"strip optional 'Referenced by' section"* ]]
}

@test "--workspace --reference --dry-run previews populated entries" {
  WS="$TEST_TMP/ws"
  SHARED="$TEST_TMP/shared-foo"
  run "$BOOTSTRAP" --workspace "$WS" --reference "$SHARED" --dry-run \
    --skip-memory --skip-scripts --no-gitignore
  [ "$status" -eq 0 ]
  [[ "$output" == *"Shared repos"* ]]
  [[ "$output" == *"shared-foo"* ]]
  [ ! -d "$WS" ]
}
