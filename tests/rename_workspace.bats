#!/usr/bin/env bats
# scripts/rename-workspace.sh — rename a kit workspace folder + fix up the
# per-repo auto-memory files that pin the old path. Workspace-tree prose is
# reported, not auto-rewritten.

load 'helpers'

RENAME="$KIT_ROOT/scripts/rename-workspace.sh"

setup() { bootstrap_setup; }
teardown() { bootstrap_teardown; }

# Set up a workspace + bootstrap one repo into it. Returns nothing; sets
# OLD_WS, NEW_WS, MEM_FILE globals for the test to use.
setup_workspace_with_one_repo() {
  OLD_WS="$TEST_TMP/old-workspace"
  NEW_WS="$TEST_TMP/new-workspace"
  run "$BOOTSTRAP" --workspace "$OLD_WS"
  [ "$status" -eq 0 ]
  MEM_FILE="$(memory_dir)/reference_ai_working_folder.md"
  [ -f "$MEM_FILE" ]
  # The memory file should reference the OLD path
  grep -qF "$OLD_WS" "$MEM_FILE"
}

@test "rename-workspace.sh -h prints usage" {
  run "$RENAME" -h
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage: rename-workspace.sh"* ]]
  [[ "$output" == *"<old-workspace-path>"* ]]
  [[ "$output" == *"<new-workspace-path>"* ]]
}

@test "rename-workspace.sh errors when no args" {
  run "$RENAME"
  [ "$status" -ne 0 ]
  [[ "$output" == *"<new-workspace-path> is required"* ]]
}

@test "rename-workspace.sh errors on relative paths" {
  run "$RENAME" relative/old absolute/new
  [ "$status" -ne 0 ]
  [[ "$output" == *"must be absolute"* ]]
}

@test "rename-workspace.sh errors when old and new are the same" {
  WS="$TEST_TMP/foo"
  mkdir -p "$WS"
  touch "$WS/workspace-CONTEXT.md"
  run "$RENAME" "$WS" "$WS"
  [ "$status" -ne 0 ]
  [[ "$output" == *"identical"* ]]
}

@test "rename-workspace.sh errors when old workspace doesn't exist" {
  run "$RENAME" "$TEST_TMP/nonexistent" "$TEST_TMP/new"
  [ "$status" -ne 0 ]
  [[ "$output" == *"does not exist"* ]]
}

@test "rename-workspace.sh errors when old path is not a kit workspace" {
  WS="$TEST_TMP/notakitws"
  mkdir -p "$WS"
  echo "hi" > "$WS/random.md"
  run "$RENAME" "$WS" "$TEST_TMP/new"
  [ "$status" -ne 0 ]
  [[ "$output" == *"workspace-CONTEXT.md"* ]]
}

@test "rename-workspace.sh errors when new path already exists" {
  setup_workspace_with_one_repo
  mkdir -p "$NEW_WS"
  run "$RENAME" "$OLD_WS" "$NEW_WS"
  [ "$status" -ne 0 ]
  [[ "$output" == *"already exists"* ]]
}

@test "rename-workspace.sh --dry-run shows plan and writes nothing" {
  setup_workspace_with_one_repo

  run "$RENAME" --dry-run "$OLD_WS" "$NEW_WS"
  [ "$status" -eq 0 ]
  [[ "$output" == *"DRY RUN"* ]]
  [[ "$output" == *"will be rewritten"* ]] || [[ "$output" == *"No auto-memory files"* ]]

  # Workspace dir not moved
  [ -d "$OLD_WS" ]
  [ ! -d "$NEW_WS" ]
  # Memory file unchanged
  grep -qF "$OLD_WS" "$MEM_FILE"
  ! grep -qF "$NEW_WS" "$MEM_FILE"
}

@test "rename-workspace.sh moves the workspace dir" {
  setup_workspace_with_one_repo

  run "$RENAME" "$OLD_WS" "$NEW_WS"
  [ "$status" -eq 0 ]

  [ ! -d "$OLD_WS" ]
  [ -d "$NEW_WS" ]
  [ -f "$NEW_WS/workspace-CONTEXT.md" ]
}

@test "rename-workspace.sh rewrites auto-memory reference_ai_working_folder.md" {
  setup_workspace_with_one_repo

  run "$RENAME" "$OLD_WS" "$NEW_WS"
  [ "$status" -eq 0 ]

  # Memory file now references new path, not old
  grep -qF "$NEW_WS" "$MEM_FILE"
  ! grep -qF "$OLD_WS" "$MEM_FILE"
}

@test "rename-workspace.sh creates a backup of memory files before rewriting" {
  setup_workspace_with_one_repo

  run "$RENAME" "$OLD_WS" "$NEW_WS"
  [ "$status" -eq 0 ]

  # At least one .bak.<timestamp> file exists alongside the rewritten memory
  ls "$MEM_FILE".bak.* >/dev/null 2>&1
  # The backup contains the OLD path
  BAK="$(ls "$MEM_FILE".bak.* | head -1)"
  grep -qF "$OLD_WS" "$BAK"
}

@test "rename-workspace.sh reports workspace-tree matches without rewriting them" {
  setup_workspace_with_one_repo

  # Inject an old-path reference into a per-repo file inside the workspace
  REPO_NAME="$(basename "$TEST_REPO")"
  echo "Reference to $OLD_WS in prose" >> "$OLD_WS/$REPO_NAME/CONTEXT.md"

  run "$RENAME" --dry-run "$OLD_WS" "$NEW_WS"
  [ "$status" -eq 0 ]
  [[ "$output" == *"NOT auto-rewritten"* ]]
  [[ "$output" == *"$REPO_NAME/CONTEXT.md"* ]]
}

@test "rename-workspace.sh handles no-memory case gracefully" {
  # Set up a workspace WITHOUT auto-memory (--skip-memory)
  OLD_WS="$TEST_TMP/old-ws"
  NEW_WS="$TEST_TMP/new-ws"
  run "$BOOTSTRAP" --workspace "$OLD_WS" --skip-memory
  [ "$status" -eq 0 ]

  run "$RENAME" "$OLD_WS" "$NEW_WS"
  [ "$status" -eq 0 ]
  [[ "$output" == *"No auto-memory files"* ]]
  [ -d "$NEW_WS" ]
}

@test "rename-workspace.sh handles tilde expansion" {
  HOME_BACKUP="$HOME"
  export HOME="$TEST_TMP/home2"
  mkdir -p "$HOME"

  # Bootstrap a workspace under the new HOME
  cd "$TEST_REPO"
  run "$BOOTSTRAP" --workspace "$HOME/old-ws" --skip-memory
  [ "$status" -eq 0 ]

  run "$RENAME" "~/old-ws" "~/new-ws"
  [ "$status" -eq 0 ]
  [ -d "$HOME/new-ws" ]
  [ ! -d "$HOME/old-ws" ]

  export HOME="$HOME_BACKUP"
}

# ─── Inference tests (issue #163) ─────────────────────────────────────────

@test "rename-workspace.sh single arg infers OLD from \$PWD when inside a workspace" {
  WS="$TEST_TMP/old-ws"
  NEW="$TEST_TMP/new-ws"
  mkdir -p "$WS"
  touch "$WS/workspace-CONTEXT.md"

  cd "$WS"
  run "$RENAME" "$NEW"

  [ "$status" -eq 0 ]
  [[ "$output" == *"(inferred from \$PWD)"* ]]
  [ -d "$NEW" ]
  [ ! -d "$WS" ]
}

@test "rename-workspace.sh single arg errors with friendly message when not in workspace" {
  HOME_BACKUP="$HOME"
  TEST_HOME="$TEST_TMP/home"
  NON_KIT="$TEST_TMP/random"
  mkdir -p "$TEST_HOME" "$NON_KIT"
  export HOME="$TEST_HOME"

  cd "$NON_KIT"
  run "$RENAME" "$TEST_TMP/new-ws"

  [ "$status" -ne 0 ]
  [[ "$output" == *"couldn't infer a workspace root"* ]]
  [[ "$output" == *"rename-workspace.sh <old> <new>"* ]]

  export HOME="$HOME_BACKUP"
}

@test "rename-workspace.sh single arg infers via parent dir from a member repo" {
  WS="$TEST_TMP/parent-ws"
  REPO_WF="$WS/repo-a"
  NEW="$TEST_TMP/parent-ws-renamed"
  mkdir -p "$REPO_WF"
  touch "$WS/workspace-CONTEXT.md"

  cd "$REPO_WF"
  run "$RENAME" --dry-run "$NEW"

  [ "$status" -eq 0 ]
  [[ "$output" == *"(inferred from \$PWD)"* ]]
  [[ "$output" == *"$WS"* ]]
}
