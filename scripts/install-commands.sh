#!/usr/bin/env bash
# Install the kit's starter slash commands and agents at user-level
# (~/.claude/{commands,agents}/) or per-project level (<repo>/.claude/{commands,agents}/).
#
# Slash commands and agents shipped in templates/.claude/ are workflow-shaped
# (session-start / session-end / session-handoff / refresh-context / close-phase /
# pull-ticket / run-acceptance / research / plan; code-reviewer +
# session-summarizer). They're not project-specific — installing once at user
# level makes them available across every project.
#
# Default behavior is **write-once**: never overwrites an existing file in the
# target. Pass --force-update to overwrite kit-shipped files (with backup + a
# customization-conflict prompt unless --yes is also passed). Files in the
# target that are NOT shipped in the kit's templates are always preserved —
# user-added commands and agents stay untouched even with --force-update.
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
recognized locations.

Default behavior is write-once: existing files in the target are never
overwritten. Use --force-update to overwrite kit-shipped files when the
kit's templates have changed (e.g. between releases).

You must pick a destination:
  --global               Install to ~/.claude/commands/ and ~/.claude/agents/.
                         Recommended for kit users with multiple projects;
                         one install covers every project on this machine.
  --project <repo-path>  Install to <repo-path>/.claude/commands/ and
                         <repo-path>/.claude/agents/. Use when you want the
                         starters scoped to a single repo (or want to
                         override globals for that repo).

Other options:
  --force-update         Overwrite kit-shipped files in the target with the
                         current kit templates. Files in the target that
                         are NOT in the kit's templates (your own custom
                         commands / agents) are still preserved.
                         Each overwritten file is backed up to
                         <name>.bak.<timestamp> before being replaced. If a
                         local file's content differs from the kit's
                         current template, you'll be prompted to confirm
                         per file unless --yes is also passed.
  --yes                  Skip the customization-conflict prompt with
                         --force-update. Implies "yes, overwrite all
                         differing files." Useful for scripts and the
                         upgrade.sh orchestrator.
  --dry-run              Print what would be copied / overwritten;
                         write nothing.
  -h, --help             Show this help and exit.

Examples:
  # Install globally (one-time per machine, covers every kit project)
  install-commands.sh --global

  # Install scoped to a single repo
  install-commands.sh --project ~/Code/my-project

  # Preview without writing
  install-commands.sh --global --dry-run

  # Update existing kit-shipped commands to the latest kit version (will
  # prompt for any local file that differs from the kit's template)
  install-commands.sh --global --force-update

  # Same, non-interactive (overwrite without prompting)
  install-commands.sh --global --force-update --yes

Behavior:
  - Files in the target that DON'T exist in the kit's templates are never
    touched, even with --force-update. Your own custom commands / agents
    stay yours.
  - Source of truth is templates/.claude/ in the kit checkout. Re-run when
    the kit ships new commands or agents to pick them up.
  - With --force-update, every overwritten file gets a .bak.<timestamp>
    backup so you can recover local edits.
  - The kit's slash commands assume a kit working folder exists in the
    project (CONTEXT.md / SESSION-LOG.md / phase-N-checklist.md). They
    error gracefully in non-kit projects.
EOF
}

DRY_RUN=0
FORCE_UPDATE=0
ASSUME_YES=0
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
    --force-update) FORCE_UPDATE=1; shift ;;
    --yes) ASSUME_YES=1; shift ;;
    --dry-run) DRY_RUN=1; shift ;;
    -h|--help) usage; exit 0 ;;
    --*) echo "error: unknown option: $1" >&2; usage >&2; exit 2 ;;
    *) echo "error: unexpected argument: $1" >&2; usage >&2; exit 2 ;;
  esac
done

if [ "$ASSUME_YES" -eq 1 ] && [ "$FORCE_UPDATE" -eq 0 ]; then
  echo "warning: --yes has no effect without --force-update; ignoring." >&2
fi

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
if [ "$FORCE_UPDATE" -eq 1 ]; then
  echo "Mode:   --force-update (kit-shipped files will be overwritten with backups)"
fi
echo

COPIED=()
SKIPPED_EXISTING=()
SKIPPED_IDENTICAL=()
OVERWROTE=()
DECLINED=()

install_dir() {
  # args: subdir_name (commands or agents)
  local sub="$1"
  local src="$SRC_DIR/$sub"
  local dst="$TARGET_BASE/$sub"
  local name src_file ans bak
  for src_file in "$src"/*.md; do
    [ -e "$src_file" ] || continue
    name="$(basename "$src_file")"

    if [ -e "$dst/$name" ]; then
      # File exists in target — write-once behavior unless --force-update
      if [ "$FORCE_UPDATE" -eq 0 ]; then
        SKIPPED_EXISTING+=("$sub/$name")
        continue
      fi

      # --force-update: overwrite if kit version differs
      if cmp -s "$src_file" "$dst/$name"; then
        SKIPPED_IDENTICAL+=("$sub/$name")
        continue
      fi

      # Local content differs from kit's. Confirm unless --yes.
      if [ "$ASSUME_YES" -eq 0 ]; then
        echo "  ! $sub/$name local version differs from kit's"
        printf "    Overwrite? [y/N]: "
        read -r ans </dev/tty 2>/dev/null || ans=""
        case "${ans:-}" in
          y|Y|yes|YES) ;;
          *)
            DECLINED+=("$sub/$name")
            echo "    declined — left in place"
            continue
            ;;
        esac
      fi

      # Backup + overwrite
      if [ "$DRY_RUN" -eq 1 ]; then
        echo "  ~ would overwrite $sub/$name (with .bak.<timestamp> backup)"
      else
        bak="$dst/$name.bak.$(date +%Y%m%d-%H%M%S)"
        cp "$dst/$name" "$bak"
        cp "$src_file" "$dst/$name"
        echo "  ~ overwrote $sub/$name (backup: $bak)"
      fi
      OVERWROTE+=("$sub/$name")
      continue
    fi

    # File doesn't exist in target — install
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
TOTAL_CHANGED=$(( ${#COPIED[@]} + ${#OVERWROTE[@]} ))
if [ "$TOTAL_CHANGED" -eq 0 ]; then
  echo "Already in sync — no files to install or overwrite."
  if [ "${#SKIPPED_EXISTING[@]}" -gt 0 ]; then
    echo "Skipped (already present, write-once): ${#SKIPPED_EXISTING[@]} file(s)."
    echo "  (Pass --force-update to overwrite kit-shipped files with the latest templates.)"
  fi
  if [ "${#SKIPPED_IDENTICAL[@]}" -gt 0 ]; then
    echo "Skipped (identical to kit, no change needed): ${#SKIPPED_IDENTICAL[@]} file(s)."
  fi
  if [ "${#DECLINED[@]}" -gt 0 ]; then
    echo "Declined (you said 'no' at the prompt): ${#DECLINED[@]} file(s)."
  fi
  exit 0
fi

if [ "$DRY_RUN" -eq 1 ]; then
  if [ "${#COPIED[@]}" -gt 0 ]; then
    echo "Would install ${#COPIED[@]} new file(s)."
  fi
  if [ "${#OVERWROTE[@]}" -gt 0 ]; then
    echo "Would overwrite ${#OVERWROTE[@]} existing file(s) (kit version differs)."
  fi
  echo "Re-run without --dry-run to apply."
else
  if [ "${#COPIED[@]}" -gt 0 ]; then
    echo "Installed ${#COPIED[@]} new file(s) into $TARGET_BASE."
  fi
  if [ "${#OVERWROTE[@]}" -gt 0 ]; then
    echo "Overwrote ${#OVERWROTE[@]} existing file(s) (backups created with .bak.<timestamp>)."
  fi
  if [ "${#SKIPPED_EXISTING[@]}" -gt 0 ]; then
    echo "Skipped ${#SKIPPED_EXISTING[@]} existing file(s) (write-once; pass --force-update to update)."
  fi
  if [ "${#SKIPPED_IDENTICAL[@]}" -gt 0 ]; then
    echo "Skipped ${#SKIPPED_IDENTICAL[@]} file(s) already identical to kit's templates."
  fi
  if [ "${#DECLINED[@]}" -gt 0 ]; then
    echo "Declined ${#DECLINED[@]} file(s) at the overwrite prompt — left in place."
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
