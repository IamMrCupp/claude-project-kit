#!/usr/bin/env bats
# Phase 4 §E.1 — pull-ticket.sh terminal-driven helper.
#
# These tests cover the script's structural behavior (path resolution,
# tracker config parsing, idempotence, dry-run, workspace detection).
# They do not exercise live tracker MCPs / CLIs — those paths are
# fall-through; the stub path is the testable one.

load 'helpers'

PULL_TICKET=""

setup() {
  bootstrap_setup
  PULL_TICKET="$KIT_ROOT/pull-ticket.sh"
}

teardown() { bootstrap_teardown; }

# Helper: seed a single-repo working folder with a tracker-configured CONTEXT.md.
seed_single_repo_wf() {
  local tracker="${1:-jira}"
  local key="${2:-ACME}"
  mkdir -p "$TEST_WF"
  cat > "$TEST_WF/CONTEXT.md" <<EOF
# Claude Working Context — test-project

## Tracker Configuration

- **Tracker type:** $tracker
- **Project / team key:** $key
- **MCP availability:** unknown
EOF
}

# Helper: seed a workspace + per-repo subfolder.
seed_workspace_wf() {
  local tracker="${1:-jira}"
  local key="${2:-ACME}"
  WS="$TEST_TMP/lx-workspace"
  WS_REPO="$WS/repo-a"
  mkdir -p "$WS_REPO" "$WS/tickets/archive"
  cat > "$WS/workspace-CONTEXT.md" <<EOF
# Workspace — acme-platform

## Tracker Configuration

- **Tracker type:** $tracker
- **Project / team key:** $key
EOF
  cat > "$WS_REPO/CONTEXT.md" <<EOF
# Per-repo CONTEXT
EOF
}

# --- Argument parsing ---

@test "pull-ticket.sh prints help on -h" {
  run "$PULL_TICKET" -h
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage: pull-ticket.sh"* ]]
  [[ "$output" == *"--working-folder"* ]]
}

@test "pull-ticket.sh errors when no KEY argument" {
  run "$PULL_TICKET"
  [ "$status" -eq 2 ]
  [[ "$output" == *"<KEY> argument is required"* ]]
}

@test "pull-ticket.sh errors on unknown flag" {
  run "$PULL_TICKET" --bogus ACME-1
  [ "$status" -eq 2 ]
  [[ "$output" == *"unknown option"* ]]
}

@test "pull-ticket.sh errors when working folder doesn't exist" {
  run "$PULL_TICKET" ACME-1 --working-folder /tmp/nonexistent-$$-pull-ticket
  [ "$status" -ne 0 ]
  [[ "$output" == *"working folder does not exist"* ]]
}

# --- Tracker config parsing ---

@test "pull-ticket.sh errors when CONTEXT.md missing" {
  mkdir -p "$TEST_WF"
  run "$PULL_TICKET" ACME-1 --working-folder "$TEST_WF"
  [ "$status" -ne 0 ]
  [[ "$output" == *"no CONTEXT.md found"* ]]
}

@test "pull-ticket.sh errors when tracker type is none" {
  seed_single_repo_wf "none" ""
  run "$PULL_TICKET" ACME-1 --working-folder "$TEST_WF"
  [ "$status" -ne 0 ]
  [[ "$output" == *"tracker type is 'none'"* ]]
}

@test "pull-ticket.sh parses jira tracker config and uses stub fallback" {
  seed_single_repo_wf jira ACME
  run "$PULL_TICKET" ACME-1234 --working-folder "$TEST_WF"
  [ "$status" -eq 0 ]
  [ -f "$TEST_WF/tickets/ACME-1234-stub.md" ]
  grep -q "^# ACME-1234" "$TEST_WF/tickets/ACME-1234-stub.md"
  grep -q "Tracker:.*ACME-1234" "$TEST_WF/tickets/ACME-1234-stub.md"
}

# --- Dry-run ---

@test "pull-ticket.sh --dry-run does not write the file" {
  seed_single_repo_wf jira ACME
  run "$PULL_TICKET" ACME-1234 --working-folder "$TEST_WF" --dry-run
  [ "$status" -eq 0 ]
  [[ "$output" == *"DRY RUN"* ]]
  [[ "$output" == *"Would write:"* ]]
  [ ! -e "$TEST_WF/tickets/ACME-1234-stub.md" ]
}

# --- Idempotence ---

@test "pull-ticket.sh refuses to overwrite an existing scratchpad" {
  seed_single_repo_wf jira ACME
  mkdir -p "$TEST_WF/tickets"
  echo "existing notes" > "$TEST_WF/tickets/ACME-1234-existing.md"

  run "$PULL_TICKET" ACME-1234 --working-folder "$TEST_WF"
  [ "$status" -ne 0 ]
  [[ "$output" == *"already exists"* ]]

  # User's edits survive
  grep -q "existing notes" "$TEST_WF/tickets/ACME-1234-existing.md"
}

@test "pull-ticket.sh refuses to overwrite an archived scratchpad with same key" {
  seed_single_repo_wf jira ACME
  mkdir -p "$TEST_WF/tickets/archive"
  echo "archived" > "$TEST_WF/tickets/archive/ACME-1234-old.md"

  run "$PULL_TICKET" ACME-1234 --working-folder "$TEST_WF"
  [ "$status" -ne 0 ]
  [[ "$output" == *"already exists"* ]]
}

# --- Workspace mode ---

@test "pull-ticket.sh writes to workspace tickets/ when ../workspace-CONTEXT.md exists" {
  seed_workspace_wf jira ACME
  run "$PULL_TICKET" ACME-1234 --working-folder "$WS_REPO"
  [ "$status" -eq 0 ]
  [ -f "$WS/tickets/ACME-1234-stub.md" ]
  [ ! -d "$WS_REPO/tickets" ]  # per-repo subfolder should NOT have its own tickets/
}

@test "pull-ticket.sh in workspace mode reads workspace-level tracker config" {
  # Per-repo CONTEXT.md is intentionally empty / no tracker config —
  # the workspace-level one is what matters.
  seed_workspace_wf jira ACME
  run "$PULL_TICKET" ACME-1234 --working-folder "$WS_REPO" --dry-run
  [ "$status" -eq 0 ]
  [[ "$output" == *"Tracker type:   jira"* ]]
  [[ "$output" == *"Tracker key:    ACME"* ]]
}

# --- Constraint: read-only ---

@test "pull-ticket.sh source contains no tracker-mutation commands" {
  # Same defensive scan as bootstrap.sh's bootstrap_constraints.bats.
  local forbidden=(
    "gh issue create"
    "gh issue edit"
    "gh issue close"
    "gh issue delete"
    "gh issue reopen"
    "gh label create"
    "gh project create"
    "gh project edit"
    "gh project item-add"
    "jira issue create"
    "jira issue edit"
    "jira issue assign"
    "jira issue move"
    "linear ticket create"
    "linear ticket edit"
    "glab issue create"
    "glab issue close"
  )
  local pattern
  for pattern in "${forbidden[@]}"; do
    if grep -F -q "$pattern" "$KIT_ROOT/pull-ticket.sh"; then
      echo "FAIL: pull-ticket.sh contains forbidden tracker-mutation pattern: $pattern" >&2
      return 1
    fi
  done
}

@test "pull-ticket.sh has explicit constraint comment about being read-only" {
  grep -q "read-only against external trackers" "$KIT_ROOT/pull-ticket.sh"
  grep -q "ADR-0001 D3" "$KIT_ROOT/pull-ticket.sh"
}
