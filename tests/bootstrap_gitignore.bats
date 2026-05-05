#!/usr/bin/env bats
# Bootstrap manages the target repo's .gitignore by appending a marker-bracketed
# block covering local-only Claude Code state (.claude/), macOS junk, and common
# editor / IDE files. Idempotent. --no-gitignore opts out.

load 'helpers'

setup() { bootstrap_setup; }
teardown() { bootstrap_teardown; }

@test "creates .gitignore with kit-managed block when absent" {
  [ ! -f "$TEST_REPO/.gitignore" ]
  run "$BOOTSTRAP" --skip-memory "$TEST_WF"
  [ "$status" -eq 0 ]
  [ -f "$TEST_REPO/.gitignore" ]
  grep -Fq "# claude-project-kit — managed block START" "$TEST_REPO/.gitignore"
  grep -Fq "# claude-project-kit — managed block END" "$TEST_REPO/.gitignore"
  grep -Fq ".claude/" "$TEST_REPO/.gitignore"
  grep -Fq ".DS_Store" "$TEST_REPO/.gitignore"
  grep -Fq ".vscode/" "$TEST_REPO/.gitignore"
  grep -Fq ".idea/" "$TEST_REPO/.gitignore"
}

@test "appends kit-managed block to existing .gitignore preserving prior content" {
  printf 'node_modules/\n*.log\n' > "$TEST_REPO/.gitignore"
  run "$BOOTSTRAP" --skip-memory "$TEST_WF"
  [ "$status" -eq 0 ]
  # Pre-existing entries still present
  grep -Fxq "node_modules/" "$TEST_REPO/.gitignore"
  grep -Fxq "*.log" "$TEST_REPO/.gitignore"
  # Kit block appended
  grep -Fq "# claude-project-kit — managed block START" "$TEST_REPO/.gitignore"
  grep -Fq ".claude/" "$TEST_REPO/.gitignore"
  # Pre-existing content appears before the kit block
  pre_line="$(grep -nFx 'node_modules/' "$TEST_REPO/.gitignore" | head -1 | cut -d: -f1)"
  block_line="$(grep -nF '# claude-project-kit — managed block START' "$TEST_REPO/.gitignore" | head -1 | cut -d: -f1)"
  [ "$pre_line" -lt "$block_line" ]
}

@test "is idempotent — re-running does not duplicate the block" {
  run "$BOOTSTRAP" --skip-memory "$TEST_WF"
  [ "$status" -eq 0 ]
  count_first="$(grep -cF '# claude-project-kit — managed block START' "$TEST_REPO/.gitignore")"
  [ "$count_first" -eq 1 ]
  # Second run must succeed and leave the file untouched.
  run "$BOOTSTRAP" --skip-memory --force "$TEST_WF"
  [ "$status" -eq 0 ]
  [[ "$output" == *"already has kit-managed block"* ]]
  count_second="$(grep -cF '# claude-project-kit — managed block START' "$TEST_REPO/.gitignore")"
  [ "$count_second" -eq 1 ]
}

@test "--no-gitignore opt-out skips creation entirely" {
  [ ! -f "$TEST_REPO/.gitignore" ]
  run "$BOOTSTRAP" --skip-memory --no-gitignore "$TEST_WF"
  [ "$status" -eq 0 ]
  [ ! -f "$TEST_REPO/.gitignore" ]
  [[ "$output" != *"kit-managed block"* ]]
}

@test "--no-gitignore opt-out leaves existing .gitignore untouched" {
  printf 'node_modules/\n*.log\n' > "$TEST_REPO/.gitignore"
  before="$(cat "$TEST_REPO/.gitignore")"
  run "$BOOTSTRAP" --skip-memory --no-gitignore "$TEST_WF"
  [ "$status" -eq 0 ]
  after="$(cat "$TEST_REPO/.gitignore")"
  [ "$before" = "$after" ]
}

@test "--dry-run previews kit-managed block creation when .gitignore absent" {
  [ ! -f "$TEST_REPO/.gitignore" ]
  run "$BOOTSTRAP" --dry-run --skip-memory "$TEST_WF"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Would create repo .gitignore"* ]]
  [[ "$output" == *"kit-managed block"* ]]
  [ ! -f "$TEST_REPO/.gitignore" ]
}

@test "--dry-run previews append when .gitignore exists without kit block" {
  printf 'node_modules/\n' > "$TEST_REPO/.gitignore"
  run "$BOOTSTRAP" --dry-run --skip-memory "$TEST_WF"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Would update repo .gitignore"* ]]
  [[ "$output" == *"append kit-managed block"* ]]
  # No write happened.
  [ "$(cat "$TEST_REPO/.gitignore")" = "$(printf 'node_modules/\n')" ]
}

@test "--dry-run reports already-managed when kit block is present" {
  "$BOOTSTRAP" --skip-memory "$TEST_WF" >/dev/null
  run "$BOOTSTRAP" --dry-run --skip-memory --force "$TEST_WF"
  [ "$status" -eq 0 ]
  [[ "$output" == *"kit-managed block already present"* ]]
}

@test "--dry-run with --no-gitignore prints no gitignore preview lines" {
  run "$BOOTSTRAP" --dry-run --skip-memory --no-gitignore "$TEST_WF"
  [ "$status" -eq 0 ]
  [[ "$output" != *".gitignore"* ]]
}

@test "block uses em-dash markers consistent with rest of kit" {
  run "$BOOTSTRAP" --skip-memory "$TEST_WF"
  [ "$status" -eq 0 ]
  # Em-dash (U+2014), not hyphen.
  grep -Fq "claude-project-kit — managed block" "$TEST_REPO/.gitignore"
}

@test "--help mentions --no-gitignore flag" {
  run "$BOOTSTRAP" --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"--no-gitignore"* ]]
}

@test "appended block normalizes spacing when prior file lacks trailing newline" {
  # File without a final newline is a common real-world shape (e.g. printf-only
  # or hand-edited). Bootstrap should still produce a clean separation rather
  # than concatenating onto the last line.
  printf 'node_modules/' > "$TEST_REPO/.gitignore"
  run "$BOOTSTRAP" --skip-memory "$TEST_WF"
  [ "$status" -eq 0 ]
  # The "node_modules/" entry must remain a standalone line, not glued to "#".
  grep -Fxq "node_modules/" "$TEST_REPO/.gitignore"
}
