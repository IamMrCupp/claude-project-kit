#!/usr/bin/env bats
# --dry-run behavior: plan printout, no filesystem writes.

load 'helpers'

setup() { bootstrap_setup; }
teardown() { bootstrap_teardown; }

@test "--dry-run exits 0 and prints DRY RUN banner" {
  run "$BOOTSTRAP" --dry-run "$TEST_WF"
  [ "$status" -eq 0 ]
  [[ "$output" == *"DRY RUN"* ]]
  [[ "$output" == *"No changes made"* ]]
}

@test "--dry-run creates no working folder" {
  run "$BOOTSTRAP" --dry-run "$TEST_WF"
  [ "$status" -eq 0 ]
  [ ! -d "$TEST_WF" ]
}

@test "--dry-run creates no memory folder" {
  run "$BOOTSTRAP" --dry-run "$TEST_WF"
  [ "$status" -eq 0 ]
  [ ! -d "$(memory_dir)" ]
}

@test "--dry-run lists planned placeholder substitutions" {
  run "$BOOTSTRAP" --dry-run "$TEST_WF"
  [ "$status" -eq 0 ]
  [[ "$output" == *"{{WORKING_FOLDER}}"* ]]
  [[ "$output" == *"{{PROJECT_NAME}}"* ]]
  [[ "$output" == *"{{REPO_PATH}}"* ]]
  [[ "$output" == *"{{REPO_SLUG}}"* ]]
}

@test "--dry-run with --tracker jira mentions key substitution" {
  run "$BOOTSTRAP" --dry-run --tracker jira --jira-project INFRA "$TEST_WF"
  [ "$status" -eq 0 ]
  [[ "$output" == *"{{JIRA_PROJECT_KEY}}"* ]]
  [[ "$output" == *"INFRA"* ]]
  [[ "$output" == *"trackers/jira.md"* ]]
}

@test "--dry-run with --ci mentions the CI variant copy" {
  run "$BOOTSTRAP" --dry-run --ci atlantis "$TEST_WF"
  [ "$status" -eq 0 ]
  [[ "$output" == *"ci/atlantis.md"* ]]
  [[ "$output" == *"reference_ci.md"* ]]
}

@test "--dry-run flags non-empty working folder as needing --force" {
  mkdir -p "$TEST_WF"
  touch "$TEST_WF/existing"
  run "$BOOTSTRAP" --dry-run "$TEST_WF"
  [ "$status" -eq 0 ]
  [[ "$output" == *"real run would fail without --force"* ]]
}

@test "--dry-run flags non-empty memory folder as blocking real run" {
  mkdir -p "$(memory_dir)"
  echo "keep" > "$(memory_dir)/existing.md"
  run "$BOOTSTRAP" --dry-run "$TEST_WF"
  [ "$status" -eq 0 ]
  [[ "$output" == *"real run would fail (never overwrites memory)"* ]]
}

@test "--dry-run with --skip-memory reports memory skipped" {
  run "$BOOTSTRAP" --dry-run --skip-memory "$TEST_WF"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Memory seeding skipped"* ]]
  # should NOT list memory placeholders
  [[ "$output" != *"{{WORKING_FOLDER}}    → "* ]]
}
