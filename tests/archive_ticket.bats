#!/usr/bin/env bats
# archive-ticket.sh — move a resolved ticket scratchpad into tickets/archive/.
# Counterpart to pull-ticket.sh. Tests cover path resolution (single-repo +
# workspace), the move, idempotence guards, and dry-run. Never touches a
# real tracker.

load 'helpers'

ARCHIVE=""

setup() {
  bootstrap_setup
  ARCHIVE="$KIT_ROOT/archive-ticket.sh"
}

teardown() { bootstrap_teardown; }

# Seed a single-repo working folder with a CONTEXT.md and an active ticket.
seed_single_repo_ticket() {
  local key="${1:-ACME-1234}"
  local slug="${2:-fix-lb-routing}"
  mkdir -p "$TEST_WF/tickets/archive"
  printf '# Claude Working Context — test\n' > "$TEST_WF/CONTEXT.md"
  printf '# %s\n\nWORKING NOTES\n' "$key" > "$TEST_WF/tickets/${key}-${slug}.md"
}

# Seed a workspace + per-repo subfolder, ticket lives in ../tickets.
seed_workspace_ticket() {
  local key="${1:-ACME-1234}"
  local slug="${2:-fix-lb-routing}"
  WS="$TEST_TMP/ws"
  WS_REPO="$WS/repo-a"
  mkdir -p "$WS_REPO" "$WS/tickets/archive"
  printf '# Workspace\n' > "$WS/workspace-CONTEXT.md"
  printf '# Per-repo CONTEXT\n' > "$WS_REPO/CONTEXT.md"
  printf '# %s\n\nWORKING NOTES\n' "$key" > "$WS/tickets/${key}-${slug}.md"
}

# --- Argument parsing ---

@test "archive-ticket.sh prints help on -h" {
  run "$ARCHIVE" -h
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage: archive-ticket.sh"* ]]
  [[ "$output" == *"--working-folder"* ]]
}

@test "archive-ticket.sh errors when no KEY argument" {
  run "$ARCHIVE"
  [ "$status" -eq 2 ]
  [[ "$output" == *"<KEY> argument is required"* ]]
}

@test "archive-ticket.sh errors on unknown flag" {
  run "$ARCHIVE" --bogus ACME-1
  [ "$status" -eq 2 ]
  [[ "$output" == *"unknown option"* ]]
}

@test "archive-ticket.sh errors when working folder does not exist" {
  run "$ARCHIVE" ACME-1234 --working-folder "$TEST_TMP/nope"
  [ "$status" -eq 1 ]
  [[ "$output" == *"working folder does not exist"* ]]
}

# --- Single-repo mode ---

@test "archive-ticket.sh moves a single-repo ticket into archive/" {
  seed_single_repo_ticket ACME-1234 fix-lb-routing
  run "$ARCHIVE" ACME-1234 --working-folder "$TEST_WF"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Archived ACME-1234-fix-lb-routing.md"* ]]
  [ ! -f "$TEST_WF/tickets/ACME-1234-fix-lb-routing.md" ]
  [ -f "$TEST_WF/tickets/archive/ACME-1234-fix-lb-routing.md" ]
}

@test "archive-ticket.sh preserves the ticket's contents on move" {
  seed_single_repo_ticket ACME-1234 fix-lb-routing
  run "$ARCHIVE" ACME-1234 --working-folder "$TEST_WF"
  [ "$status" -eq 0 ]
  grep -q "WORKING NOTES" "$TEST_WF/tickets/archive/ACME-1234-fix-lb-routing.md"
}

@test "archive-ticket.sh suggests a SESSION-LOG line and notes the tracker is unchanged" {
  seed_single_repo_ticket ACME-1234 fix-lb-routing
  run "$ARCHIVE" ACME-1234 --working-folder "$TEST_WF"
  [ "$status" -eq 0 ]
  [[ "$output" == *"SESSION-LOG.md"* ]]
  [[ "$output" == *"Tracker is unchanged"* ]]
}

# --- Workspace mode ---

@test "archive-ticket.sh moves a workspace ticket from ../tickets" {
  seed_workspace_ticket ACME-1234 fix-lb-routing
  run "$ARCHIVE" ACME-1234 --working-folder "$WS_REPO"
  [ "$status" -eq 0 ]
  [ ! -f "$WS/tickets/ACME-1234-fix-lb-routing.md" ]
  [ -f "$WS/tickets/archive/ACME-1234-fix-lb-routing.md" ]
}

# --- Dry run ---

@test "archive-ticket.sh --dry-run moves nothing" {
  seed_single_repo_ticket ACME-1234 fix-lb-routing
  run "$ARCHIVE" ACME-1234 --working-folder "$TEST_WF" --dry-run
  [ "$status" -eq 0 ]
  [[ "$output" == *"DRY RUN"* ]]
  [[ "$output" == *"Would move"* ]]
  [ -f "$TEST_WF/tickets/ACME-1234-fix-lb-routing.md" ]
  [ ! -f "$TEST_WF/tickets/archive/ACME-1234-fix-lb-routing.md" ]
}

# --- Guards ---

@test "archive-ticket.sh errors when no matching ticket exists" {
  seed_single_repo_ticket ACME-1234 fix-lb-routing
  run "$ARCHIVE" INFRA-99 --working-folder "$TEST_WF"
  [ "$status" -eq 1 ]
  [[ "$output" == *"no active ticket matching INFRA-99"* ]]
}

@test "archive-ticket.sh reports when a ticket is already archived" {
  seed_single_repo_ticket ACME-1234 fix-lb-routing
  # Archive it once, then try again
  run "$ARCHIVE" ACME-1234 --working-folder "$TEST_WF"
  [ "$status" -eq 0 ]
  run "$ARCHIVE" ACME-1234 --working-folder "$TEST_WF"
  [ "$status" -eq 1 ]
  [[ "$output" == *"already archived"* ]]
}

@test "archive-ticket.sh refuses to guess when multiple tickets match the key" {
  mkdir -p "$TEST_WF/tickets/archive"
  printf '# Claude Working Context — test\n' > "$TEST_WF/CONTEXT.md"
  printf 'a\n' > "$TEST_WF/tickets/ACME-1234-first.md"
  printf 'b\n' > "$TEST_WF/tickets/ACME-1234-second.md"
  run "$ARCHIVE" ACME-1234 --working-folder "$TEST_WF"
  [ "$status" -eq 1 ]
  [[ "$output" == *"multiple tickets match"* ]]
}

@test "archive-ticket.sh refuses when an archived file with the same name exists" {
  seed_single_repo_ticket ACME-1234 fix-lb-routing
  printf 'old\n' > "$TEST_WF/tickets/archive/ACME-1234-fix-lb-routing.md"
  run "$ARCHIVE" ACME-1234 --working-folder "$TEST_WF"
  [ "$status" -eq 1 ]
  [[ "$output" == *"already exists"* ]]
}

@test "archive-ticket.sh errors when no CONTEXT.md / workspace-CONTEXT.md is found" {
  mkdir -p "$TEST_WF"
  run "$ARCHIVE" ACME-1234 --working-folder "$TEST_WF"
  [ "$status" -eq 1 ]
  [[ "$output" == *"no CONTEXT.md found"* ]]
}
