#!/usr/bin/env bats
# Working-folder + memory seeding + placeholder substitution.

load 'helpers'

setup() { bootstrap_setup; }
teardown() { bootstrap_teardown; }

@test "basic run creates working folder with templates" {
  run "$BOOTSTRAP" "$TEST_WF"
  [ "$status" -eq 0 ]
  [ -d "$TEST_WF" ]
  [ -f "$TEST_WF/CONTEXT.md" ]
  [ -f "$TEST_WF/SESSION-LOG.md" ]
  [ -f "$TEST_WF/plan.md" ]
  [ -f "$TEST_WF/implementation.md" ]
  [ -f "$TEST_WF/SEED-PROMPT.md" ]
  [ -f "$TEST_WF/research.md" ]
  [ -f "$TEST_WF/acceptance-test-results.md" ]
}

@test "phase-N-checklist.md is renamed to phase-0-checklist.md" {
  run "$BOOTSTRAP" "$TEST_WF"
  [ "$status" -eq 0 ]
  [ -f "$TEST_WF/phase-0-checklist.md" ]
  [ ! -f "$TEST_WF/phase-N-checklist.md" ]
}

@test "basic run seeds memory folder with all starter files" {
  run "$BOOTSTRAP" "$TEST_WF"
  [ "$status" -eq 0 ]
  local mem
  mem="$(memory_dir)"
  [ -d "$mem" ]
  [ -f "$mem/MEMORY.md" ]
  [ -f "$mem/user_role.md" ]
  [ -f "$mem/reference_ai_working_folder.md" ]
  [ -f "$mem/project_current.md" ]
}

@test "--skip-memory does not create memory folder" {
  run "$BOOTSTRAP" --skip-memory "$TEST_WF"
  [ "$status" -eq 0 ]
  [ -d "$TEST_WF" ]
  [ ! -d "$(memory_dir)" ]
}

@test "placeholder substitution fills {{PROJECT_NAME}}" {
  run "$BOOTSTRAP" "$TEST_WF"
  [ "$status" -eq 0 ]
  # default project name = basename of working folder
  grep -q "$(basename "$TEST_WF")" "$(memory_dir)/reference_ai_working_folder.md"
  ! grep -q '{{PROJECT_NAME}}' "$(memory_dir)/reference_ai_working_folder.md"
}

@test "placeholder substitution fills {{WORKING_FOLDER}}" {
  run "$BOOTSTRAP" "$TEST_WF"
  [ "$status" -eq 0 ]
  grep -q "$TEST_WF" "$(memory_dir)/reference_ai_working_folder.md"
  ! grep -q '{{WORKING_FOLDER}}' "$(memory_dir)/reference_ai_working_folder.md"
}

@test "placeholder substitution fills {{REPO_PATH}}" {
  run "$BOOTSTRAP" "$TEST_WF"
  [ "$status" -eq 0 ]
  grep -q "$TEST_REPO" "$(memory_dir)/reference_ai_working_folder.md"
  ! grep -q '{{REPO_PATH}}' "$(memory_dir)/reference_ai_working_folder.md"
}

@test "placeholder substitution fills {{REPO_SLUG}} when git remote exists" {
  run "$BOOTSTRAP" "$TEST_WF"
  [ "$status" -eq 0 ]
  grep -q "example/test-repo" "$(memory_dir)/project_current.md"
  ! grep -q '{{REPO_SLUG}}' "$(memory_dir)/project_current.md"
}

@test "{{REPO_SLUG}} left as placeholder when no git remote" {
  setup_repo_without_remote
  run "$BOOTSTRAP" "$TEST_WF"
  [ "$status" -eq 0 ]
  grep -q '{{REPO_SLUG}}' "$(memory_dir)/project_current.md"
  [[ "$output" == *"no git remote 'origin' found"* ]]
}

@test "--project-name overrides the auto-derived name" {
  run "$BOOTSTRAP" --project-name "my-custom-name" "$TEST_WF"
  [ "$status" -eq 0 ]
  grep -q "my-custom-name" "$(memory_dir)/reference_ai_working_folder.md"
}

@test "non-empty working folder errors without --force" {
  mkdir -p "$TEST_WF"
  touch "$TEST_WF/existing-file"
  run "$BOOTSTRAP" "$TEST_WF"
  [ "$status" -eq 1 ]
  [[ "$output" == *"is not empty"* ]]
}

@test "--force proceeds past non-empty working folder" {
  mkdir -p "$TEST_WF"
  touch "$TEST_WF/existing-file"
  run "$BOOTSTRAP" --force "$TEST_WF"
  [ "$status" -eq 0 ]
  [ -f "$TEST_WF/existing-file" ]
  [ -f "$TEST_WF/CONTEXT.md" ]
}

@test "existing non-empty memory folder errors (never overwrites)" {
  mkdir -p "$(memory_dir)"
  echo "pre-existing" > "$(memory_dir)/keep.md"
  run "$BOOTSTRAP" "$TEST_WF"
  [ "$status" -eq 1 ]
  [[ "$output" == *"already contains files"* ]]
  [ -f "$(memory_dir)/keep.md" ]
}

@test "tilde in working-folder expands to HOME" {
  run "$BOOTSTRAP" "~/test-wf"
  [ "$status" -eq 0 ]
  [ -d "$TEST_HOME/test-wf" ]
  [ -f "$TEST_HOME/test-wf/CONTEXT.md" ]
}
