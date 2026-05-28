#!/usr/bin/env bats
# scripts/convert-to-shared.sh — migrate a per-repo working folder out of a
# workspace into a standalone shared working folder (#199 PR B).

load 'helpers'

CONVERT=""

setup() {
  bootstrap_setup
  CONVERT="$KIT_ROOT/scripts/convert-to-shared.sh"
}

teardown() { bootstrap_teardown; }

# Helper: stage a pre-migration state — a kit-bootstrapped repo whose working
# folder lives as a per-repo subfolder under a workspace, with the auto-memory
# pointer pointing at it. Sets the following globals:
#   REPO         — the repo path (git-inited)
#   WS           — the workspace dir (has workspace-CONTEXT.md)
#   WS_WF        — the per-repo working folder under WS (the migration source)
#   MEM_DIR      — the auto-memory dir for REPO
#   MEM_POINTER  — reference_ai_working_folder.md inside MEM_DIR
stage_per_repo_in_workspace() {
  REPO="$TEST_TMP/repo"
  WS="$TEST_TMP/ws"
  WS_WF="$WS/$(basename "$REPO")"

  mkdir -p "$REPO" "$WS/tickets/archive" "$WS_WF"
  git -C "$REPO" init -q
  cp "$KIT_ROOT/templates/workspace/workspace-CONTEXT.md" "$WS/"
  cp "$KIT_ROOT/templates/CONTEXT.md" "$WS_WF/"
  echo "SESSION-LOG content" > "$WS_WF/SESSION-LOG.md"

  local sanitized
  sanitized="$(echo "$REPO" | sed 's|[/.]|-|g')"
  MEM_DIR="$TEST_HOME/.claude/projects/${sanitized}/memory"
  mkdir -p "$MEM_DIR"
  MEM_POINTER="$MEM_DIR/reference_ai_working_folder.md"
  cat > "$MEM_POINTER" <<EOF
---
name: AI working folder for test
type: reference
---
Read these files first:
- \`$WS_WF/CONTEXT.md\` — context
- \`$WS_WF/SESSION-LOG.md\` — log
EOF
}

# --- Help / arg validation ---

@test "convert-to-shared.sh -h prints usage with --to and --reference-from" {
  run "$CONVERT" -h
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage: convert-to-shared.sh"* ]]
  [[ "$output" == *"--to PATH"* ]]
  [[ "$output" == *"--reference-from WS"* ]]
}

@test "errors when no <repo-path> given" {
  run "$CONVERT"
  [ "$status" -eq 2 ]
  [[ "$output" == *"<repo-path> argument is required"* ]]
}

@test "errors on relative <repo-path>" {
  run "$CONVERT" relative/path
  [ "$status" -eq 2 ]
  [[ "$output" == *"must be an absolute path"* ]]
}

@test "errors when <repo-path> does not exist" {
  run "$CONVERT" "$TEST_TMP/nope"
  [ "$status" -eq 2 ]
  [[ "$output" == *"does not exist"* ]]
}

@test "errors when --to is missing its argument" {
  stage_per_repo_in_workspace
  run "$CONVERT" "$REPO" --to
  [ "$status" -eq 2 ]
  [[ "$output" == *"--to requires a path"* ]]
}

@test "errors when --reference-from is missing its argument" {
  stage_per_repo_in_workspace
  run "$CONVERT" "$REPO" --reference-from
  [ "$status" -eq 2 ]
  [[ "$output" == *"--reference-from requires a path"* ]]
}

# --- Precondition errors ---

@test "errors when repo has no kit auto-memory" {
  REPO="$TEST_TMP/lonely-repo"
  mkdir -p "$REPO"
  git -C "$REPO" init -q
  run "$CONVERT" "$REPO" --yes
  [ "$status" -eq 1 ]
  [[ "$output" == *"no kit working folder found"* ]]
}

@test "errors when working folder isn't under a workspace" {
  # Standalone repo (already has a non-workspace working folder)
  REPO="$TEST_TMP/standalone-repo"
  STANDALONE_WF="$TEST_TMP/standalone-wf"
  mkdir -p "$REPO" "$STANDALONE_WF"
  git -C "$REPO" init -q
  cp "$KIT_ROOT/templates/CONTEXT.md" "$STANDALONE_WF/"
  local sanitized
  sanitized="$(echo "$REPO" | sed 's|[/.]|-|g')"
  mkdir -p "$TEST_HOME/.claude/projects/${sanitized}/memory"
  cat > "$TEST_HOME/.claude/projects/${sanitized}/memory/reference_ai_working_folder.md" <<EOF
- \`$STANDALONE_WF/CONTEXT.md\` — context
EOF
  run "$CONVERT" "$REPO" --yes
  [ "$status" -eq 1 ]
  [[ "$output" == *"isn't currently a per-repo subfolder under a workspace"* ]]
}

# --- Happy path ---

@test "happy path: moves WF, repoints pointer, appends entry to source WS" {
  stage_per_repo_in_workspace
  TGT="$TEST_TMP/target-wf"

  run "$CONVERT" "$REPO" --to "$TGT" --yes
  [ "$status" -eq 0 ]

  # WF moved
  [ ! -d "$WS_WF" ]
  [ -f "$TGT/CONTEXT.md" ]
  [ -f "$TGT/SESSION-LOG.md" ]

  # Pointer repointed
  grep -q "$TGT/CONTEXT.md" "$MEM_POINTER"
  ! grep -q "$WS_WF/CONTEXT.md" "$MEM_POINTER"

  # Source workspace-CONTEXT.md has the Shared repos entry
  grep -q "$(basename "$REPO") — \`$TGT\`" "$WS/workspace-CONTEXT.md"

  # Backups exist for both mutated files
  ls "$MEM_POINTER".bak.* >/dev/null 2>&1
  ls "$WS/workspace-CONTEXT.md".bak.* >/dev/null 2>&1
}

@test "preserves content of files inside the moved working folder" {
  stage_per_repo_in_workspace
  echo "MY CUSTOM CONTENT" > "$WS_WF/notes.md"
  TGT="$TEST_TMP/target-wf"

  run "$CONVERT" "$REPO" --to "$TGT" --yes
  [ "$status" -eq 0 ]

  [ -f "$TGT/notes.md" ]
  grep -q "MY CUSTOM CONTENT" "$TGT/notes.md"
}

# --- Dry-run ---

@test "--dry-run prints plan and writes nothing" {
  stage_per_repo_in_workspace
  TGT="$TEST_TMP/target-wf"

  run "$CONVERT" "$REPO" --to "$TGT" --dry-run
  [ "$status" -eq 0 ]
  [[ "$output" == *"DRY RUN"* ]]
  [[ "$output" == *"mv $WS_WF"* ]]

  # Nothing actually moved or mutated
  [ -d "$WS_WF" ]
  [ ! -e "$TGT" ]
  ! grep -q "$TGT" "$MEM_POINTER"
  ! grep -q "## Shared repos" "$WS/workspace-CONTEXT.md" || \
    ! grep -q "$(basename "$REPO") —" "$WS/workspace-CONTEXT.md"
}

# --- --reference-from ---

@test "--reference-from adds the entry to additional workspaces" {
  stage_per_repo_in_workspace
  EXTRA_WS="$TEST_TMP/extra-ws"
  mkdir -p "$EXTRA_WS"
  cp "$KIT_ROOT/templates/workspace/workspace-CONTEXT.md" "$EXTRA_WS/"

  TGT="$TEST_TMP/target-wf"
  run "$CONVERT" "$REPO" --to "$TGT" --reference-from "$EXTRA_WS" --yes
  [ "$status" -eq 0 ]

  grep -q "$(basename "$REPO")" "$WS/workspace-CONTEXT.md"
  grep -q "$(basename "$REPO")" "$EXTRA_WS/workspace-CONTEXT.md"
  ls "$EXTRA_WS/workspace-CONTEXT.md".bak.* >/dev/null 2>&1
}

@test "--reference-from skips paths that aren't workspaces (warn, don't fail)" {
  stage_per_repo_in_workspace
  TGT="$TEST_TMP/target-wf"
  BOGUS="$TEST_TMP/not-a-workspace"
  mkdir -p "$BOGUS"

  run "$CONVERT" "$REPO" --to "$TGT" --reference-from "$BOGUS" --yes
  [ "$status" -eq 0 ]
  [[ "$output" == *"skipped"* ]]
}

@test "--reference-from skips the source workspace if passed redundantly" {
  stage_per_repo_in_workspace
  TGT="$TEST_TMP/target-wf"

  run "$CONVERT" "$REPO" --to "$TGT" --reference-from "$WS" --yes
  [ "$status" -eq 0 ]
  [[ "$output" == *"skipped"* ]]
  # The source workspace still got exactly one entry (not duplicated)
  local count
  count=$(grep -c "^- $(basename "$REPO") —" "$WS/workspace-CONTEXT.md")
  [ "$count" -eq 1 ]
}

# --- Target collision ---

@test "errors when --to target already exists" {
  stage_per_repo_in_workspace
  TGT="$TEST_TMP/already-here"
  mkdir -p "$TGT"

  run "$CONVERT" "$REPO" --to "$TGT" --yes
  [ "$status" -eq 1 ]
  [[ "$output" == *"target standalone working folder already exists"* ]]
}
