#!/usr/bin/env bash
# convert-to-shared.sh — migrate a repo's per-repo working folder out of a
# workspace into a standalone shared working folder (#199 PR B).
#
# Counterpart to `bootstrap.sh --shared / --reference`. After migration the
# repo's working folder lives standalone (one canonical state), the auto-memory
# pointer is repointed to the new location, and the source workspace (+ any
# additional workspaces passed via --reference-from) gain a "Shared repos"
# entry pointing back at the new standalone path.
#
# Every file mutation gets a .bak.<timestamp> backup. --dry-run previews.
#
# CONSTRAINT: This script never touches an external tracker. It only moves
# local working-folder state + appends to local workspace-CONTEXT.md files +
# updates the auto-memory pointer. See ADR-0001 D3 and the kit's
# CONVENTIONS.md "Ticket-driven workflows → What the kit does NOT do with
# trackers".
set -euo pipefail

if [ -z "${BASH_VERSION:-}" ]; then
  echo "error: convert-to-shared.sh requires bash" >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KIT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# shellcheck source=lib/infer.sh
. "$SCRIPT_DIR/lib/infer.sh"

usage() {
  cat <<EOF
Usage: convert-to-shared.sh <repo-path> [options]

Migrate a repo's per-repo working folder out of its current workspace into a
standalone shared working folder. The repo continues to work as a kit project;
the workspace it left gains a "Shared repos" entry pointing at the new path.

Arguments:
  <repo-path>            Absolute path to the repo whose working folder will be
                         migrated. Must currently be a per-repo subfolder under
                         a workspace (i.e. its working folder's parent must
                         contain workspace-CONTEXT.md).

Options:
  --to PATH              Target standalone working-folder path. If omitted,
                         defaults to ~/Documents/Claude/Projects/<repo-basename>/.
                         If that default collides with an existing directory,
                         the script falls back to <basename>-<sanitized-org>
                         (derived from \`git remote get-url origin\`) and
                         prints the chosen path so you can override with --to.
  --reference-from WS    Repeatable. Absolute path to ANOTHER workspace that
                         should also reference the now-shared repo. One
                         "Shared repos" bullet is appended to each WS's
                         workspace-CONTEXT.md. The source workspace (where
                         the per-repo subfolder currently lives) ALWAYS gets
                         the entry; --reference-from adds additional ones.
  --dry-run              Print the plan and exit. No files moved or modified.
  --yes                  Skip the confirmation prompt before applying. Useful
                         for scripted runs.
  -h, --help             Show this help and exit.

Behavior:
  - The auto-memory file ~/.claude/projects/<sanitized-repo-path>/memory/
    reference_ai_working_folder.md is repointed from the old per-repo subfolder
    to the new standalone path. This file is normally never modified by the
    kit; the migration justifies the write with a backup + dry-run preview +
    confirmation prompt.
  - workspace-CONTEXT.md files are appended-to in place (with backups).
    The script never removes the existing per-repo entry from the source
    workspace's "Repos in this workspace" table — review and edit by hand
    after migration if you want the table to reflect the new shared status.

Examples:
  # Default (target dir from basename, source workspace gets the back-reference)
  convert-to-shared.sh ~/Code/shared-flux-config

  # Custom target path
  convert-to-shared.sh ~/Code/shared-flux-config \\
    --to ~/Documents/Claude/Projects/flux-shared/

  # Multi-workspace reference: source workspace + two others get the entry
  convert-to-shared.sh ~/Code/shared-flux-config \\
    --reference-from ~/Documents/Claude/Projects/data-platform/ \\
    --reference-from ~/Documents/Claude/Projects/ml-platform/

  # Preview before applying
  convert-to-shared.sh ~/Code/shared-flux-config --dry-run
EOF
}

REPO_PATH=""
TO_PATH=""
REFERENCE_FROM=()
DRY_RUN=0
ASSUME_YES=0

while [ $# -gt 0 ]; do
  case "$1" in
    -h|--help) usage; exit 0 ;;
    --dry-run) DRY_RUN=1; shift ;;
    --yes) ASSUME_YES=1; shift ;;
    --to)
      if [ $# -lt 2 ]; then
        echo "error: --to requires a path" >&2
        usage >&2
        exit 2
      fi
      TO_PATH="$2"; shift 2 ;;
    --reference-from)
      if [ $# -lt 2 ]; then
        echo "error: --reference-from requires a path" >&2
        usage >&2
        exit 2
      fi
      REFERENCE_FROM+=("$2"); shift 2 ;;
    --*) echo "error: unknown option: $1" >&2; usage >&2; exit 2 ;;
    *)
      if [ -z "$REPO_PATH" ]; then
        REPO_PATH="$1"
      else
        echo "error: unexpected extra argument: $1" >&2
        usage >&2
        exit 2
      fi
      shift
      ;;
  esac
done

if [ -z "$REPO_PATH" ]; then
  echo "error: <repo-path> argument is required" >&2
  usage >&2
  exit 2
fi

case "$REPO_PATH" in
  "~"|"~/"*) REPO_PATH="${REPO_PATH/#\~/$HOME}" ;;
esac
case "$REPO_PATH" in
  /*) ;;
  *) echo "error: <repo-path> must be an absolute path (got: $REPO_PATH)" >&2; exit 2 ;;
esac
if [ ! -d "$REPO_PATH" ]; then
  echo "error: <repo-path> does not exist: $REPO_PATH" >&2
  exit 2
fi

# --- Resolve current working folder + workspace ---

SRC_WF="$(infer_working_folder "$REPO_PATH")"
if [ -z "$SRC_WF" ]; then
  echo "error: no kit working folder found for $REPO_PATH" >&2
  echo "       (no reference_ai_working_folder.md in $(infer_memory_dir "$REPO_PATH"))" >&2
  echo "       Run bootstrap.sh on this repo first, or pass a different <repo-path>." >&2
  exit 1
fi
if [ ! -d "$SRC_WF" ]; then
  echo "error: working folder pointer exists but the target directory does not: $SRC_WF" >&2
  exit 1
fi

# The source workspace is the parent dir of the per-repo working folder IF
# that parent contains workspace-CONTEXT.md.
SRC_WS="$(cd "$SRC_WF/.." 2>/dev/null && pwd)"
SRC_WS_CTX="$SRC_WS/workspace-CONTEXT.md"
if [ ! -f "$SRC_WS_CTX" ]; then
  echo "error: $REPO_PATH isn't currently a per-repo subfolder under a workspace" >&2
  echo "       Working folder is at $SRC_WF, but its parent ($SRC_WS) has no" >&2
  echo "       workspace-CONTEXT.md. Migration only applies to repos already living" >&2
  echo "       under a workspace." >&2
  exit 1
fi

MEM_FILE="$(infer_memory_dir "$REPO_PATH")/reference_ai_working_folder.md"
if [ ! -f "$MEM_FILE" ]; then
  echo "error: auto-memory pointer missing: $MEM_FILE" >&2
  exit 1
fi

# --- Determine target standalone path ---

REPO_BASENAME="$(basename "$REPO_PATH")"
DEFAULT_TGT="$HOME/Documents/Claude/Projects/$REPO_BASENAME"

if [ -n "$TO_PATH" ]; then
  case "$TO_PATH" in
    "~"|"~/"*) TO_PATH="${TO_PATH/#\~/$HOME}" ;;
  esac
  case "$TO_PATH" in
    /*) ;;
    *) echo "error: --to must be an absolute path (got: $TO_PATH)" >&2; exit 2 ;;
  esac
  TGT_WF="$TO_PATH"
else
  TGT_WF="$DEFAULT_TGT"
  # Basename-collision fallback: try <basename>-<org> from git remote.
  if [ -e "$TGT_WF" ]; then
    ORG=""
    if REMOTE="$(git -C "$REPO_PATH" remote get-url origin 2>/dev/null)"; then
      # Extract org segment from `git@host:org/repo(.git)?` or `https://host/org/repo(.git)?`.
      ORG="$(printf '%s\n' "$REMOTE" \
        | sed -E 's|^https?://[^/]+/||; s|^git@[^:]+:||; s|\.git$||' \
        | awk -F'/' '{print $1}')"
      ORG="$(printf '%s' "$ORG" | sed 's|[/.]|-|g' | tr '[:upper:]' '[:lower:]')"
    fi
    if [ -n "$ORG" ]; then
      TGT_WF="$DEFAULT_TGT-$ORG"
      echo "  ⚠ default target $DEFAULT_TGT already exists; falling back to $TGT_WF" >&2
      echo "    Override with --to <path> if you'd rather pick the target yourself." >&2
    fi
  fi
fi

if [ -e "$TGT_WF" ]; then
  echo "error: target standalone working folder already exists: $TGT_WF" >&2
  echo "       Remove it or pass --to <different-path> and retry." >&2
  exit 1
fi

# --- Validate --reference-from paths up front (warn-don't-fail per path) ---

VALID_REFS=()
for ws in "${REFERENCE_FROM[@]}"; do
  case "$ws" in
    "~"|"~/"*) ws="${ws/#\~/$HOME}" ;;
  esac
  if [ ! -f "$ws/workspace-CONTEXT.md" ]; then
    echo "  ⚠ --reference-from $ws skipped (no workspace-CONTEXT.md there)" >&2
    continue
  fi
  if [ "$ws" = "$SRC_WS" ]; then
    echo "  ⚠ --reference-from $ws skipped (same as the source workspace; already covered)" >&2
    continue
  fi
  VALID_REFS+=("$ws")
done

# --- Helpers (mirrors bootstrap.sh's append_shared_repo_entries; duplicated
#     here intentionally to keep this script standalone — see #199 PR B notes) ---

append_shared_repo_entry() {
  # Args: <workspace-CONTEXT.md path>
  # Inserts a single bullet pointing at TGT_WF, using basename "$REPO_PATH" as
  # the entry name. Tries placeholder bullet → section header → append-at-EOF.
  local file="$1"
  local entry
  entry="- ${REPO_BASENAME} — \`${TGT_WF}\` — moved from per-repo subfolder $(date +%Y-%m-%d) via convert-to-shared.sh"

  local anchor=""
  if grep -Fq -- '- {{SHARED_REPO_NAME}}' "$file"; then
    anchor='- {{SHARED_REPO_NAME}}'
  elif grep -Fq '## Shared repos' "$file"; then
    anchor='## Shared repos'
  else
    # No section at all — append a fresh one at EOF (pre-#199 workspace path).
    {
      printf '\n---\n\n## Shared repos\n\n'
      printf '%s\n\n' '<!-- Added by `convert-to-shared.sh` (workspace pre-dates #199 template; section seeded at EOF). -->'
      printf '%s\n' "$entry"
    } >> "$file"
    return 0
  fi

  awk -v anchor="$anchor" -v entry="$entry" '
    { print }
    index($0, anchor) == 1 && !done { print entry; done = 1 }
  ' "$file" > "$file.new" && mv "$file.new" "$file"
}

backup_then_run() {
  # Args: <file> <command...>
  # Creates <file>.bak.<timestamp> first, then runs the command. The command
  # is responsible for the actual write.
  local file="$1"; shift
  local bak="$file.bak.$(date +%Y%m%d-%H%M%S)"
  cp "$file" "$bak"
  echo "    backup: $bak"
  "$@"
}

# --- Print the plan ---

echo "convert-to-shared.sh plan"
echo
echo "  Repo:               $REPO_PATH"
echo "  Source workspace:   $SRC_WS"
echo "  Current working folder: $SRC_WF"
echo "  Target working folder:  $TGT_WF"
echo "  Auto-memory pointer:    $MEM_FILE"
echo
echo "Steps the real run will take:"
echo "  1. mv $SRC_WF → $TGT_WF (preserves all files)"
echo "  2. backup + sed-update $MEM_FILE (paths now point at $TGT_WF)"
echo "  3. backup + append \"Shared repos\" entry to $SRC_WS_CTX"
if [ "${#VALID_REFS[@]}" -gt 0 ]; then
  echo "  4. backup + append \"Shared repos\" entry to ${#VALID_REFS[@]} additional workspace(s):"
  for ws in "${VALID_REFS[@]}"; do
    echo "       - $ws/workspace-CONTEXT.md"
  done
fi
echo

if [ "$DRY_RUN" -eq 1 ]; then
  echo "=== DRY RUN — no files moved or modified ==="
  exit 0
fi

if [ "$ASSUME_YES" -eq 0 ]; then
  printf "Proceed? [y/N]: "
  read -r ans </dev/tty 2>/dev/null || ans=""
  case "${ans:-}" in
    y|Y|yes|YES) ;;
    *) echo "Aborted."; exit 0 ;;
  esac
fi

# --- Execute ---

echo
echo "Step 1/3: moving working folder"
mkdir -p "$(dirname "$TGT_WF")"
mv "$SRC_WF" "$TGT_WF"
echo "  ✓ $SRC_WF → $TGT_WF"

echo "Step 2/3: repointing auto-memory pointer"
backup_then_run "$MEM_FILE" bash -c "
  sed 's|$SRC_WF|$TGT_WF|g' '$MEM_FILE' > '$MEM_FILE.new' && mv '$MEM_FILE.new' '$MEM_FILE'
"
echo "  ✓ $MEM_FILE now points at $TGT_WF"

echo "Step 3/3: appending Shared repos entries"
backup_then_run "$SRC_WS_CTX" append_shared_repo_entry "$SRC_WS_CTX"
echo "  ✓ appended entry to $SRC_WS_CTX"
for ws in "${VALID_REFS[@]}"; do
  ws_ctx="$ws/workspace-CONTEXT.md"
  backup_then_run "$ws_ctx" append_shared_repo_entry "$ws_ctx"
  echo "  ✓ appended entry to $ws_ctx"
done

echo
echo "Migration complete."
echo
echo "Next:"
echo "  1. Edit $TGT_WF/CONTEXT.md — if it doesn't already have a 'Referenced by'"
echo "     section, add one and list the workspaces that reference this repo."
echo "  2. Edit the workspace-CONTEXT.md files above — replace the 'TODO: describe"
echo "     why this workspace uses it' placeholder in the new entry with the"
echo "     per-workspace context (1 sentence)."
echo "  3. Review the source workspace's 'Repos in this workspace' table — the"
echo "     migrated repo's row is still there; remove it if you want the table to"
echo "     reflect the new shared status (the 'Shared repos' section now points"
echo "     at the standalone working folder)."
