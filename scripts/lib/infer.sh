#!/usr/bin/env bash
# Shared inference helpers for the kit's helper scripts.
#
# Source-able from sync-memory.sh, sync-templates.sh, rename-workspace.sh —
# any helper that today takes an explicit path and could reasonably infer it
# from $PWD when run inside a kit-bootstrapped repo.
#
# Functions are pure (no side effects, no exits) so the calling script
# decides how to handle empty returns. All return paths use absolute,
# unresolved-symlink form to match bootstrap.sh's sanitization rule
# (sed 's|/|-|g').
#
# Conventions:
#   - All functions take an optional first arg (defaults to $PWD).
#   - Empty stdout = could not infer. Caller must check.
#   - Functions never error / never call exit. Caller decides.

# Sanitize a filesystem path the way the Claude harness keys auto-memory:
# replace `/` with `-`. Result is the directory name under
# ~/.claude/projects/.
sanitize_path_for_memory() {
  echo "$1" | sed 's|/|-|g'
}

# Walk up from $1 (default $PWD) to find a directory that contains .git.
# Echoes the repo root on success. Echoes the original $1 (or $PWD) if no
# .git is found in any ancestor, since some target repos may not be git
# repos at all.
find_repo_root() {
  local start="${1:-$PWD}"
  local dir="$start"
  while [ "$dir" != "/" ] && [ -n "$dir" ]; do
    if [ -d "$dir/.git" ]; then
      echo "$dir"
      return 0
    fi
    dir="$(dirname "$dir")"
  done
  echo "$start"
}

# Echo the auto-memory dir for a given repo path (default: walk up from
# $PWD to find the repo root). Does NOT check that the dir exists; callers
# decide how to handle missing dirs.
infer_memory_dir() {
  local start="${1:-$PWD}"
  local repo
  repo="$(find_repo_root "$start")"
  local sanitized
  sanitized="$(sanitize_path_for_memory "$repo")"
  echo "$HOME/.claude/projects/${sanitized}/memory"
}

# Echo the working-folder path for the kit-bootstrapped project rooted at
# $1 (default $PWD).
#
# Strategy: read reference_ai_working_folder.md from the repo's auto-memory
# and extract the first backtick-quoted absolute path ending in /CONTEXT.md.
# Strip the trailing /CONTEXT.md and return the parent directory.
#
# Returns empty string on any failure (no memory dir, no reference file,
# no parseable path). Does not error.
infer_working_folder() {
  local start="${1:-$PWD}"
  local memory_dir
  memory_dir="$(infer_memory_dir "$start")"
  local ref_file="$memory_dir/reference_ai_working_folder.md"
  [ -f "$ref_file" ] || return 0

  # Match: backtick + / + non-backtick chars + /CONTEXT.md + backtick.
  # Example line in memory file:
  #   - `/Users/x/Documents/Claude/Projects/foo/CONTEXT.md` — overview...
  local match
  match="$(grep -oE '`/[^`]+/CONTEXT\.md`' "$ref_file" 2>/dev/null | head -1)"
  [ -n "$match" ] || return 0

  # Strip surrounding backticks and trailing /CONTEXT.md
  match="${match#\`}"
  match="${match%\`}"
  match="${match%/CONTEXT.md}"
  echo "$match"
}

# Echo the workspace root for the project at $1 (default $PWD). Workspace
# root = the directory containing workspace-CONTEXT.md.
#
# Tries three strategies in order:
#   1. $dir itself is a workspace root.
#   2. $dir's parent is a workspace root (i.e. $dir is a per-repo subfolder
#      of a workspace).
#   3. $dir is a kit-bootstrapped repo whose working folder is per-repo
#      under a workspace — infer the working folder via auto-memory, then
#      check the working folder's parent for workspace-CONTEXT.md.
#
# Returns empty string if none of the strategies find a workspace root.
infer_workspace_root() {
  local start="${1:-$PWD}"

  if [ -f "$start/workspace-CONTEXT.md" ]; then
    echo "$start"
    return 0
  fi

  if [ -f "$start/../workspace-CONTEXT.md" ]; then
    (cd "$start/.." && pwd)
    return 0
  fi

  local wf
  wf="$(infer_working_folder "$start")"
  if [ -n "$wf" ] && [ -f "$wf/../workspace-CONTEXT.md" ]; then
    (cd "$wf/.." && pwd)
    return 0
  fi

  return 0
}
