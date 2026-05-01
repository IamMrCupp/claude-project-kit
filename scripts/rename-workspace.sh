#!/usr/bin/env bash
# Rename a kit workspace folder: mv the workspace tree AND fix up the
# per-repo auto-memory files that pin the old path.
#
# Why this exists: per-repo auto-memory at
# ~/.claude/projects/<sanitized-repo-path>/memory/reference_ai_working_folder.md
# contains the workspace-relative {{WORKING_FOLDER}} path baked in at bootstrap
# time. The memory directory is keyed off the *repo* path (not the workspace
# path), so a naive `mv` of the workspace directory leaves stale path references
# in those memory files. This helper does the mv and the memory rewrite atomically.
#
# Prose inside the workspace tree itself (workspace-CONTEXT.md, per-repo
# CONTEXT.md, SESSION-LOG.md, etc.) is NOT auto-rewritten — those files may
# legitimately reference the old path in historical entries. The helper greps
# and reports matches so the user can review and edit by hand if appropriate.
set -euo pipefail

if [ -z "${BASH_VERSION:-}" ]; then
  echo "error: rename-workspace.sh requires bash" >&2
  exit 1
fi

usage() {
  cat <<EOF
Usage: rename-workspace.sh [options] <old-workspace-path> <new-workspace-path>

Rename a kit workspace folder. Both paths must be absolute. The old path must
exist and contain workspace-CONTEXT.md (i.e. it must have been bootstrapped
with --workspace). The new path must NOT already exist.

What happens:
  1. mv <old-workspace-path> <new-workspace-path>
  2. Rewrite per-repo auto-memory files (~/.claude/projects/.../memory/*.md)
     that contained <old-workspace-path>, replacing it with <new-workspace-path>.
  3. Grep the moved workspace tree for any remaining <old-workspace-path>
     string matches (in workspace-CONTEXT.md, per-repo CONTEXT.md, etc.) and
     REPORT them — these are NOT auto-rewritten since prose may legitimately
     reference history.

Options:
  --dry-run     Show what would change. No mv, no memory edits.
  -h, --help    Show this help and exit.

Examples:
  # Rename ~/Documents/Claude/Projects/old-name to ...new-name
  rename-workspace.sh \\
    ~/Documents/Claude/Projects/old-name \\
    ~/Documents/Claude/Projects/new-name

  # Preview without writing
  rename-workspace.sh --dry-run \\
    ~/Documents/Claude/Projects/old-name \\
    ~/Documents/Claude/Projects/new-name
EOF
}

DRY_RUN=0
OLD=""
NEW=""

while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run) DRY_RUN=1; shift ;;
    -h|--help) usage; exit 0 ;;
    --*) echo "error: unknown option: $1" >&2; usage >&2; exit 2 ;;
    *)
      if [ -z "$OLD" ]; then
        OLD="$1"
      elif [ -z "$NEW" ]; then
        NEW="$1"
      else
        echo "error: unexpected extra argument: $1" >&2
        usage >&2
        exit 2
      fi
      shift
      ;;
  esac
done

if [ -z "$OLD" ] || [ -z "$NEW" ]; then
  echo "error: both <old-workspace-path> and <new-workspace-path> are required" >&2
  usage >&2
  exit 2
fi

# Tilde expansion (in case argument was literal "~/...")
case "$OLD" in
  "~") OLD="$HOME" ;;
  "~/"*) OLD="$HOME/${OLD#"~/"}" ;;
esac
case "$NEW" in
  "~") NEW="$HOME" ;;
  "~/"*) NEW="$HOME/${NEW#"~/"}" ;;
esac

case "$OLD" in /*) ;; *) echo "error: old path must be absolute (got: $OLD)" >&2; exit 2 ;; esac
case "$NEW" in /*) ;; *) echo "error: new path must be absolute (got: $NEW)" >&2; exit 2 ;; esac

# Strip trailing slashes for consistent string-replacement
OLD="${OLD%/}"
NEW="${NEW%/}"

if [ "$OLD" = "$NEW" ]; then
  echo "error: old and new paths are identical" >&2
  exit 2
fi

if [ ! -d "$OLD" ]; then
  echo "error: old workspace path does not exist or is not a directory: $OLD" >&2
  exit 2
fi

if [ ! -f "$OLD/workspace-CONTEXT.md" ]; then
  echo "error: $OLD does not look like a kit workspace (no workspace-CONTEXT.md)" >&2
  exit 2
fi

if [ -e "$NEW" ]; then
  echo "error: new workspace path already exists: $NEW" >&2
  echo "       Refusing to overwrite. Choose a different new path." >&2
  exit 2
fi

# Find auto-memory files that contain the old workspace path. The memory dir
# layout (per Claude harness): ~/.claude/projects/<sanitized-repo-path>/memory/*.md.
MEMORY_ROOT="$HOME/.claude/projects"
AFFECTED_MEMORY_FILES=()
if [ -d "$MEMORY_ROOT" ]; then
  while IFS= read -r f; do
    [ -n "$f" ] && AFFECTED_MEMORY_FILES+=("$f")
  done < <(grep -rl -F "$OLD" "$MEMORY_ROOT" 2>/dev/null || true)
fi

echo "Workspace rename plan"
echo "  Old: $OLD"
echo "  New: $NEW"
echo

if [ "${#AFFECTED_MEMORY_FILES[@]}" -eq 0 ]; then
  echo "  No auto-memory files reference the old path."
else
  echo "  Auto-memory files that will be rewritten (${#AFFECTED_MEMORY_FILES[@]}):"
  for f in "${AFFECTED_MEMORY_FILES[@]}"; do
    echo "    - $f"
  done
fi
echo

# Grep workspace tree for old-path matches (these are reported, not rewritten).
WORKSPACE_TREE_MATCHES=()
while IFS= read -r line; do
  [ -n "$line" ] && WORKSPACE_TREE_MATCHES+=("$line")
done < <(grep -rn -F "$OLD" "$OLD" --include='*.md' 2>/dev/null || true)

if [ "${#WORKSPACE_TREE_MATCHES[@]}" -eq 0 ]; then
  echo "  No old-path references inside the workspace tree."
else
  echo "  Old-path references INSIDE the workspace tree (NOT auto-rewritten — review by hand):"
  for line in "${WORKSPACE_TREE_MATCHES[@]}"; do
    echo "    $line"
  done
fi
echo

if [ "$DRY_RUN" -eq 1 ]; then
  echo "=== DRY RUN — no changes made ==="
  echo "Re-run without --dry-run to apply."
  exit 0
fi

# Perform the rename. mv first; if mv fails, abort before touching memory.
echo "Renaming workspace directory..."
mv "$OLD" "$NEW"
echo "  ✓ moved $OLD → $NEW"

# Rewrite memory files. If anything fails here, the workspace dir stays at NEW
# (it can be reverted by hand: mv "$NEW" "$OLD" + un-edited memory).
if [ "${#AFFECTED_MEMORY_FILES[@]}" -gt 0 ]; then
  echo "Rewriting auto-memory references..."
  for f in "${AFFECTED_MEMORY_FILES[@]}"; do
    # Use a delimiter unlikely to appear in paths (we use | and rely on no |
    # in HOME-rooted paths). Backup created with .bak.<timestamp> suffix.
    BAK="$f.bak.$(date +%Y%m%d-%H%M%S)"
    cp "$f" "$BAK"
    # macOS sed and GNU sed differ on -i; use a portable pattern.
    if sed --version >/dev/null 2>&1; then
      sed -i "s|$OLD|$NEW|g" "$f"
    else
      sed -i '' "s|$OLD|$NEW|g" "$f"
    fi
    echo "  ✓ rewrote $f (backup: $BAK)"
  done
fi

echo
echo "Workspace rename complete."
if [ "${#WORKSPACE_TREE_MATCHES[@]}" -gt 0 ]; then
  echo
  echo "Reminder — the workspace tree itself still has old-path references"
  echo "in prose (listed above). Review and edit by hand if those should change."
fi
