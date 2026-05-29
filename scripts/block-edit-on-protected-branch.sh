#!/usr/bin/env bash
# claude-project-kit hook — block Edit/Write/MultiEdit/NotebookEdit on
# protected branches (default: main, master).
# Wired in ~/.claude/settings.json as a PreToolUse hook with matcher
# "Edit|Write|MultiEdit|NotebookEdit". Receives Claude Code tool input as
# JSON on stdin; outputs a deny decision JSON on stdout if the edit targets
# a tracked file on a protected branch, otherwise exits silently.
#
# Behavior:
#   - Only fires when tool_name is Edit / Write / MultiEdit / NotebookEdit.
#   - file_path (or notebook_path for NotebookEdit) must resolve into a git
#     work-tree. Files outside any git repo (private working folders at
#     ~/Documents/Claude/Projects/<repo>/...) are always allowed — they're
#     deliberately untracked.
#   - Current branch of the resolved work-tree is checked against the
#     protected list. Match → deny; no match → allow.
#   - Walks up from $FILE_PATH to find an existing ancestor dir before
#     asking git, so new-file paths (Write creating a fresh file) work.
#
# Configurable:
#   KIT_PROTECTED_BRANCHES (env, default "main master")
#     Space-separated branch names to block. Override per-session if you
#     genuinely need to edit on main (very rare — the hook exists because
#     "I'll just be careful" historically didn't hold).
#
# Triggered by claude-project-kit issue #248 (sibling to #236 commit-format
# hook). Memory + slash-command guards (#204 / #222) cover the rule as
# guidance, but the harness only enforces what hooks reject. Pattern
# surfaced as 3+ sessions opening on main since v1.0.0 shipped.

set -uo pipefail

INPUT="$(cat)"
TOOL_NAME=$(printf '%s' "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null || printf '')
case "$TOOL_NAME" in
  Edit|Write|MultiEdit|NotebookEdit) ;;
  *) exit 0 ;;
esac

FILE_PATH=$(printf '%s' "$INPUT" \
  | jq -r '.tool_input.file_path // .tool_input.notebook_path // empty' 2>/dev/null \
  || printf '')
[ -n "$FILE_PATH" ] || exit 0

# Walk up from $FILE_PATH to find an existing ancestor directory before
# asking git. Handles both "edit existing file" (dir = dirname of file) and
# "Write a new file under a fresh subdir" (walk up until something exists).
DIR="$FILE_PATH"
while [ ! -d "$DIR" ] && [ "$DIR" != "/" ] && [ -n "$DIR" ]; do
  DIR=$(dirname "$DIR")
done
[ -d "$DIR" ] || exit 0

GIT_ROOT=$(git -C "$DIR" rev-parse --show-toplevel 2>/dev/null || true)
[ -n "$GIT_ROOT" ] || exit 0   # outside any git repo — allow

BRANCH=$(git -C "$GIT_ROOT" rev-parse --abbrev-ref HEAD 2>/dev/null || true)
[ -n "$BRANCH" ] || exit 0     # detached HEAD or unborn — don't block

PROTECTED="${KIT_PROTECTED_BRANCHES-main master}"
[ -n "$PROTECTED" ] || exit 0  # user explicitly opted out for this session

for p in $PROTECTED; do
  if [ "$BRANCH" = "$p" ]; then
    reason="Blocked by claude-project-kit branch-first hook: editing on protected branch '$BRANCH' in $GIT_ROOT. The kit's CONVENTIONS.md and feedback_no_work_on_main memory require a feature branch before any edit to tracked files. Create one and switch: 'git checkout -b <type>/<slug>' (feat/, fix/, docs/, ci/, chore/). Read-only work and edits to files outside any git repo (e.g. private working folders) are not blocked. To override for this session, set KIT_PROTECTED_BRANCHES to a list that excludes '$BRANCH' (or to empty to disable entirely)."
    jq -n --arg r "$reason" '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:$r}}'
    exit 0
  fi
done
exit 0
