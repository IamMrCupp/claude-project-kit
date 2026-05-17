#!/usr/bin/env bash
# Print the absolute path of the current project's auto-memory pointer file
# (reference_ai_working_folder.md) — the canonical entry point for kit slash
# commands and agents to discover the project's working folder.
#
# Why a separate script:
#   Inlining this logic in slash-command markdown produces a compound Bash
#   call (chained with && / || / $()) that Claude Code's permission matcher
#   cannot statically decompose — so every fresh session hits a permission
#   prompt that no allowlist rule can silence. A single non-compound script
#   invocation IS matchable; the kit's bootstrap installs an absolute-path
#   `permissions.allow` entry pointing here so the prompt disappears.
#   See issue #218 + bug #16800 in anthropics/claude-code.
#
# Behavior (matches the previous inline snippet exactly):
#   - In a git worktree:   walks up to the parent repo via
#     `git rev-parse --path-format=absolute --git-common-dir` (returns the
#     parent repo's .git for both regular and linked worktrees), then takes
#     dirname. This matches the kit's worktree-aware fix from #210.
#   - Outside any git repo: falls back to $PWD.
#   - Sanitizes both `/` and `.` to `-` (matching Claude Code's runtime
#     sanitization rule — fixed in #205) before building the auto-memory
#     project key.
#   - Emits exactly one line to stdout: the absolute path of the pointer
#     file (whether or not it exists on disk — the caller decides).
#
# Exit code is always 0 unless the shell itself fails — the caller (slash
# command precheck) decides what to do when the path doesn't exist.
set -u

GIT_COMMON_DIR=$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null) || GIT_COMMON_DIR=""

if [ -n "$GIT_COMMON_DIR" ]; then
  REPO_ROOT=$(dirname "$GIT_COMMON_DIR")
else
  REPO_ROOT="$PWD"
fi

SANITIZED=$(echo "$REPO_ROOT" | sed 's|[/.]|-|g')

echo "$HOME/.claude/projects/$SANITIZED/memory/reference_ai_working_folder.md"
