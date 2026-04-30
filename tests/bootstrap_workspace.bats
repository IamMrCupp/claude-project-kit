#!/usr/bin/env bats
# --workspace flag mechanics: workspace folder creation, per-repo subfolder,
# add-to-existing-workspace flow, dry-run output, help text presence.

load 'helpers'

setup() { bootstrap_setup; }
teardown() { bootstrap_teardown; }

@test "--workspace appears in --help output" {
  run "$BOOTSTRAP" --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"--workspace"* ]]
  [[ "$output" == *"workspace path"* ]]
  [[ "$output" == *"multi-repo"* ]]
}

@test "--workspace creates workspace dir, per-repo subfolder, and tickets/archive/" {
  WS="$TEST_TMP/acme-platform"
  run "$BOOTSTRAP" --workspace "$WS" --skip-memory
  [ "$status" -eq 0 ]

  REPO_NAME="$(basename "$TEST_REPO")"
  [ -d "$WS" ]
  [ -d "$WS/$REPO_NAME" ]
  [ -d "$WS/tickets" ]
  [ -d "$WS/tickets/archive" ]
}

@test "--workspace copies workspace-CONTEXT.md to workspace root" {
  WS="$TEST_TMP/acme-platform"
  run "$BOOTSTRAP" --workspace "$WS" --skip-memory
  [ "$status" -eq 0 ]

  [ -f "$WS/workspace-CONTEXT.md" ]
  grep -q "Workspace —" "$WS/workspace-CONTEXT.md"
}

@test "--workspace populates per-repo subfolder with standard templates" {
  WS="$TEST_TMP/acme-platform"
  run "$BOOTSTRAP" --workspace "$WS" --skip-memory
  [ "$status" -eq 0 ]

  REPO_NAME="$(basename "$TEST_REPO")"
  [ -f "$WS/$REPO_NAME/CONTEXT.md" ]
  [ -f "$WS/$REPO_NAME/SESSION-LOG.md" ]
  [ -f "$WS/$REPO_NAME/plan.md" ]
  [ -f "$WS/$REPO_NAME/phase-0-checklist.md" ]
  [ ! -f "$WS/$REPO_NAME/phase-N-checklist.md" ]
}

@test "--workspace does NOT copy workspace-only templates to per-repo subfolder" {
  WS="$TEST_TMP/acme-platform"
  run "$BOOTSTRAP" --workspace "$WS" --skip-memory
  [ "$status" -eq 0 ]

  REPO_NAME="$(basename "$TEST_REPO")"
  [ ! -f "$WS/$REPO_NAME/workspace-CONTEXT.md" ]
  [ ! -d "$WS/$REPO_NAME/tickets" ]
}

@test "--workspace re-run against existing workspace adds new repo without recreating workspace files" {
  WS="$TEST_TMP/acme-platform"

  # First run — creates workspace
  run "$BOOTSTRAP" --workspace "$WS" --skip-memory
  [ "$status" -eq 0 ]
  REPO1_NAME="$(basename "$TEST_REPO")"
  [ -f "$WS/workspace-CONTEXT.md" ]

  # Mark workspace-CONTEXT.md so we can detect if it gets overwritten
  echo "USER_EDITED" >> "$WS/workspace-CONTEXT.md"

  # Set up a sibling repo and bootstrap it into the same workspace
  REPO2="$TEST_TMP/repo2"
  mkdir -p "$REPO2"
  git -C "$REPO2" init -q
  cd "$REPO2"

  run "$BOOTSTRAP" --workspace "$WS" --skip-memory
  [ "$status" -eq 0 ]
  [[ "$output" == *"Existing workspace"* ]]
  [[ "$output" == *"adding repo subfolder repo2"* ]]

  # User edit must survive — workspace-CONTEXT.md NOT overwritten
  grep -q "USER_EDITED" "$WS/workspace-CONTEXT.md"

  # Both per-repo subfolders should exist
  [ -d "$WS/$REPO1_NAME" ]
  [ -d "$WS/repo2" ]
  [ -f "$WS/repo2/CONTEXT.md" ]
}

@test "--workspace errors when per-repo subfolder is non-empty (without --force)" {
  WS="$TEST_TMP/acme-platform"
  REPO_NAME="$(basename "$TEST_REPO")"
  mkdir -p "$WS/$REPO_NAME"
  echo "leftover" > "$WS/$REPO_NAME/CONTEXT.md"

  run "$BOOTSTRAP" --workspace "$WS" --skip-memory
  [ "$status" -ne 0 ]
  [[ "$output" == *"is not empty"* ]]
}

@test "--workspace --force proceeds past non-empty per-repo subfolder" {
  WS="$TEST_TMP/acme-platform"
  REPO_NAME="$(basename "$TEST_REPO")"
  mkdir -p "$WS/$REPO_NAME"
  echo "leftover" > "$WS/$REPO_NAME/leftover.txt"

  run "$BOOTSTRAP" --workspace "$WS" --skip-memory --force
  [ "$status" -eq 0 ]
  [ -f "$WS/$REPO_NAME/CONTEXT.md" ]
}

@test "--workspace --dry-run previews workspace creation without writing" {
  WS="$TEST_TMP/acme-platform"
  run "$BOOTSTRAP" --workspace "$WS" --skip-memory --dry-run
  [ "$status" -eq 0 ]
  [[ "$output" == *"DRY RUN"* ]]
  [[ "$output" == *"Workspace dir: $WS"* ]]
  [[ "$output" == *"create workspace dir"* ]]
  [[ "$output" == *"workspace-CONTEXT.md"* ]]

  # Nothing actually written
  [ ! -d "$WS" ]
}

@test "--workspace --dry-run against existing workspace reports no workspace-level changes" {
  WS="$TEST_TMP/acme-platform"
  mkdir -p "$WS"
  touch "$WS/workspace-CONTEXT.md"

  run "$BOOTSTRAP" --workspace "$WS" --skip-memory --dry-run
  [ "$status" -eq 0 ]
  [[ "$output" == *"existing workspace"* ]]
  [[ "$output" == *"no workspace-level changes"* ]]
}

@test "--workspace summary lines reflect workspace mode" {
  WS="$TEST_TMP/acme-platform"
  REPO_NAME="$(basename "$TEST_REPO")"
  run "$BOOTSTRAP" --workspace "$WS" --skip-memory
  [ "$status" -eq 0 ]
  [[ "$output" == *"Workspace:      $WS"* ]]
  [[ "$output" == *"Repo subfolder: $REPO_NAME"* ]]
  # Single-repo "Working folder:" line should NOT appear in workspace mode
  [[ "$output" != *"Working folder: $WS"* ]]
}

@test "--workspace seeds memory under repo-keyed path (not workspace-keyed)" {
  WS="$TEST_TMP/acme-platform"
  run "$BOOTSTRAP" --workspace "$WS"
  [ "$status" -eq 0 ]

  # Memory dir is keyed by REPO_ROOT (the actual repo), unchanged by workspace mode
  MEM="$(memory_dir)"
  [ -d "$MEM" ]
  [ -f "$MEM/MEMORY.md" ]
}

# --- Phase 4 D.1 — tracker config substitution into workspace-CONTEXT.md ---

@test "--workspace --tracker jira fills tracker config in workspace-CONTEXT.md" {
  WS="$TEST_TMP/acme-platform"
  REPO_NAME="$(basename "$TEST_REPO")"
  run "$BOOTSTRAP" --workspace "$WS" --tracker jira --jira-project ACME --skip-memory
  [ "$status" -eq 0 ]

  grep -q '^- \*\*Tracker type:\*\* jira$' "$WS/workspace-CONTEXT.md"
  grep -q '^- \*\*Project / team key:\*\* ACME$' "$WS/workspace-CONTEXT.md"
  ! grep -q '{{TRACKER_TYPE}}' "$WS/workspace-CONTEXT.md"
  ! grep -q '{{TRACKER_KEY}}' "$WS/workspace-CONTEXT.md"

  # Per-repo CONTEXT.md also gets the same substitution
  grep -q '^- \*\*Tracker type:\*\* jira$' "$WS/$REPO_NAME/CONTEXT.md"
  grep -q '^- \*\*Project / team key:\*\* ACME$' "$WS/$REPO_NAME/CONTEXT.md"
}

@test "--workspace re-run against existing workspace does not re-substitute tracker config" {
  WS="$TEST_TMP/acme-platform"

  # First run with jira/ACME
  run "$BOOTSTRAP" --workspace "$WS" --tracker jira --jira-project ACME --skip-memory
  [ "$status" -eq 0 ]
  grep -q '^- \*\*Project / team key:\*\* ACME$' "$WS/workspace-CONTEXT.md"

  # User manually edits workspace-CONTEXT.md
  sed -i.bak 's/Project \/ team key:\*\* ACME/Project \/ team key:\*\* ACME-EDITED/' "$WS/workspace-CONTEXT.md"
  rm -f "$WS/workspace-CONTEXT.md.bak"
  grep -q 'ACME-EDITED' "$WS/workspace-CONTEXT.md"

  # Bootstrap a sibling repo into the same workspace with different tracker key
  REPO2="$TEST_TMP/repo2"
  mkdir -p "$REPO2"
  git -C "$REPO2" init -q
  cd "$REPO2"

  run "$BOOTSTRAP" --workspace "$WS" --tracker jira --jira-project DIFFERENT --skip-memory
  [ "$status" -eq 0 ]

  # User's edit survives — workspace-CONTEXT.md was not overwritten
  grep -q 'ACME-EDITED' "$WS/workspace-CONTEXT.md"
  ! grep -q 'DIFFERENT' "$WS/workspace-CONTEXT.md"
}
