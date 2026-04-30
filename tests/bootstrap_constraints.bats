#!/usr/bin/env bats
# Phase 4 D.2 — Defensive assertions that bootstrap.sh never creates resources
# in external trackers. See ADR-0001 D3 and CONVENTIONS.md "Ticket-driven
# workflows → What the kit does NOT do with trackers".

load 'helpers'

setup() { bootstrap_setup; }
teardown() { bootstrap_teardown; }

@test "bootstrap.sh source contains no tracker-mutation commands" {
  # Static check: scan bootstrap.sh for any command that would create or
  # mutate resources in an external tracker. This is the load-bearing
  # assertion behind ADR-0001 D3.
  local forbidden=(
    "gh issue create"
    "gh issue edit"
    "gh issue close"
    "gh issue delete"
    "gh issue reopen"
    "gh label create"
    "gh label edit"
    "gh label delete"
    "gh project create"
    "gh project edit"
    "gh project delete"
    "gh project item-add"
    "gh project field-create"
    "gh repo create"
    "gh workflow"
    "jira issue create"
    "jira issue edit"
    "jira issue close"
    "jira issue assign"
    "jira issue move"
    "linear ticket create"
    "linear ticket edit"
    "glab issue create"
    "glab issue close"
    "glab issue delete"
    "glab label create"
  )
  local pattern
  for pattern in "${forbidden[@]}"; do
    if grep -F -q "$pattern" "$BOOTSTRAP"; then
      echo "FAIL: bootstrap.sh contains forbidden tracker-mutation pattern: $pattern" >&2
      return 1
    fi
  done
}

@test "bootstrap.sh has explicit constraint comment about not creating tracker resources" {
  grep -q "never creates resources in external trackers" "$BOOTSTRAP"
  grep -q "ADR-0001 D3" "$BOOTSTRAP"
}

@test "bootstrap output never claims to create tracker resources (github)" {
  run "$BOOTSTRAP" --tracker github "$TEST_WF"
  [ "$status" -eq 0 ]
  [[ "$output" != *"Created issue"* ]]
  [[ "$output" != *"Created label"* ]]
  [[ "$output" != *"Created project"* ]]
  [[ "$output" != *"Created workflow"* ]]
  [[ "$output" != *"Created sprint"* ]]
}

@test "bootstrap output never claims to create tracker resources (jira)" {
  run "$BOOTSTRAP" --tracker jira --jira-project INFRA "$TEST_WF"
  [ "$status" -eq 0 ]
  [[ "$output" != *"Created issue"* ]]
  [[ "$output" != *"Created project"* ]]
  [[ "$output" != *"Created sprint"* ]]
  [[ "$output" != *"Created board"* ]]
}

@test "dry-run output never previews tracker resource creation" {
  run "$BOOTSTRAP" --dry-run --tracker jira --jira-project ACME "$TEST_WF"
  [ "$status" -eq 0 ]
  [[ "$output" != *"create issue"* ]]
  [[ "$output" != *"create label"* ]]
  [[ "$output" != *"create project in"* ]]
  [[ "$output" != *"create sprint"* ]]
}
