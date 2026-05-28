#!/usr/bin/env bash
# claude-project-kit hook — block forbidden commit-format patterns.
# Wired in ~/.claude/settings.json as a PreToolUse Bash hook.
# Receives Claude Code tool input as JSON on stdin; outputs a deny decision
# JSON on stdout if a forbidden pattern is matched, otherwise exits silently.
#
# Patterns blocked (see CONVENTIONS.md / feedback_commit_format memory):
#   - Co-Authored-By: ...Claude (any variant)
#   - Co-Authored-By: ...bot trailer
#   - "Generated with Claude Code" / 🤖 markers
#   - --no-verify           (bypassing pre-commit hooks)
#   - --no-gpg-sign         (bypassing GPG signing)
#   - commit.gpgsign=false  (same, via `git -c` override)
#
# Triggered by claude-project-kit issue #204's Option C: hooks are the only
# structural enforcement for these rules — memory/preferences can't reach
# the harness. Pattern surfaced as 6 violations across 4 repos in 2 days.

set -uo pipefail

cmd=$(jq -r '.tool_input.command // empty' 2>/dev/null || printf '')
[ -n "$cmd" ] || exit 0

# False-positive avoidance: gh write-subcommands legitimately carry the
# forbidden patterns inside their --body / --notes args (issue/PR bodies and
# release notes routinely DESCRIBE these rules — that's not a commit). Let
# them through. Anything else (including `git commit ...`, `echo ...`,
# direct shell writes) still goes through the pattern check.
case "$cmd" in
  *"gh issue create"*|*"gh issue edit"*|*"gh issue comment"*) exit 0 ;;
  *"gh pr create"*|*"gh pr edit"*|*"gh pr comment"*)          exit 0 ;;
  *"gh release create"*|*"gh release edit"*)                  exit 0 ;;
esac

patterns=(
  'co-authored-by:.*claude'
  'co-authored-by:.*bot'
  'generated with claude'
  '🤖'
  'commit\.gpgsign=false'
  '--no-gpg-sign'
  '--no-verify'
)
labels=(
  'Co-Authored-By: ...Claude trailer'
  'Co-Authored-By: ...bot trailer'
  '"Generated with Claude Code" marker'
  '🤖 marker (typical of "🤖 Generated with..." trailer)'
  'commit.gpgsign=false (bypasses GPG signing)'
  '--no-gpg-sign (bypasses GPG signing)'
  '--no-verify (bypasses pre-commit hooks)'
)

matched=""
for i in "${!patterns[@]}"; do
  # `--` terminates grep's option parsing so patterns starting with `--`
  # (--no-verify, --no-gpg-sign) aren't read as grep flags. Without this,
  # macOS BSD grep silently fails on those two patterns and the hook
  # would let the most-violated commands through.
  if printf '%s' "$cmd" | grep -qiE -- "${patterns[$i]}"; then
    matched="${labels[$i]}"
    break
  fi
done

if [ -n "$matched" ]; then
  reason="Blocked by claude-project-kit commit-format hook: $matched. The kit's CONVENTIONS.md and feedback_commit_format memory forbid this pattern. Use 'git commit -s -m \"type(scope): subject\"' — single line, no body, no co-author trailer, no --no-verify / --no-gpg-sign / commit.gpgsign=false bypass. If a pre-commit hook is failing, fix the underlying issue rather than bypassing it. If you genuinely need to bypass for a specific commit (very rare), ask the user to disable the hook temporarily."
  jq -n --arg r "$reason" '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:$r}}'
  exit 0
fi

exit 0
