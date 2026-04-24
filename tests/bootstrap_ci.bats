#!/usr/bin/env bats
# CI/automation variant selection and memory seeding.

load 'helpers'

setup() { bootstrap_setup; }
teardown() { bootstrap_teardown; }

@test "--ci github-actions seeds reference_ci.md from gha variant" {
  run "$BOOTSTRAP" --ci github-actions "$TEST_WF"
  [ "$status" -eq 0 ]
  local mem
  mem="$(memory_dir)"
  [ -f "$mem/reference_ci.md" ]
  grep -q "GitHub Actions" "$mem/reference_ci.md"
  grep -q "gh run" "$mem/reference_ci.md"
}

@test "--ci gitlab-ci seeds gitlab-ci variant" {
  run "$BOOTSTRAP" --ci gitlab-ci "$TEST_WF"
  [ "$status" -eq 0 ]
  local mem
  mem="$(memory_dir)"
  [ -f "$mem/reference_ci.md" ]
  grep -q "GitLab CI" "$mem/reference_ci.md"
  grep -q "glab ci" "$mem/reference_ci.md"
}

@test "--ci jenkins seeds jenkins variant" {
  run "$BOOTSTRAP" --ci jenkins "$TEST_WF"
  [ "$status" -eq 0 ]
  local mem
  mem="$(memory_dir)"
  [ -f "$mem/reference_ci.md" ]
  grep -q "Jenkins" "$mem/reference_ci.md"
  grep -q "Jenkinsfile" "$mem/reference_ci.md"
}

@test "--ci circleci seeds circleci variant" {
  run "$BOOTSTRAP" --ci circleci "$TEST_WF"
  [ "$status" -eq 0 ]
  local mem
  mem="$(memory_dir)"
  [ -f "$mem/reference_ci.md" ]
  grep -q "CircleCI" "$mem/reference_ci.md"
  grep -q "circleci" "$mem/reference_ci.md"
}

@test "--ci atlantis seeds atlantis variant" {
  run "$BOOTSTRAP" --ci atlantis "$TEST_WF"
  [ "$status" -eq 0 ]
  local mem
  mem="$(memory_dir)"
  [ -f "$mem/reference_ci.md" ]
  grep -q "Atlantis" "$mem/reference_ci.md"
  grep -q "atlantis plan" "$mem/reference_ci.md"
}

@test "--ci ansible-cli seeds ansible-cli variant" {
  run "$BOOTSTRAP" --ci ansible-cli "$TEST_WF"
  [ "$status" -eq 0 ]
  local mem
  mem="$(memory_dir)"
  [ -f "$mem/reference_ci.md" ]
  grep -q "Ansible" "$mem/reference_ci.md"
  grep -q "ansible-playbook" "$mem/reference_ci.md"
}

@test "--ci other seeds placeholder-full variant" {
  run "$BOOTSTRAP" --ci other "$TEST_WF"
  [ "$status" -eq 0 ]
  local mem
  mem="$(memory_dir)"
  [ -f "$mem/reference_ci.md" ]
  grep -q '{{describe the CI' "$mem/reference_ci.md"
  [[ "$output" == *"Also fill in the {{placeholders}} in reference_ci.md"* ]]
}

@test "--ci none does not seed reference_ci.md" {
  run "$BOOTSTRAP" --ci none "$TEST_WF"
  [ "$status" -eq 0 ]
  [ ! -f "$(memory_dir)/reference_ci.md" ]
}

@test "no --ci flag does not seed reference_ci.md" {
  run "$BOOTSTRAP" "$TEST_WF"
  [ "$status" -eq 0 ]
  [ ! -f "$(memory_dir)/reference_ci.md" ]
}

@test "CI seeding appends a line to MEMORY.md index" {
  run "$BOOTSTRAP" --ci jenkins "$TEST_WF"
  [ "$status" -eq 0 ]
  grep -q "reference_ci.md" "$(memory_dir)/MEMORY.md"
}

@test "combined --tracker + --ci seeds both reference files" {
  run "$BOOTSTRAP" --tracker jira --jira-project INFRA --ci atlantis "$TEST_WF"
  [ "$status" -eq 0 ]
  local mem
  mem="$(memory_dir)"
  [ -f "$mem/reference_issue_tracker.md" ]
  [ -f "$mem/reference_ci.md" ]
  grep -q "reference_issue_tracker.md" "$mem/MEMORY.md"
  grep -q "reference_ci.md" "$mem/MEMORY.md"
}
