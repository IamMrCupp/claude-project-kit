#!/usr/bin/env bash
# bootstrap.sh — create a Claude working folder and seed auto-memory
# for the project whose repo you run this from.
#
# Run this from the root of the project repo you want to bootstrap. The
# auto-memory path is derived from the current working directory using
# the Claude harness's sanitization rule ('/' -> '-', prefixed with '-').
set -euo pipefail

if [ -z "${BASH_VERSION:-}" ]; then
  echo "error: bootstrap.sh requires bash" >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KIT_ROOT="$SCRIPT_DIR"

usage() {
  cat <<EOF
Usage: bootstrap.sh [options] <working-folder>

Create a Claude working folder and seed auto-memory for the project
whose repo you run this from. The current working directory is assumed
to be the repo root.

Arguments:
  <working-folder>   Absolute path where the Claude working folder will
                     be created (e.g. ~/Documents/Claude/Projects/foo).

Options:
  --skip-memory      Skip copying memory-templates/ into the auto-memory
                     folder. Only the working folder will be seeded.
  --force            Proceed even if the working folder already exists
                     and is non-empty. Does NOT override the auto-memory
                     safety check — existing memory files are never
                     overwritten.
  -h, --help         Show this help and exit.

Example:
  cd ~/Code/my-new-project
  ~/Code/claude-project-kit/bootstrap.sh ~/Documents/Claude/Projects/my-new-project

After running, edit the copied files (placeholders marked {{LIKE_THIS}}).
See SETUP.md in the kit repo for the full walk-through.
EOF
}

SKIP_MEMORY=0
FORCE=0
WORKING_FOLDER=""

while [ $# -gt 0 ]; do
  case "$1" in
    --skip-memory) SKIP_MEMORY=1; shift ;;
    --force) FORCE=1; shift ;;
    -h|--help) usage; exit 0 ;;
    --*) echo "error: unknown option: $1" >&2; usage >&2; exit 2 ;;
    *)
      if [ -z "$WORKING_FOLDER" ]; then
        WORKING_FOLDER="$1"
      else
        echo "error: unexpected extra argument: $1" >&2
        usage >&2
        exit 2
      fi
      shift
      ;;
  esac
done

if [ -z "$WORKING_FOLDER" ]; then
  echo "error: missing <working-folder> argument" >&2
  usage >&2
  exit 2
fi

case "$WORKING_FOLDER" in
  "~") WORKING_FOLDER="$HOME" ;;
  "~/"*) WORKING_FOLDER="$HOME/${WORKING_FOLDER#~/}" ;;
esac

case "$WORKING_FOLDER" in
  /*) ;;
  *) echo "error: <working-folder> must be an absolute path (got: $WORKING_FOLDER)" >&2; exit 2 ;;
esac

if [ ! -d "$KIT_ROOT/templates" ] || [ ! -d "$KIT_ROOT/memory-templates" ]; then
  echo "error: bootstrap.sh must live alongside templates/ and memory-templates/ in a claude-project-kit checkout" >&2
  exit 1
fi

REPO_ROOT="$(pwd)"
SANITIZED="$(echo "$REPO_ROOT" | sed 's|/|-|g')"
MEMORY_DIR="$HOME/.claude/projects/${SANITIZED}/memory"

echo "Working folder: $WORKING_FOLDER"
echo "Repo root:      $REPO_ROOT"
if [ "$SKIP_MEMORY" -eq 0 ]; then
  echo "Memory folder:  $MEMORY_DIR"
fi
echo

if [ -e "$WORKING_FOLDER" ]; then
  if [ ! -d "$WORKING_FOLDER" ]; then
    echo "error: $WORKING_FOLDER exists and is not a directory" >&2
    exit 1
  fi
  if [ -n "$(ls -A "$WORKING_FOLDER" 2>/dev/null)" ] && [ "$FORCE" -eq 0 ]; then
    echo "error: $WORKING_FOLDER is not empty. Use --force to proceed anyway." >&2
    exit 1
  fi
fi

if [ "$SKIP_MEMORY" -eq 0 ] && [ -d "$MEMORY_DIR" ]; then
  if [ -n "$(ls -A "$MEMORY_DIR" 2>/dev/null)" ]; then
    echo "error: $MEMORY_DIR already contains files." >&2
    echo "       Bootstrap will never overwrite existing memory. Inspect and clear" >&2
    echo "       manually, or re-run with --skip-memory to leave memory alone." >&2
    exit 1
  fi
fi

mkdir -p "$WORKING_FOLDER"
cp "$KIT_ROOT/templates/"*.md "$WORKING_FOLDER/"
mv "$WORKING_FOLDER/phase-N-checklist.md" "$WORKING_FOLDER/phase-0-checklist.md"
echo "  ✓ Copied template files to $WORKING_FOLDER"
echo "  ✓ Renamed phase-N-checklist.md → phase-0-checklist.md"

if [ "$SKIP_MEMORY" -eq 0 ]; then
  mkdir -p "$MEMORY_DIR"
  cp "$KIT_ROOT/memory-templates/"*.md "$MEMORY_DIR/"
  echo "  ✓ Copied memory files to $MEMORY_DIR"
fi

echo
echo "Bootstrap complete."
echo
echo "Next steps:"
echo "  1. cd $WORKING_FOLDER"
echo "  2. Fill in {{PLACEHOLDERS}} — start with CONTEXT.md (see SETUP.md §3)"
if [ "$SKIP_MEMORY" -eq 0 ]; then
  echo "  3. Edit memory files at $MEMORY_DIR to match your preferences"
  echo "     (especially reference_ai_working_folder.md — point it at the working folder)"
  echo "  4. Open a Claude session and use a prompt from PROMPTS.md"
else
  echo "  3. Open a Claude session and use a prompt from PROMPTS.md"
fi
