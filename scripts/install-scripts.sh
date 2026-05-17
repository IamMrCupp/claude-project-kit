#!/usr/bin/env bash
# Install the kit's runtime helper scripts at user-level (~/.claude/scripts/)
# or per-project (<repo>/.claude/scripts/).
#
# Currently ships one script:
#   - kit-print-memory-pointer.sh — the precheck helper invoked by every
#     kit-coupled slash command and the session-summarizer agent. Extracted
#     from the inline precheck Bash so the call is matchable by Claude
#     Code's permission system (closes #218; see also #16800).
#
# Default behavior is write-once: never overwrites an existing file in the
# target. Pass --force-update to overwrite kit-shipped files (with backup +
# a customization-conflict prompt unless --yes is also passed). Files in
# the target that are NOT shipped in the kit's scripts/ are always
# preserved — user-added scripts stay untouched even with --force-update.
#
# Mirrors install-commands.sh's flag set for consistency.
set -euo pipefail

if [ -z "${BASH_VERSION:-}" ]; then
  echo "error: install-scripts.sh requires bash" >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KIT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Scripts shipped by the kit that should be installed. Add new entries here
# when the kit grows more user-facing runtime helpers.
SHIPPED_SCRIPTS=(
  kit-print-memory-pointer.sh
)

usage() {
  cat <<EOF
Usage: install-scripts.sh [options]

Install the kit's runtime helper scripts into Claude Code's recognized
locations so slash commands and agents can invoke them with a single
allowlist-friendly call.

Default behavior is write-once: existing files in the target are never
overwritten. Use --force-update to overwrite kit-shipped files when the
kit's scripts/ have changed (e.g. between releases).

You must pick a destination:
  --global               Install to ~/.claude/scripts/. Recommended for
                         kit users with multiple projects; one install
                         covers every project on this machine.
  --project <repo-path>  Install to <repo-path>/.claude/scripts/. Use
                         when you want the helpers scoped to a single
                         repo.

Other options:
  --force-update         Overwrite kit-shipped scripts in the target with
                         the current kit versions. Files in the target
                         that are NOT shipped by the kit (your own custom
                         scripts) are still preserved. Each overwritten
                         file is backed up to <name>.bak.<timestamp>. If
                         a local file's content differs from the kit's
                         current version, you'll be prompted to confirm
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
  install-scripts.sh --global

  # Install scoped to a single repo
  install-scripts.sh --project ~/Code/my-project

  # Preview without writing
  install-scripts.sh --global --dry-run

  # Update existing kit-shipped scripts to the latest kit version
  install-scripts.sh --global --force-update --yes

Behavior:
  - Files in the target that DON'T match a kit-shipped script name are
    never touched, even with --force-update. Your own custom scripts
    stay yours.
  - Source of truth is scripts/ in the kit checkout. Re-run when the kit
    ships new helper scripts (or after upgrading the kit) to pick up the
    latest versions.
  - With --force-update, every overwritten file gets a .bak.<timestamp>
    backup so you can recover local edits.
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
  TARGET_DIR="$PROJECT_PATH/.claude/scripts"
else
  TARGET_DIR="$HOME/.claude/scripts"
fi

SRC_DIR="$KIT_ROOT/scripts"

# Sanity-check that every shipped script exists in the source tree.
for name in "${SHIPPED_SCRIPTS[@]}"; do
  if [ ! -f "$SRC_DIR/$name" ]; then
    echo "error: kit source missing — expected $SRC_DIR/$name" >&2
    exit 1
  fi
done

if [ "$DRY_RUN" -eq 1 ]; then
  echo "=== DRY RUN — no files will be written ==="
fi
echo "Source: $SRC_DIR"
echo "Target: $TARGET_DIR"
if [ "$FORCE_UPDATE" -eq 1 ]; then
  echo "Mode:   --force-update (kit-shipped scripts will be overwritten with backups)"
fi
echo

COPIED=()
SKIPPED_EXISTING=()
SKIPPED_IDENTICAL=()
OVERWROTE=()
DECLINED=()

install_script() {
  local name="$1"
  local src_file="$SRC_DIR/$name"
  local dst_file="$TARGET_DIR/$name"
  local ans bak

  if [ -e "$dst_file" ]; then
    if [ "$FORCE_UPDATE" -eq 0 ]; then
      SKIPPED_EXISTING+=("$name")
      return
    fi

    if cmp -s "$src_file" "$dst_file"; then
      SKIPPED_IDENTICAL+=("$name")
      return
    fi

    if [ "$ASSUME_YES" -eq 0 ]; then
      echo "  ! $name local version differs from kit's"
      printf "    Overwrite? [y/N]: "
      read -r ans </dev/tty 2>/dev/null || ans=""
      case "${ans:-}" in
        y|Y|yes|YES) ;;
        *)
          DECLINED+=("$name")
          echo "    declined — left in place"
          return
          ;;
      esac
    fi

    if [ "$DRY_RUN" -eq 1 ]; then
      echo "  ~ would overwrite $name (with .bak.<timestamp> backup)"
    else
      bak="$dst_file.bak.$(date +%Y%m%d-%H%M%S)"
      cp "$dst_file" "$bak"
      cp "$src_file" "$dst_file"
      chmod +x "$dst_file"
      echo "  ~ overwrote $name (backup: $bak)"
    fi
    OVERWROTE+=("$name")
    return
  fi

  if [ "$DRY_RUN" -eq 1 ]; then
    echo "  + would install $name → $dst_file"
  else
    mkdir -p "$TARGET_DIR"
    cp "$src_file" "$dst_file"
    chmod +x "$dst_file"
    echo "  ✓ installed $name"
  fi
  COPIED+=("$name")
}

for name in "${SHIPPED_SCRIPTS[@]}"; do
  install_script "$name"
done

echo
TOTAL_CHANGED=$(( ${#COPIED[@]} + ${#OVERWROTE[@]} ))
if [ "$TOTAL_CHANGED" -eq 0 ]; then
  echo "Already in sync — no scripts to install or overwrite."
  if [ "${#SKIPPED_EXISTING[@]}" -gt 0 ]; then
    echo "Skipped (already present, write-once): ${#SKIPPED_EXISTING[@]} script(s)."
    echo "  (Pass --force-update to overwrite kit-shipped scripts with the latest versions.)"
  fi
  if [ "${#SKIPPED_IDENTICAL[@]}" -gt 0 ]; then
    echo "Skipped (identical to kit, no change needed): ${#SKIPPED_IDENTICAL[@]} script(s)."
  fi
  if [ "${#DECLINED[@]}" -gt 0 ]; then
    echo "Declined (you said 'no' at the prompt): ${#DECLINED[@]} script(s)."
  fi
  exit 0
fi

if [ "$DRY_RUN" -eq 1 ]; then
  if [ "${#COPIED[@]}" -gt 0 ]; then
    echo "Would install ${#COPIED[@]} new script(s)."
  fi
  if [ "${#OVERWROTE[@]}" -gt 0 ]; then
    echo "Would overwrite ${#OVERWROTE[@]} existing script(s) (kit version differs)."
  fi
  echo "Re-run without --dry-run to apply."
else
  if [ "${#COPIED[@]}" -gt 0 ]; then
    echo "Installed ${#COPIED[@]} new script(s) into $TARGET_DIR."
  fi
  if [ "${#OVERWROTE[@]}" -gt 0 ]; then
    echo "Overwrote ${#OVERWROTE[@]} existing script(s) (backups created with .bak.<timestamp>)."
  fi
  if [ "${#SKIPPED_EXISTING[@]}" -gt 0 ]; then
    echo "Skipped ${#SKIPPED_EXISTING[@]} existing script(s) (write-once; pass --force-update to update)."
  fi
  if [ "${#SKIPPED_IDENTICAL[@]}" -gt 0 ]; then
    echo "Skipped ${#SKIPPED_IDENTICAL[@]} script(s) already identical to kit's versions."
  fi
  if [ "${#DECLINED[@]}" -gt 0 ]; then
    echo "Declined ${#DECLINED[@]} script(s) at the overwrite prompt — left in place."
  fi
fi
