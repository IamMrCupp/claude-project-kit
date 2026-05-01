#!/usr/bin/env bats
# bootstrap.sh appends a factual "Bootstrap" entry to <working-folder>/SESSION-LOG.md
# so the bootstrap session is durable even if a hand-off interrupts before
# /session-end runs.

load 'helpers'

setup() { bootstrap_setup; }
teardown() { bootstrap_teardown; }

@test "bootstrap appends a Bootstrap entry to SESSION-LOG.md" {
  run "$BOOTSTRAP" "$TEST_WF" --skip-memory
  [ "$status" -eq 0 ]

  [ -f "$TEST_WF/SESSION-LOG.md" ]
  grep -qE '^## Session: [0-9]{4}-[0-9]{2}-[0-9]{2} — Bootstrap$' "$TEST_WF/SESSION-LOG.md"
  grep -q '\*\*Focus:\*\* Initial bootstrap' "$TEST_WF/SESSION-LOG.md"
  grep -q '\*\*Bootstrap config:\*\*' "$TEST_WF/SESSION-LOG.md"
  grep -q '\*\*Open threads / next steps:\*\*' "$TEST_WF/SESSION-LOG.md"
}

@test "Bootstrap entry records single-repo mode by default" {
  run "$BOOTSTRAP" "$TEST_WF" --skip-memory
  [ "$status" -eq 0 ]
  grep -q '^- Mode: single-repo$' "$TEST_WF/SESSION-LOG.md"
  grep -q "^- Working folder: \`$TEST_WF\`$" "$TEST_WF/SESSION-LOG.md"
  grep -q "^- Repo: \`$TEST_REPO\`$" "$TEST_WF/SESSION-LOG.md"
}

@test "Bootstrap entry records tracker config when set" {
  run "$BOOTSTRAP" "$TEST_WF" --skip-memory --tracker jira --jira-project INFRA
  [ "$status" -eq 0 ]
  grep -q '^- Tracker: jira (project: INFRA)$' "$TEST_WF/SESSION-LOG.md"
}

@test "Bootstrap entry records linear tracker key" {
  run "$BOOTSTRAP" "$TEST_WF" --skip-memory --tracker linear --linear-team ENG
  [ "$status" -eq 0 ]
  grep -q '^- Tracker: linear (team: ENG)$' "$TEST_WF/SESSION-LOG.md"
}

@test "Bootstrap entry records CI tool when set" {
  run "$BOOTSTRAP" "$TEST_WF" --skip-memory --ci github-actions
  [ "$status" -eq 0 ]
  grep -q '^- CI: github-actions$' "$TEST_WF/SESSION-LOG.md"
}

@test "Bootstrap entry records 'none' tracker and CI when not set" {
  run "$BOOTSTRAP" "$TEST_WF" --skip-memory
  [ "$status" -eq 0 ]
  grep -q '^- Tracker: (none)$' "$TEST_WF/SESSION-LOG.md"
  grep -q '^- CI: (none)$' "$TEST_WF/SESSION-LOG.md"
}

@test "Bootstrap entry records skipped memory when --skip-memory" {
  run "$BOOTSTRAP" "$TEST_WF" --skip-memory
  [ "$status" -eq 0 ]
  grep -q '^- Auto-memory: skipped (--skip-memory)$' "$TEST_WF/SESSION-LOG.md"
  # Memory tuning step should NOT appear when skipped
  ! grep -q 'Tune auto-memory' "$TEST_WF/SESSION-LOG.md"
}

@test "Bootstrap entry records auto-memory path when seeded" {
  run "$BOOTSTRAP" "$TEST_WF"
  [ "$status" -eq 0 ]
  MEM="$(memory_dir)"
  grep -q "^- Auto-memory: $MEM$" "$TEST_WF/SESSION-LOG.md"
  grep -q 'Tune auto-memory' "$TEST_WF/SESSION-LOG.md"
}

@test "Bootstrap entry includes a kit-version line" {
  run "$BOOTSTRAP" "$TEST_WF" --skip-memory
  [ "$status" -eq 0 ]
  grep -qE '^- Kit version: ' "$TEST_WF/SESSION-LOG.md"
}

@test "Bootstrap entry includes a Next session prompt block" {
  run "$BOOTSTRAP" "$TEST_WF" --skip-memory
  [ "$status" -eq 0 ]
  grep -qF '**Next session prompt:**' "$TEST_WF/SESSION-LOG.md"
  grep -q 'Load context and give me a 3-bullet summary' "$TEST_WF/SESSION-LOG.md"
  grep -q 'running the SEED-PROMPT' "$TEST_WF/SESSION-LOG.md"
}

@test "Bootstrap entry includes seed-prompt next step" {
  run "$BOOTSTRAP" "$TEST_WF" --skip-memory
  [ "$status" -eq 0 ]
  grep -q "Follow the instructions in $TEST_WF/SEED-PROMPT.md" "$TEST_WF/SESSION-LOG.md"
}

@test "workspace first-repo bootstrap entry records workspace mode + sibling-repo step" {
  WS="$TEST_TMP/lx-platform"
  REPO_NAME="$(basename "$TEST_REPO")"
  run "$BOOTSTRAP" --workspace "$WS" --skip-memory
  [ "$status" -eq 0 ]

  PER_REPO="$WS/$REPO_NAME"
  grep -q '^- Mode: workspace (new — first repo)$' "$PER_REPO/SESSION-LOG.md"
  grep -q "^- Workspace: \`$WS\`$" "$PER_REPO/SESSION-LOG.md"
  grep -q "^- Repo subfolder: \`$REPO_NAME\`" "$PER_REPO/SESSION-LOG.md"
  grep -q "re-run \`bootstrap.sh --workspace $WS\`" "$PER_REPO/SESSION-LOG.md"
}

@test "workspace second-repo bootstrap entry records added-repo mode" {
  WS="$TEST_TMP/lx-platform"

  # First run establishes workspace
  run "$BOOTSTRAP" --workspace "$WS" --skip-memory
  [ "$status" -eq 0 ]

  # Sibling repo
  REPO2="$TEST_TMP/repo2"
  mkdir -p "$REPO2"
  git -C "$REPO2" init -q
  cd "$REPO2"

  run "$BOOTSTRAP" --workspace "$WS" --skip-memory
  [ "$status" -eq 0 ]

  grep -q '^- Mode: workspace (added repo to existing workspace)$' "$WS/repo2/SESSION-LOG.md"
}

@test "--dry-run does NOT write a Bootstrap entry" {
  run "$BOOTSTRAP" --dry-run "$TEST_WF" --skip-memory
  [ "$status" -eq 0 ]
  [ ! -d "$TEST_WF" ]
}

@test "templates/SESSION-LOG.md no longer contains the placeholder Initial setup entry" {
  # The kit's own SESSION-LOG.md template should not ship an unfilled
  # "Initial setup" entry — that's bootstrap's job to write factually.
  ! grep -q '## Session: {{YYYY-MM-DD}} — Initial setup' "$KIT_ROOT/templates/SESSION-LOG.md"
}
