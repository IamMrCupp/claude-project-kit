#!/usr/bin/env bats
# Issue-tracker variant selection and memory seeding.

load 'helpers'

setup() { bootstrap_setup; }
teardown() { bootstrap_teardown; }

@test "--tracker github seeds reference_issue_tracker.md from github variant" {
  run "$BOOTSTRAP" --tracker github "$TEST_WF"
  [ "$status" -eq 0 ]
  local mem
  mem="$(memory_dir)"
  [ -f "$mem/reference_issue_tracker.md" ]
  grep -q "GitHub Issues" "$mem/reference_issue_tracker.md"
  grep -q "example/test-repo" "$mem/reference_issue_tracker.md"
}

@test "--tracker jira seeds and substitutes {{JIRA_PROJECT_KEY}}" {
  run "$BOOTSTRAP" --tracker jira --jira-project INFRA "$TEST_WF"
  [ "$status" -eq 0 ]
  local mem
  mem="$(memory_dir)"
  [ -f "$mem/reference_issue_tracker.md" ]
  grep -q "JIRA project \`INFRA\`" "$mem/reference_issue_tracker.md"
  ! grep -q '{{JIRA_PROJECT_KEY}}' "$mem/reference_issue_tracker.md"
}

@test "--tracker linear seeds and substitutes {{LINEAR_TEAM_KEY}}" {
  run "$BOOTSTRAP" --tracker linear --linear-team ENG "$TEST_WF"
  [ "$status" -eq 0 ]
  local mem
  mem="$(memory_dir)"
  [ -f "$mem/reference_issue_tracker.md" ]
  grep -q "Linear team \`ENG\`" "$mem/reference_issue_tracker.md"
  ! grep -q '{{LINEAR_TEAM_KEY}}' "$mem/reference_issue_tracker.md"
}

@test "--tracker gitlab seeds gitlab variant with repo slug" {
  run "$BOOTSTRAP" --tracker gitlab "$TEST_WF"
  [ "$status" -eq 0 ]
  local mem
  mem="$(memory_dir)"
  [ -f "$mem/reference_issue_tracker.md" ]
  grep -q "GitLab Issues" "$mem/reference_issue_tracker.md"
  grep -q "example/test-repo" "$mem/reference_issue_tracker.md"
}

@test "--tracker shortcut seeds shortcut variant" {
  run "$BOOTSTRAP" --tracker shortcut "$TEST_WF"
  [ "$status" -eq 0 ]
  local mem
  mem="$(memory_dir)"
  [ -f "$mem/reference_issue_tracker.md" ]
  grep -q "Shortcut" "$mem/reference_issue_tracker.md"
  grep -q "sc-" "$mem/reference_issue_tracker.md"
}

@test "--tracker other seeds placeholder-full variant" {
  run "$BOOTSTRAP" --tracker other "$TEST_WF"
  [ "$status" -eq 0 ]
  local mem
  mem="$(memory_dir)"
  [ -f "$mem/reference_issue_tracker.md" ]
  # "other" variant has intentional {{placeholder}} markers for manual fill
  grep -q '{{describe the tracker' "$mem/reference_issue_tracker.md"
  [[ "$output" == *"Also fill in the {{placeholders}} in reference_issue_tracker.md"* ]]
}

@test "--tracker none does not seed reference_issue_tracker.md" {
  run "$BOOTSTRAP" --tracker none "$TEST_WF"
  [ "$status" -eq 0 ]
  [ ! -f "$(memory_dir)/reference_issue_tracker.md" ]
}

@test "no --tracker flag does not seed reference_issue_tracker.md" {
  run "$BOOTSTRAP" "$TEST_WF"
  [ "$status" -eq 0 ]
  [ ! -f "$(memory_dir)/reference_issue_tracker.md" ]
}

@test "tracker seeding appends a line to MEMORY.md index" {
  run "$BOOTSTRAP" --tracker github "$TEST_WF"
  [ "$status" -eq 0 ]
  grep -q "reference_issue_tracker.md" "$(memory_dir)/MEMORY.md"
}

@test "tracker not seeded — no MEMORY.md index line for it" {
  run "$BOOTSTRAP" "$TEST_WF"
  [ "$status" -eq 0 ]
  ! grep -q "reference_issue_tracker.md" "$(memory_dir)/MEMORY.md"
}

# --- Phase 4 D.1 — tracker config substitution into CONTEXT.md ---

@test "--tracker jira substitutes tracker config into CONTEXT.md" {
  run "$BOOTSTRAP" --tracker jira --jira-project INFRA "$TEST_WF"
  [ "$status" -eq 0 ]
  grep -q '^- \*\*Tracker type:\*\* jira$' "$TEST_WF/CONTEXT.md"
  grep -q '^- \*\*Project / team key:\*\* INFRA$' "$TEST_WF/CONTEXT.md"
  ! grep -q '{{TRACKER_TYPE}}' "$TEST_WF/CONTEXT.md"
  ! grep -q '{{TRACKER_KEY}}' "$TEST_WF/CONTEXT.md"
}

@test "--tracker linear substitutes tracker config into CONTEXT.md" {
  run "$BOOTSTRAP" --tracker linear --linear-team ENG "$TEST_WF"
  [ "$status" -eq 0 ]
  grep -q '^- \*\*Tracker type:\*\* linear$' "$TEST_WF/CONTEXT.md"
  grep -q '^- \*\*Project / team key:\*\* ENG$' "$TEST_WF/CONTEXT.md"
}

@test "--tracker github substitutes type with not-applicable key" {
  run "$BOOTSTRAP" --tracker github "$TEST_WF"
  [ "$status" -eq 0 ]
  grep -q '^- \*\*Tracker type:\*\* github$' "$TEST_WF/CONTEXT.md"
  grep -q 'not applicable for github tracker' "$TEST_WF/CONTEXT.md"
}

@test "no --tracker flag substitutes tracker type as none" {
  run "$BOOTSTRAP" "$TEST_WF"
  [ "$status" -eq 0 ]
  grep -q '^- \*\*Tracker type:\*\* none$' "$TEST_WF/CONTEXT.md"
  grep -q 'no tracker configured' "$TEST_WF/CONTEXT.md"
}

@test "tracker substitution does not touch non-CONTEXT working-folder files" {
  # SEED-PROMPT.md owns deep-read content; bootstrap should leave its
  # placeholders alone (e.g. {{PROJECT_NAME}}, {{REPO_PATH}}).
  run "$BOOTSTRAP" --tracker jira --jira-project INFRA "$TEST_WF"
  [ "$status" -eq 0 ]
  grep -q '{{PROJECT_NAME}}' "$TEST_WF/plan.md"
  grep -q '{{REPO_PATH}}' "$TEST_WF/CONTEXT.md"
}

@test "dry-run shows tracker placeholder substitutions for CONTEXT.md" {
  run "$BOOTSTRAP" --dry-run --tracker jira --jira-project LX "$TEST_WF"
  [ "$status" -eq 0 ]
  [[ "$output" == *"substitute tracker placeholders in CONTEXT.md"* ]]
  [[ "$output" == *"{{TRACKER_TYPE}}"*"jira"* ]]
  [[ "$output" == *"{{TRACKER_KEY}}"*"LX"* ]]
}
