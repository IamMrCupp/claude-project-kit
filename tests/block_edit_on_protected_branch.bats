#!/usr/bin/env bats
# scripts/block-edit-on-protected-branch.sh — the PreToolUse Edit/Write hook
# that enforces the kit's "branch first" rule (#248 / #204 sibling to #236).
#
# Tests pipe a synthetic Claude Code hook-input JSON to the script and check
# whether it emits a deny-decision JSON (block) or exits silently (allow).
# Coverage matrix:
#   - Tool dispatch (only Edit/Write/MultiEdit/NotebookEdit fire)
#   - Branch dispatch (main, master block by default; feature branches pass)
#   - Working-folder case (files outside any git repo always pass)
#   - KIT_PROTECTED_BRANCHES env override (custom list, empty list)
#   - New-file path (Write creating a file under a not-yet-existing subdir)
#   - Deny message names branch, repo, override env var

load 'helpers'

HOOK="$KIT_ROOT/scripts/block-edit-on-protected-branch.sh"

setup() {
  # Minimal sandbox — just need a writeable TEST_TMP for git repo fixtures.
  TEST_TMP="$(mktemp -d)"
}

teardown() {
  [ -n "${TEST_TMP:-}" ] && rm -rf "$TEST_TMP"
}

# Helper: pipe synthetic hook-input JSON, capture stdout.
hook_decision() {
  local tool="$1"
  local file_path="$2"
  printf '{"tool_name":"%s","tool_input":{"file_path":%s}}' \
    "$tool" \
    "$(printf '%s' "$file_path" | jq -Rs .)" \
    | "$HOOK"
}

decision() {
  hook_decision "$1" "$2" | jq -r '.hookSpecificOutput.permissionDecision // empty' 2>/dev/null
}

# Helper: stage a git repo at $TEST_TMP/repo with current branch set.
# Sets REPO global.
stage_git_repo() {
  local branch="${1:-main}"
  REPO="$TEST_TMP/repo"
  mkdir -p "$REPO"
  git -C "$REPO" init -q -b "$branch"
  git -C "$REPO" -c user.email=t@t -c user.name=t commit --allow-empty -q -m "init"
  # If init -b isn't supported (older git), rename:
  if [ "$(git -C "$REPO" rev-parse --abbrev-ref HEAD)" != "$branch" ]; then
    git -C "$REPO" branch -m "$branch"
  fi
  echo "tracked content" > "$REPO/tracked.md"
  git -C "$REPO" -c user.email=t@t -c user.name=t add tracked.md
  git -C "$REPO" -c user.email=t@t -c user.name=t commit -q -m "add tracked"
}

# --- Smoke ---

@test "hook script exists and is executable" {
  [ -x "$HOOK" ]
}

@test "hook outputs nothing and exits 0 on empty stdin" {
  run bash -c "printf '' | $HOOK"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "hook outputs nothing on benign JSON with no tool_name" {
  run bash -c "printf '%s' '{}' | $HOOK"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

# --- Tool dispatch (only Edit/Write/MultiEdit/NotebookEdit fire) ---

@test "passes through when tool is Bash" {
  stage_git_repo main
  [ -z "$(decision 'Bash' "$REPO/tracked.md")" ]
}

@test "passes through when tool is Read" {
  stage_git_repo main
  [ -z "$(decision 'Read' "$REPO/tracked.md")" ]
}

# --- Block cases (protected branch) ---

@test "blocks Edit on main" {
  stage_git_repo main
  [ "$(decision 'Edit' "$REPO/tracked.md")" = "deny" ]
}

@test "blocks Write on main" {
  stage_git_repo main
  [ "$(decision 'Write' "$REPO/new-file.md")" = "deny" ]
}

@test "blocks MultiEdit on main" {
  stage_git_repo main
  [ "$(decision 'MultiEdit' "$REPO/tracked.md")" = "deny" ]
}

@test "blocks NotebookEdit on main (notebook_path field)" {
  stage_git_repo main
  REPO_PATH="$REPO/nb.ipynb"
  result=$(printf '{"tool_name":"NotebookEdit","tool_input":{"notebook_path":%s}}' \
    "$(printf '%s' "$REPO_PATH" | jq -Rs .)" \
    | "$HOOK" | jq -r '.hookSpecificOutput.permissionDecision // empty')
  [ "$result" = "deny" ]
}

@test "blocks Edit on master" {
  stage_git_repo master
  [ "$(decision 'Edit' "$REPO/tracked.md")" = "deny" ]
}

@test "blocks Write to a new file under a not-yet-existing subdir on main" {
  stage_git_repo main
  # Subdir doesn't exist yet — hook walks up to find existing ancestor.
  [ "$(decision 'Write' "$REPO/new-subdir/nested/file.md")" = "deny" ]
}

# --- Allow cases ---

@test "allows Edit on a feature branch" {
  stage_git_repo feat/some-work
  [ -z "$(decision 'Edit' "$REPO/tracked.md")" ]
}

@test "allows Edit on fix/* branch" {
  stage_git_repo fix/bug
  [ -z "$(decision 'Edit' "$REPO/tracked.md")" ]
}

@test "allows Edit on a file outside any git repo (working-folder case)" {
  # No git init anywhere — simulates ~/Documents/Claude/Projects/<repo>/CONTEXT.md
  WF="$TEST_TMP/wf"
  mkdir -p "$WF"
  echo "context" > "$WF/CONTEXT.md"
  [ -z "$(decision 'Edit' "$WF/CONTEXT.md")" ]
}

@test "allows Write to a brand-new file in a non-git path" {
  WF="$TEST_TMP/wf"
  mkdir -p "$WF"
  [ -z "$(decision 'Write' "$WF/brand-new.md")" ]
}

# --- KIT_PROTECTED_BRANCHES override ---

@test "KIT_PROTECTED_BRANCHES override: custom list ('production') allows main" {
  stage_git_repo main
  result=$(printf '{"tool_name":"Edit","tool_input":{"file_path":%s}}' \
    "$(printf '%s' "$REPO/tracked.md" | jq -Rs .)" \
    | KIT_PROTECTED_BRANCHES="production" "$HOOK" \
    | jq -r '.hookSpecificOutput.permissionDecision // empty')
  [ -z "$result" ]
}

@test "KIT_PROTECTED_BRANCHES override: empty disables hook entirely" {
  stage_git_repo main
  result=$(printf '{"tool_name":"Edit","tool_input":{"file_path":%s}}' \
    "$(printf '%s' "$REPO/tracked.md" | jq -Rs .)" \
    | KIT_PROTECTED_BRANCHES="" "$HOOK" \
    | jq -r '.hookSpecificOutput.permissionDecision // empty')
  [ -z "$result" ]
}

@test "KIT_PROTECTED_BRANCHES override: custom list still blocks listed branches" {
  stage_git_repo production
  result=$(printf '{"tool_name":"Edit","tool_input":{"file_path":%s}}' \
    "$(printf '%s' "$REPO/tracked.md" | jq -Rs .)" \
    | KIT_PROTECTED_BRANCHES="production staging" "$HOOK" \
    | jq -r '.hookSpecificOutput.permissionDecision // empty')
  [ "$result" = "deny" ]
}

# --- Deny message content ---

@test "deny message names the branch, the repo, and the override env var" {
  stage_git_repo main
  reason=$(hook_decision 'Edit' "$REPO/tracked.md" \
    | jq -r '.hookSpecificOutput.permissionDecisionReason')
  [[ "$reason" == *"branch 'main'"* ]]
  [[ "$reason" == *"$REPO"* ]]
  [[ "$reason" == *"feedback_no_work_on_main"* ]]
  [[ "$reason" == *"git checkout -b"* ]]
  [[ "$reason" == *"KIT_PROTECTED_BRANCHES"* ]]
}
