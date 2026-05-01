#!/usr/bin/env bash
# Install the kit's starter slash commands and agents at user-level
# (~/.claude/{commands,agents}/) or per-project level (<repo>/.claude/{commands,agents}/).
#
# Slash commands and agents shipped in templates/.claude/ are workflow-shaped
# (session-start / session-end / session-handoff / refresh-context / close-phase /
# pull-ticket; code-reviewer + session-summarizer). They're not project-specific —
# installing once at user level makes them available across every project. This
# script does that opt-in install with the same write-once invariant bootstrap.sh
# follows: never overwrite an existing file. Idempotent.
#
# See FEATURES.md "Starter slash commands" / "Starter agents" for what each
# command does. See templates/.claude/README.md for the kit-coupling caveat —
# most commands assume a kit working folder exists; they error gracefully in
# non-kit projects.
set -euo pipefail

if [ -z "${BASH_VERSION:-}" ]; then
  echo "error: install-commands.sh requires bash" >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KIT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SRC_DIR="$KIT_ROOT/templates/.claude"

usage() {
  cat <<EOF
Usage: install-commands.sh [options]

Install the kit's starter slash commands and agents into Claude Code's
recognized locations. Never overwrites existing files.

You must pick a destination:
  --global               Install to ~/.claude/commands/ and ~/.claude/agents/.
                         Recommended for kit users with multiple projects;
                         one install covers every project on this machine.
  --project <repo-path>  Install to <repo-path>/.claude/commands/ and
                         <repo-path>/.claude/agents/. Use when you want the
                         starters scoped to a single repo (or want to
                         override globals for that repo).

Other options:
  --dry-run              Print what would be copied; write nothing.
  -h, --help             Show this help and exit.

Examples:
  # Install globally (one-time per machine, covers every kit project)
  install-commands.sh --global

  # Install scoped to a single repo
  install-commands.sh --project ~/Code/my-project

  # Preview without writing
  install-commands.sh --global --dry-run

Behavior:
  - Idempotent — files already present in the target are skipped, never
    overwritten. Safe to re-run.
  - Source of truth is templates/.claude/ in the kit checkout; if the kit
    ships new commands or agents later, re-run to pick them up.
  - The kit's slash commands assume a kit working folder exists in the
    project (CONTEXT.md / SESSION-LOG.md / phase-N-checklist.md). They
    will error in non-kit projects — see kit issue #82 for graceful
    degradation, in flight.
EOF
}

DRY_RUN=0
MODE=""
PROJECT_PATH=""

while [ $# -gt 0 ]; do
  case "$1" in
    --global)
      if [ -n "$MODE" ]; then
        echo "error: --global and --project are mutually exclusive" >&2
        exit 2
      fi
      MODE="global"
      shift
      ;;
    --project)
      if [ -n "$MODE" ]; then
        echo "error: --global and --project are mutually exclusive" >&2
        exit 2
      fi
      if [ $# -lt 2 ]; then
        echo "error: --project requires a path argument" >&2
        usage >&2
        exit 2
      fi
      MODE="project"
      PROJECT_PATH="$2"
      shift 2
      ;;
    --dry-run) DRY_RUN=1; shift ;;
    -h|--help) usage; exit 0 ;;
    --*) echo "error: unknown option: $1" >&2; usage >&2; exit 2 ;;
    *) echo "error: unexpected argument: $1" >&2; usage >&2; exit 2 ;;
  esac
done

if [ -z "$MODE" ]; then
  echo "error: must specify --global or --project <repo-path>" >&2
  usage >&2
  exit 2
fi

if [ "$MODE" = "project" ]; then
  case "$PROJECT_PATH" in
    "~") PROJECT_PATH="$HOME" ;;
    "~/"*) PROJECT_PATH="$HOME/${PROJECT_PATH#"~/"}" ;;
  esac
  case "$PROJECT_PATH" in
    /*) ;;
    *) echo "error: --project path must be absolute (got: $PROJECT_PATH)" >&2; exit 2 ;;
  esac
  if [ ! -d "$PROJECT_PATH" ]; then
    echo "error: --project path does not exist: $PROJECT_PATH" >&2
    exit 2
  fi
  TARGET_BASE="$PROJECT_PATH/.claude"
else
  TARGET_BASE="$HOME/.claude"
fi

if [ ! -d "$SRC_DIR/commands" ] || [ ! -d "$SRC_DIR/agents" ]; then
  echo "error: kit source missing — expected $SRC_DIR/commands and $SRC_DIR/agents" >&2
  exit 1
fi

if [ "$DRY_RUN" -eq 1 ]; then
  echo "=== DRY RUN — no files will be written ==="
fi
echo "Source: $SRC_DIR"
echo "Target: $TARGET_BASE"
echo

COPIED=()
SKIPPED_EXISTING=()

install_dir() {
  # args: subdir_name (commands or agents)
  local sub="$1"
  local src="$SRC_DIR/$sub"
  local dst="$TARGET_BASE/$sub"
  local f name
  for src_file in "$src"/*.md; do
    [ -e "$src_file" ] || continue
    name="$(basename "$src_file")"
    if [ -e "$dst/$name" ]; then
      SKIPPED_EXISTING+=("$sub/$name")
      continue
    fi
    if [ "$DRY_RUN" -eq 1 ]; then
      echo "  + would install $sub/$name → $dst/$name"
    else
      mkdir -p "$dst"
      cp "$src_file" "$dst/$name"
      echo "  ✓ installed $sub/$name"
    fi
    COPIED+=("$sub/$name")
  done
}

install_dir commands
install_dir agents

echo
if [ "${#COPIED[@]}" -eq 0 ]; then
  echo "Already installed — no files to copy."
  if [ "${#SKIPPED_EXISTING[@]}" -gt 0 ]; then
    echo "Skipped (already present): ${#SKIPPED_EXISTING[@]} file(s)."
  fi
  exit 0
fi

if [ "$DRY_RUN" -eq 1 ]; then
  echo "Would install ${#COPIED[@]} file(s). Re-run without --dry-run to apply."
else
  echo "Installed ${#COPIED[@]} file(s) into $TARGET_BASE."
  if [ "${#SKIPPED_EXISTING[@]}" -gt 0 ]; then
    echo "Skipped ${#SKIPPED_EXISTING[@]} file(s) already present (never overwritten)."
  fi
  echo
  if [ "$MODE" = "global" ]; then
    echo "Slash commands and agents are now available in every project on this"
    echo "machine. Restart Claude Code if it was already running."
  else
    echo "Slash commands and agents are scoped to $PROJECT_PATH."
    echo "Open Claude Code in that repo to use them."
  fi
fi
