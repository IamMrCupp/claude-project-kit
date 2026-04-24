#!/usr/bin/env bats
# Arg parsing, help text, and CLI validation.

load 'helpers'

setup() { bootstrap_setup; }
teardown() { bootstrap_teardown; }

@test "--help exits 0 and prints usage" {
  run "$BOOTSTRAP" --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage:"* ]]
  [[ "$output" == *"--tracker"* ]]
  [[ "$output" == *"--ci"* ]]
  [[ "$output" == *"--dry-run"* ]]
}

@test "-h exits 0 and prints usage" {
  run "$BOOTSTRAP" -h
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage:"* ]]
}

@test "unknown flag errors with exit 2" {
  run "$BOOTSTRAP" --does-not-exist "$TEST_WF"
  [ "$status" -eq 2 ]
  [[ "$output" == *"unknown option"* ]]
}

@test "extra positional arg errors with exit 2" {
  run "$BOOTSTRAP" "$TEST_WF" "$TEST_WF.extra"
  [ "$status" -eq 2 ]
  [[ "$output" == *"unexpected extra argument"* ]]
}

@test "missing <working-folder> in non-TTY errors with exit 2" {
  # bats drives the script non-interactively, so no arg should error
  # rather than prompting.
  run "$BOOTSTRAP"
  [ "$status" -eq 2 ]
  [[ "$output" == *"missing <working-folder>"* ]]
}

@test "--project-name without value errors" {
  run "$BOOTSTRAP" --project-name
  [ "$status" -eq 2 ]
  [[ "$output" == *"--project-name requires a value"* ]]
}

@test "--tracker without value errors" {
  run "$BOOTSTRAP" --tracker
  [ "$status" -eq 2 ]
  [[ "$output" == *"--tracker requires a value"* ]]
}

@test "--jira-project without value errors" {
  run "$BOOTSTRAP" --jira-project
  [ "$status" -eq 2 ]
  [[ "$output" == *"--jira-project requires a value"* ]]
}

@test "--linear-team without value errors" {
  run "$BOOTSTRAP" --linear-team
  [ "$status" -eq 2 ]
  [[ "$output" == *"--linear-team requires a value"* ]]
}

@test "--ci without value errors" {
  run "$BOOTSTRAP" --ci
  [ "$status" -eq 2 ]
  [[ "$output" == *"--ci requires a value"* ]]
}

@test "invalid --tracker value errors" {
  run "$BOOTSTRAP" --tracker bogus "$TEST_WF"
  [ "$status" -eq 2 ]
  [[ "$output" == *"--tracker must be one of"* ]]
}

@test "invalid --ci value errors" {
  run "$BOOTSTRAP" --ci bogus "$TEST_WF"
  [ "$status" -eq 2 ]
  [[ "$output" == *"--ci must be one of"* ]]
}

@test "relative working-folder path errors" {
  run "$BOOTSTRAP" relative/path
  [ "$status" -eq 2 ]
  [[ "$output" == *"must be an absolute path"* ]]
}

@test "--tracker jira without --jira-project in non-TTY errors" {
  run "$BOOTSTRAP" --tracker jira "$TEST_WF"
  [ "$status" -eq 2 ]
  [[ "$output" == *"requires --jira-project"* ]]
}

@test "--tracker linear without --linear-team in non-TTY errors" {
  run "$BOOTSTRAP" --tracker linear "$TEST_WF"
  [ "$status" -eq 2 ]
  [[ "$output" == *"requires --linear-team"* ]]
}

@test "--jira-project alone infers --tracker jira" {
  run "$BOOTSTRAP" --jira-project INFRA "$TEST_WF"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Issue tracker:  jira (project: INFRA)"* ]]
}

@test "--linear-team alone infers --tracker linear" {
  run "$BOOTSTRAP" --linear-team ENG "$TEST_WF"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Issue tracker:  linear (team: ENG)"* ]]
}
