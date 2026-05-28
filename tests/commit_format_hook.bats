#!/usr/bin/env bats
# scripts/block-forbidden-commit-patterns.sh — the PreToolUse Bash hook that
# enforces the kit's commit-format rules (#236 / #204 Option C).
#
# Tests pipe a synthetic Claude Code hook-input JSON to the script and check
# whether it emits a deny-decision JSON (block) or exits silently (allow).
# Two regression guards are explicit because both bugs hit during local
# install before the test suite existed:
#
#   1. macOS BSD grep silently fails on patterns starting with `--`
#      (--no-verify, --no-gpg-sign) unless `--` end-of-options is passed.
#      Without the guard the most-violated commands quietly bypass the hook.
#
#   2. `gh issue|pr|release create/edit/comment` legitimately carry the
#      forbidden patterns in --body / --notes args (issue/PR bodies
#      describe the very rules we're enforcing). The allowlist must let
#      them through; without it the hook chokes on its own documentation.

load 'helpers'

HOOK="$KIT_ROOT/scripts/block-forbidden-commit-patterns.sh"

# Helper: pipe a synthetic Bash hook-input JSON to the hook script and capture
# both stdout (deny JSON, if any) and exit code.
hook_decision() {
  local cmd="$1"
  printf '{"tool_name":"Bash","tool_input":{"command":%s}}' \
    "$(printf '%s' "$cmd" | jq -Rs .)" \
    | "$HOOK"
}

# Helper: extract the permissionDecision from the script's stdout (empty if
# the script wrote nothing — i.e., allowed the command).
decision() {
  hook_decision "$1" | jq -r '.hookSpecificOutput.permissionDecision // empty' 2>/dev/null
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

@test "hook outputs nothing on benign JSON with no command" {
  run bash -c "printf '%s' '{}' | $HOOK"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

# --- Forbidden patterns (DENY) ---

@test "blocks Co-Authored-By: Claude trailer" {
  [ "$(decision 'git commit -m foo -m "Co-Authored-By: Claude <noreply@anthropic.com>"')" = "deny" ]
}

@test "blocks Co-Authored-By with bot-flavored trailer" {
  [ "$(decision 'git commit -m foo -m "Co-Authored-By: SomeBot <bot@x.com>"')" = "deny" ]
}

@test "blocks Generated with Claude Code marker" {
  [ "$(decision 'git commit -m foo -m "Generated with Claude Code"')" = "deny" ]
}

@test "blocks the 🤖 marker" {
  [ "$(decision 'git commit -m "🤖 some message"')" = "deny" ]
}

@test "blocks commit.gpgsign=false via git -c" {
  [ "$(decision 'git -c commit.gpgsign=false commit -m foo')" = "deny" ]
}

@test "blocks --no-gpg-sign flag (regression: BSD grep --)" {
  # Without `--` terminating grep options, macOS BSD grep treats --no-gpg-sign
  # as a grep flag, errors out, and the hook silently allows the command.
  [ "$(decision 'git commit -m foo --no-gpg-sign')" = "deny" ]
}

@test "blocks --no-verify flag (regression: BSD grep --)" {
  # Same regression as --no-gpg-sign — `--` end-of-options must guard this.
  [ "$(decision 'git commit -m foo --no-verify')" = "deny" ]
}

@test "block reason names which pattern matched" {
  reason=$(hook_decision 'git commit --no-verify' | jq -r '.hookSpecificOutput.permissionDecisionReason')
  [[ "$reason" == *"--no-verify"* ]]
  [[ "$reason" == *"feedback_commit_format"* ]]
  [[ "$reason" == *"git commit -s -m"* ]]
}

# --- Allow cases ---

@test "allows a clean commit (no forbidden tokens)" {
  [ -z "$(decision 'git commit -s -m \"feat(scope): clean message\"')" ]
}

@test "allows unrelated bash commands" {
  [ -z "$(decision 'ls -la')" ]
  [ -z "$(decision 'gh issue list')" ]
  [ -z "$(decision 'git log --oneline -5')" ]
}

# --- gh-allowlist (REGRESSION: false-positive on issue/PR bodies) ---

@test "allows 'gh issue create' even with forbidden patterns in the --body" {
  # Issue bodies legitimately describe these patterns (the rules they enforce).
  # The hook MUST NOT block these.
  [ -z "$(decision 'gh issue create --title foo --body "describes --no-verify and Co-Authored-By: Claude"')" ]
}

@test "allows 'gh pr create' with forbidden patterns in the --body" {
  [ -z "$(decision 'gh pr create --body "explains git commit --no-verify is forbidden"')" ]
}

@test "allows 'gh issue edit' / 'gh pr edit' / 'gh issue comment' / 'gh pr comment'" {
  [ -z "$(decision 'gh issue edit 1 --body "Co-Authored-By: Claude"')" ]
  [ -z "$(decision 'gh pr edit 1 --body "🤖 Generated with Claude Code"')" ]
  [ -z "$(decision 'gh issue comment 1 --body "uses --no-verify"')" ]
  [ -z "$(decision 'gh pr comment 1 --body "uses --no-gpg-sign"')" ]
}

@test "allows 'gh release create' with forbidden patterns in --notes" {
  [ -z "$(decision 'gh release create v1.0.0 --notes "patches Co-Authored-By: bot"')" ]
}

@test "the allowlist does NOT cover 'gh issue view' or 'gh pr view' — but those have no body args, so safe" {
  # Sanity: read-only gh commands aren't in the allowlist explicitly, but they
  # don't carry --body so they can't match the patterns anyway.
  [ -z "$(decision 'gh issue view 1')" ]
}
