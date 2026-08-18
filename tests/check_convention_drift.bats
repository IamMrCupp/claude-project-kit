#!/usr/bin/env bats
# Tests for scripts/check-convention-drift.sh (#258, fix 3).
#
# The script is read-only: it flags when a CONTEXT.md convention contradicts
# the auto-memory feedback_* that owns it. Auto-memory is the source of truth.

load 'helpers'

SCRIPT="$KIT_ROOT/scripts/check-convention-drift.sh"

setup() {
  bootstrap_setup           # gives TEST_REPO (cwd), TEST_HOME, memory_dir()
  MEM="$(memory_dir)"
  WF="$TEST_TMP/wf"
  mkdir -p "$MEM" "$WF"
  # The kit's canonical merge-strategy memory: asserts merge commit.
  cat > "$MEM/feedback_merge_strategy.md" <<'EOF'
---
name: PR merge strategy — always merge commits
description: Always use "Create a merge commit". Never squash or rebase-merge.
type: feedback
---
When merging PRs, always choose "Create a merge commit". Never squash-merge.
EOF
}

teardown() { bootstrap_teardown; }

# A CONTEXT.md with the given Working Rules body.
write_context() {
  cat > "$WF/CONTEXT.md" <<EOF
# Claude Working Context
## Working Rules
### Git & commits
$1
## Current Phase Status
done
EOF
}

@test "script is executable" {
  [ -x "$SCRIPT" ]
}

@test "flags a stale squash directive in CONTEXT vs a merge-commit memory" {
  write_context "- Merge strategy: squash merge into main"
  run "$SCRIPT" "$WF"
  [ "$status" -eq 1 ]
  echo "$output" | grep -q "CONFLICT" || { echo "$output"; return 1; }
  echo "$output" | grep -qi "merge strategy" || return 1
}

@test "passes when CONTEXT points at memory instead of restating the rule" {
  write_context "- Merge strategy → see feedback_merge_strategy"
  run "$SCRIPT" "$WF"
  [ "$status" -eq 0 ]
  echo "$output" | grep -qi "no convention drift" || { echo "$output"; return 1; }
}

@test "does not flag a negated mention (never squash) in CONTEXT" {
  write_context "- Merge strategy: always merge commit, never squash"
  run "$SCRIPT" "$WF"
  [ "$status" -eq 0 ]
}

@test "flags the reverse: memory flipped to squash, CONTEXT still says merge commit" {
  cat > "$MEM/feedback_merge_strategy.md" <<'EOF'
---
name: PR merge strategy — squash
description: Always squash-merge. Never use a merge commit.
type: feedback
---
Squash-merge every PR. Never create a merge commit.
EOF
  write_context "- Merge strategy: create a merge commit on every PR"
  run "$SCRIPT" "$WF"
  [ "$status" -eq 1 ]
  echo "$output" | grep -q "CONFLICT" || { echo "$output"; return 1; }
}

@test "exits 0 (graceful) when no working folder CONTEXT.md is found" {
  run "$SCRIPT" "$TEST_TMP/does-not-exist"
  [ "$status" -eq 0 ]
  echo "$output" | grep -qi "nothing to check" || { echo "$output"; return 1; }
}

@test "exits 0 when the owning memory file is absent" {
  rm -f "$MEM/feedback_merge_strategy.md"
  write_context "- Merge strategy: squash merge into main"
  run "$SCRIPT" "$WF"
  [ "$status" -eq 0 ]
}

@test "also scans workspace-CONTEXT.md Cross-repo notes" {
  write_context "- Merge strategy → see feedback_merge_strategy"
  cat > "$TEST_TMP/workspace-CONTEXT.md" <<'EOF'
# Workspace
## Cross-repo notes
- All repos squash-merge into main.
## Reference
x
EOF
  # WF parent must be the workspace dir; point WF at a subdir of TEST_TMP.
  mkdir -p "$TEST_TMP/repo-a"
  mv "$WF/CONTEXT.md" "$TEST_TMP/repo-a/CONTEXT.md"
  run "$SCRIPT" "$TEST_TMP/repo-a"
  [ "$status" -eq 1 ]
  echo "$output" | grep -q "CONFLICT" || { echo "$output"; return 1; }
}

@test "-h prints usage and exits 2" {
  run "$SCRIPT" -h
  [ "$status" -eq 2 ]
  echo "$output" | grep -qi "check-convention-drift" || return 1
}

# --- Regression tests for the review of 2026-08-17 ---------------------------
# Three defects found by probing the paths the original tests didn't cover:
# a bare-"no" negation read as an assertion, an exact-match heading that
# silently disabled the scan, and a success message printed when nothing was
# actually compared.

# A CONTEXT.md with a caller-chosen "## <heading>" section.
write_context_heading() {
  cat > "$WF/CONTEXT.md" <<EOF
# Claude Working Context
## $1
### Git & commits
$2
## Current Phase Status
done
EOF
}

@test "does not flag the bare 'no squash' negation form" {
  write_context "- Merge strategy: merge commits only, no squash"
  run "$SCRIPT" "$WF"
  [ "$status" -eq 0 ]
  echo "$output" | grep -qi "no convention drift" || { echo "$output"; return 1; }
}

@test "bare-'no' negator is word-anchored — a word ending in 'no' does not suppress a real conflict" {
  write_context "- Casino rules aside, merge strategy is: squash merge into main"
  run "$SCRIPT" "$WF"
  [ "$status" -eq 1 ]
  echo "$output" | grep -q "CONFLICT" || { echo "$output"; return 1; }
}

@test "heading match is case-insensitive — '## Working rules' still gets scanned" {
  write_context_heading "Working rules" "- Merge strategy: squash merge into main"
  run "$SCRIPT" "$WF"
  [ "$status" -eq 1 ]
  echo "$output" | grep -q "CONFLICT" || { echo "$output"; return 1; }
}

@test "heading match tolerates trailing whitespace" {
  printf '# Ctx\n## Working Rules   \n- Merge strategy: squash merge into main\n## Next\nx\n' > "$WF/CONTEXT.md"
  run "$SCRIPT" "$WF"
  [ "$status" -eq 1 ]
  echo "$output" | grep -q "CONFLICT" || { echo "$output"; return 1; }
}

@test "a missing Working Rules section reports 'nothing to compare', not 'no drift'" {
  write_context_heading "Some Other Section" "- Merge strategy: squash merge into main"
  run "$SCRIPT" "$WF"
  [ "$status" -eq 0 ]
  echo "$output" | grep -qi "nothing to compare" || { echo "$output"; return 1; }
  echo "$output" | grep -qi "no convention drift" && { echo "claimed clean while blind: $output"; return 1; }
  return 0
}

@test "an ambiguous memory reports 'nothing to compare', not 'no drift'" {
  cat > "$MEM/feedback_merge_strategy.md" <<'EOF'
---
name: undecided
description: Team has not settled this.
type: feedback
---
Not squash. Not a merge commit. See the team wiki.
EOF
  write_context "- Merge strategy: squash merge into main"
  run "$SCRIPT" "$WF"
  [ "$status" -eq 0 ]
  echo "$output" | grep -qi "nothing to compare" || { echo "$output"; return 1; }
  echo "$output" | grep -qi "no convention drift" && { echo "claimed clean while blind: $output"; return 1; }
  return 0
}

@test "the clean message reports how many conventions were actually compared" {
  write_context "- Merge strategy → see feedback_merge_strategy"
  run "$SCRIPT" "$WF"
  [ "$status" -eq 0 ]
  echo "$output" | grep -qE "1 convention\(s\) compared" || { echo "$output"; return 1; }
}
