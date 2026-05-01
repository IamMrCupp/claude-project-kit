#!/usr/bin/env bash
# Sync missing memory-templates/*.md into a target auto-memory directory.
#
# Bootstrap seeds memory at first-run only. When the kit ships new starter
# memory files, existing adopters (and the kit's own dogfood memory) drift
# behind. This helper copies any template not already present in the target
# memory dir, never overwrites existing files, and never touches user-curated
# files (MEMORY.md, project_current.md, user_role.md).
#
# Run after pulling kit updates if you want to absorb new starter rules.
# Idempotent — re-running is a no-op once everything is in sync.
set -euo pipefail

if [ -z "${BASH_VERSION:-}" ]; then
  echo "error: sync-memory.sh requires bash" >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KIT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TEMPLATES_DIR="$KIT_ROOT/memory-templates"

# Files in memory-templates/ that are user-customized scaffolds (not generic
# rules) and must NEVER be auto-synced — overwriting them would clobber the
# user's project notes / role profile / curated index.
SKIP_FILES=(MEMORY.md project_current.md user_role.md)

usage() {
  cat <<EOF
Usage: sync-memory.sh [options] <memory-dir>

Sync missing memory-templates/*.md into <memory-dir>. Never overwrites
existing files. Never touches MEMORY.md, project_current.md, or
user_role.md (those are user-customized).

Arguments:
  <memory-dir>   Absolute path to an auto-memory directory.
                 Typically ~/.claude/projects/<sanitized-repo-path>/memory/.

Options:
  --dry-run      Print what would be copied; write nothing.
  -h, --help     Show this help and exit.

Examples:
  # Sync the kit's own dogfood memory after pulling kit updates
  sync-memory.sh ~/.claude/projects/-Users-you-Code-claude-project-kit/memory

  # Preview without writing
  sync-memory.sh --dry-run ~/.claude/projects/.../memory

After files copy, the script prints suggested MEMORY.md index lines for
the new entries — paste the ones you want into your MEMORY.md. The
script never edits MEMORY.md directly.
EOF
}

is_skipped() {
  local name="$1"
  local skip
  for skip in "${SKIP_FILES[@]}"; do
    [ "$name" = "$skip" ] && return 0
  done
  return 1
}

# Extract the matching MEMORY.md index line for a memory file, if any.
# Reads memory-templates/MEMORY.md and returns the line that links to the
# file (e.g. "- [Title](feedback_foo.md) — hook"). Empty string if not found.
suggested_index_line() {
  local name="$1"
  local index_src="$TEMPLATES_DIR/MEMORY.md"
  [ -f "$index_src" ] || return 0
  grep -F "($name)" "$index_src" || true
}

DRY_RUN=0
TARGET=""

while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run) DRY_RUN=1; shift ;;
    -h|--help) usage; exit 0 ;;
    --*) echo "error: unknown option: $1" >&2; usage >&2; exit 2 ;;
    *)
      if [ -z "$TARGET" ]; then
        TARGET="$1"
      else
        echo "error: unexpected extra argument: $1" >&2
        usage >&2
        exit 2
      fi
      shift
      ;;
  esac
done

if [ -z "$TARGET" ]; then
  echo "error: missing <memory-dir> argument" >&2
  usage >&2
  exit 2
fi

case "$TARGET" in
  "~") TARGET="$HOME" ;;
  "~/"*) TARGET="$HOME/${TARGET#"~/"}" ;;
esac

case "$TARGET" in
  /*) ;;
  *) echo "error: <memory-dir> must be an absolute path (got: $TARGET)" >&2; exit 2 ;;
esac

if [ ! -d "$TEMPLATES_DIR" ]; then
  echo "error: kit memory-templates/ not found at $TEMPLATES_DIR" >&2
  exit 1
fi

if [ ! -d "$TARGET" ]; then
  echo "error: target memory dir does not exist: $TARGET" >&2
  echo "       Run bootstrap.sh first to seed initial memory." >&2
  exit 1
fi

if [ "$DRY_RUN" -eq 1 ]; then
  echo "=== DRY RUN — no files will be written ==="
fi
echo "Source:  $TEMPLATES_DIR"
echo "Target:  $TARGET"
echo

COPIED=()
SKIPPED_EXISTING=()
SKIPPED_RESERVED=()

for src in "$TEMPLATES_DIR"/*.md; do
  [ -e "$src" ] || continue
  name="$(basename "$src")"

  if is_skipped "$name"; then
    SKIPPED_RESERVED+=("$name")
    continue
  fi

  if [ -e "$TARGET/$name" ]; then
    SKIPPED_EXISTING+=("$name")
    continue
  fi

  if [ "$DRY_RUN" -eq 1 ]; then
    echo "  + would copy $name"
  else
    cp "$src" "$TARGET/$name"
    echo "  ✓ copied $name"
  fi
  COPIED+=("$name")
done

echo
if [ "${#COPIED[@]}" -eq 0 ]; then
  echo "Already in sync — no files to copy."
  if [ "${#SKIPPED_RESERVED[@]}" -gt 0 ]; then
    echo "Skipped (user-customized, never auto-synced): ${SKIPPED_RESERVED[*]}"
  fi
  exit 0
fi

if [ "$DRY_RUN" -eq 1 ]; then
  echo "Would copy ${#COPIED[@]} file(s). Re-run without --dry-run to apply."
else
  echo "Copied ${#COPIED[@]} file(s) into $TARGET."
fi

echo
echo "Suggested MEMORY.md additions (paste the ones you want):"
echo
for name in "${COPIED[@]}"; do
  line="$(suggested_index_line "$name")"
  if [ -n "$line" ]; then
    echo "  $line"
  else
    echo "  - [TITLE]($name) — TODO: write a one-line hook"
  fi
done
echo
echo "MEMORY.md is user-curated; this script does not edit it directly."
