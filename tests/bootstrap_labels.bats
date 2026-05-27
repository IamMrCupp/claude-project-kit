#!/usr/bin/env bats
# bootstrap.sh --with-labels (#58) — opt-in standard triage label scheme.
# The real `gh label create` path needs gh + a live GitHub repo, so these
# tests exercise the testable surfaces: flag parsing, the --dry-run preview,
# and off-by-default behavior. Real creation is non-fatal and gh-gated.

load 'helpers'

setup() { bootstrap_setup; }
teardown() { bootstrap_teardown; }

@test "bootstrap.sh -h documents --with-labels" {
  run "$BOOTSTRAP" -h
  [ "$status" -eq 0 ]
  [[ "$output" == *"--with-labels"* ]]
  [[ "$output" == *"OFF by default"* ]]
}

@test "bootstrap.sh --with-labels --dry-run previews the label scheme, writes nothing" {
  run "$BOOTSTRAP" "$TEST_WF" --dry-run --with-labels --skip-memory
  [ "$status" -eq 0 ]
  [[ "$output" == *"Would create GitHub labels"* ]]
  # A representative sample across the scheme
  [[ "$output" == *"type:bug"* ]]
  [[ "$output" == *"priority:P0"* ]]
  [[ "$output" == *"blocker"* ]]
  [[ "$output" == *"decision-needed"* ]]
  [[ "$output" == *"phase-0"* ]]
  # Dry run writes nothing
  [ ! -d "$TEST_WF" ] || [ -z "$(ls -A "$TEST_WF" 2>/dev/null)" ]
}

@test "bootstrap.sh without --with-labels never mentions labels" {
  run "$BOOTSTRAP" "$TEST_WF" --dry-run --skip-memory
  [ "$status" -eq 0 ]
  [[ "$output" != *"GitHub labels"* ]]
  [[ "$output" != *"create label"* ]]
}

@test "bootstrap.sh --with-labels is accepted alongside other flags" {
  run "$BOOTSTRAP" "$TEST_WF" --dry-run --with-labels --skip-memory --no-gitignore
  [ "$status" -eq 0 ]
  [[ "$output" == *"Would create GitHub labels"* ]]
}
