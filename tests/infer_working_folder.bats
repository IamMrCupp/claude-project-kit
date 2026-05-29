#!/usr/bin/env bats
# scripts/lib/infer.sh::infer_working_folder — read the auto-memory pointer
# file and return the working-folder path. Both absolute and `~/`-prefixed
# pointer forms must be supported; tilde is expanded to $HOME at the
# inference layer (#251).

load 'helpers'

source "$KIT_ROOT/scripts/lib/infer.sh"

# Stage a fake kit project + auto-memory + reference pointer.
# Args:
#   $1 — content of the reference pointer's CONTEXT.md path bullet (the line
#        is written verbatim into reference_ai_working_folder.md).
# Sets globals:
#   FAKE_REPO     — the project repo path
#   MEMORY_DIR    — derived auto-memory dir
#   REF_FILE      — the pointer file inside MEMORY_DIR
stage_memory_pointer() {
  local pointer_line="$1"
  FAKE_REPO="$TEST_TMP/repo"
  mkdir -p "$FAKE_REPO"
  git -C "$FAKE_REPO" init -q

  # The kit's sanitization rule: absolute repo path with `/` and `.` replaced by `-`.
  local sanitized
  sanitized="$(echo "$FAKE_REPO" | sed 's|[/.]|-|g')"
  MEMORY_DIR="$TEST_HOME/.claude/projects/${sanitized}/memory"
  mkdir -p "$MEMORY_DIR"
  REF_FILE="$MEMORY_DIR/reference_ai_working_folder.md"

  cat > "$REF_FILE" <<EOF
---
name: AI working folder for test
type: reference
---
At the start of every session, read:
$pointer_line
EOF
}

setup() {
  TEST_TMP="$(mktemp -d)"
  TEST_HOME="$TEST_TMP/home"
  mkdir -p "$TEST_HOME"
  export HOME="$TEST_HOME"
}

teardown() {
  [ -n "${TEST_TMP:-}" ] && rm -rf "$TEST_TMP"
}

# --- Absolute pointer (existing behavior, regression guard) ---

@test "absolute-path pointer: returns the working-folder directory" {
  WF="$TEST_TMP/wf-absolute"
  mkdir -p "$WF"
  stage_memory_pointer "- \`$WF/CONTEXT.md\` — overview"
  result="$(infer_working_folder "$FAKE_REPO")"
  [ "$result" = "$WF" ]
}

# --- Tilde-prefixed pointer (#251 regression) ---

@test "tilde-prefixed pointer: expands ~/ to \$HOME and returns the directory" {
  # Stage a real WF under $HOME so the expanded path actually exists.
  WF_REL="Documents/Claude/Projects/tilde-test"
  mkdir -p "$HOME/$WF_REL"
  stage_memory_pointer "- \`~/$WF_REL/CONTEXT.md\` — overview (tilde form)"
  result="$(infer_working_folder "$FAKE_REPO")"
  [ "$result" = "$HOME/$WF_REL" ]
}

@test "tilde-prefixed pointer: result is an absolute path, not literal ~" {
  WF_REL="Documents/Claude/Projects/foo"
  mkdir -p "$HOME/$WF_REL"
  stage_memory_pointer "- \`~/$WF_REL/CONTEXT.md\` — overview"
  result="$(infer_working_folder "$FAKE_REPO")"
  # Must NOT begin with literal tilde — must be fully expanded.
  [[ "$result" != \~* ]]
  [[ "$result" == /* ]]
}

# --- Edge cases ---

@test "no pointer file: returns empty" {
  FAKE_REPO="$TEST_TMP/no-memory-repo"
  mkdir -p "$FAKE_REPO"
  git -C "$FAKE_REPO" init -q
  result="$(infer_working_folder "$FAKE_REPO")"
  [ -z "$result" ]
}

@test "pointer file present but no /CONTEXT.md match: returns empty" {
  stage_memory_pointer "- this line has no backtick-quoted CONTEXT.md path"
  result="$(infer_working_folder "$FAKE_REPO")"
  [ -z "$result" ]
}

@test "multiple pointer lines: first match wins (deterministic)" {
  FAKE_REPO="$TEST_TMP/repo"
  mkdir -p "$FAKE_REPO"
  git -C "$FAKE_REPO" init -q
  local sanitized
  sanitized="$(echo "$FAKE_REPO" | sed 's|[/.]|-|g')"
  MEMORY_DIR="$TEST_HOME/.claude/projects/${sanitized}/memory"
  mkdir -p "$MEMORY_DIR"
  REF_FILE="$MEMORY_DIR/reference_ai_working_folder.md"
  WF_FIRST="$TEST_TMP/wf-first"
  WF_SECOND="$TEST_TMP/wf-second"
  mkdir -p "$WF_FIRST" "$WF_SECOND"
  cat > "$REF_FILE" <<EOF
- \`$WF_FIRST/CONTEXT.md\` — first match
- \`$WF_SECOND/CONTEXT.md\` — second match
EOF
  result="$(infer_working_folder "$FAKE_REPO")"
  [ "$result" = "$WF_FIRST" ]
}
