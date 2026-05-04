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

@test "templates/.claude/ starters are copied to working folder" {
  run "$BOOTSTRAP" "$TEST_WF"
  [ "$status" -eq 0 ]
  [ -d "$TEST_WF/.claude" ]
  [ -d "$TEST_WF/.claude/agents" ]
  [ -d "$TEST_WF/.claude/commands" ]
  [ -f "$TEST_WF/.claude/agents/code-reviewer.md" ]
  [ -f "$TEST_WF/.claude/agents/session-summarizer.md" ]
  [ -f "$TEST_WF/.claude/commands/close-phase.md" ]
  [ -f "$TEST_WF/.claude/commands/session-end.md" ]
  [ -f "$TEST_WF/.claude/README.md" ]
  [[ "$output" == *".claude/ starters"* ]]
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

@test "AI working folder index line in MEMORY.md is stamped with absolute path" {
  run "$BOOTSTRAP" "$TEST_WF"
  [ "$status" -eq 0 ]
  # Bug fix: the [AI working folder location] index line must embed the actual
  # working-folder path, because /session-start's precheck only sees MEMORY.md
  # content (not the linked reference_ai_working_folder.md file). A generic
  # description like "at session start" makes the precheck bail.
  grep -q "AI working folder location.*$TEST_WF" "$(memory_dir)/MEMORY.md"
  ! grep -q '{{WORKING_FOLDER}}' "$(memory_dir)/MEMORY.md"
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
