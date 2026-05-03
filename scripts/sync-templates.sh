#!/usr/bin/env bash
# Sync working-folder or workspace templates into an existing kit working
# folder, write-once. Counterpart to scripts/sync-memory.sh and
# scripts/install-commands.sh — same shape, different source/destination.
#
# Default mode: copies any templates/*.md file not already present in the
# target working folder. Workspace mode (--workspace): copies any
# templates/workspace/*.md file not already present in the target workspace
# root.
#
# **Never overwrites existing files** — if a file is already present, it is
# preserved as-is. Files that exist but differ from the kit's current
# template are reported as "outdated; review and merge by hand if desired"
# so the user knows there's a kit update available without auto-clobbering
# their filled-in content.
#
# Idempotent — re-running is a no-op once everything is in sync.
set -euo pipefail

if [ -z "${BASH_VERSION:-}" ]; then
  echo "error: sync-templates.sh requires bash" >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KIT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# shellcheck source=lib/infer.sh
. "$SCRIPT_DIR/lib/infer.sh"

usage() {
  cat <<EOF
Usage: sync-templates.sh [options] [target-folder]

Sync missing kit templates into the target. Never overwrites existing
files. Reports files that exist but differ from the kit's current template
("outdated") so you can review and merge by hand if desired.

Modes:
  Default            Sync templates/*.md into a working folder.
  --workspace        Sync templates/workspace/*.md into a workspace root
                     (directory containing workspace-CONTEXT.md).

Other options:
  --dry-run          Print what would be copied; write nothing.
  -h, --help         Show this help and exit.

Arguments:
  [target-folder]    Optional. Absolute path to the target.
                     - Default mode: working folder (per-repo).
                     - --workspace mode: workspace root.

                     If omitted, inferred from \$PWD by reading the repo's
                     auto-memory (reference_ai_working_folder.md). Pass
                     explicitly when not inside a kit-bootstrapped repo.

Examples:
  # Inferred mode (default) — run from a kit-bootstrapped repo
  cd ~/Code/some-project && sync-templates.sh

  # Inferred mode (workspace) — run from anywhere inside the workspace
  cd ~/Code/some-project && sync-templates.sh --workspace

  # Explicit forms still work
  sync-templates.sh ~/Documents/Claude/Projects/my-project
  sync-templates.sh --workspace ~/Documents/Claude/Projects/platform-infra

  # Preview without writing
  sync-templates.sh --dry-run

Notes:
  - Default mode skips templates/.claude/ (use scripts/install-commands.sh
    for slash commands and agents).
  - Default mode skips templates/workspace/ (use --workspace mode for that).
  - Memory templates have their own helper: scripts/sync-memory.sh.
EOF
}

DRY_RUN=0
WORKSPACE_MODE=0
TARGET=""

while [ $# -gt 0 ]; do
  case "$1" in
    --workspace) WORKSPACE_MODE=1; shift ;;
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

INFERRED=0
if [ -z "$TARGET" ]; then
  if [ "$WORKSPACE_MODE" -eq 1 ]; then
    TARGET="$(infer_workspace_root)"
    if [ -z "$TARGET" ]; then
      echo "error: couldn't find a workspace root from \$PWD." >&2
      echo "       Either cd into a workspace (or a repo whose working folder" >&2
      echo "       lives inside one), or pass the path explicitly:" >&2
      echo "       sync-templates.sh --workspace <path>" >&2
      exit 1
    fi
  else
    TARGET="$(infer_working_folder)"
    if [ -z "$TARGET" ]; then
      echo "error: couldn't infer a working folder from \$PWD." >&2
      echo "       Either cd into a kit-bootstrapped repo first (its" >&2
      echo "       auto-memory must contain reference_ai_working_folder.md)," >&2
      echo "       or pass the working-folder path explicitly:" >&2
      echo "       sync-templates.sh <path>" >&2
      exit 1
    fi
  fi
  INFERRED=1
fi

case "$TARGET" in
  "~") TARGET="$HOME" ;;
  "~/"*) TARGET="$HOME/${TARGET#"~/"}" ;;
esac

case "$TARGET" in
  /*) ;;
  *) echo "error: target-folder must be an absolute path (got: $TARGET)" >&2; exit 2 ;;
esac

if [ ! -d "$TARGET" ]; then
  echo "error: target folder does not exist: $TARGET" >&2
  exit 2
fi

if [ "$WORKSPACE_MODE" -eq 1 ]; then
  SRC_DIR="$KIT_ROOT/templates/workspace"
  MODE_LABEL="workspace"
else
  SRC_DIR="$KIT_ROOT/templates"
  MODE_LABEL="working-folder"
fi

if [ ! -d "$SRC_DIR" ]; then
  echo "error: kit source dir not found: $SRC_DIR" >&2
  exit 1
fi

if [ "$DRY_RUN" -eq 1 ]; then
  echo "=== DRY RUN — no files will be written ==="
fi
echo "Mode:   $MODE_LABEL"
echo "Source: $SRC_DIR"
if [ "$INFERRED" -eq 1 ]; then
  echo "Target: $TARGET  (inferred from \$PWD)"
else
  echo "Target: $TARGET"
fi
echo

COPIED=()
SKIPPED_IDENTICAL=()
OUTDATED=()

for src_file in "$SRC_DIR"/*.md; do
  [ -e "$src_file" ] || continue
  name="$(basename "$src_file")"

  if [ -e "$TARGET/$name" ]; then
    if cmp -s "$src_file" "$TARGET/$name"; then
      SKIPPED_IDENTICAL+=("$name")
    else
      OUTDATED+=("$name")
    fi
    continue
  fi

  if [ "$DRY_RUN" -eq 1 ]; then
    echo "  + would copy $name"
  else
    cp "$src_file" "$TARGET/$name"
    echo "  ✓ copied $name"
  fi
  COPIED+=("$name")
done

echo
if [ "${#COPIED[@]}" -eq 0 ] && [ "${#OUTDATED[@]}" -eq 0 ]; then
  echo "Already in sync — no files to copy, no outdated content."
  exit 0
fi

if [ "${#COPIED[@]}" -gt 0 ]; then
  if [ "$DRY_RUN" -eq 1 ]; then
    echo "Would copy ${#COPIED[@]} new file(s). Re-run without --dry-run to apply."
  else
    echo "Copied ${#COPIED[@]} new file(s) into $TARGET."
  fi
fi

if [ "${#OUTDATED[@]}" -gt 0 ]; then
  echo
  echo "Outdated files (exist locally but differ from kit's current template):"
  for name in "${OUTDATED[@]}"; do
    echo "  - $name"
  done
  echo
  echo "These were NOT modified — review the kit's version and merge by hand"
  echo "if desired. Compare with:"
  echo
  for name in "${OUTDATED[@]}"; do
    echo "    diff $SRC_DIR/$name $TARGET/$name"
    break  # show one example, the user can extrapolate
  done
fi
