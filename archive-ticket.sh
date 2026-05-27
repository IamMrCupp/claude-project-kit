#!/usr/bin/env bash
# archive-ticket.sh — move a resolved ticket scratchpad into tickets/archive/.
#
# Counterpart to pull-ticket.sh: pull-ticket creates tickets/<KEY>-<slug>.md,
# archive-ticket moves it to tickets/archive/<KEY>-<slug>.md once the work is
# done, so a long-running workspace's tickets/ folder doesn't accumulate
# hundreds of resolved scratchpads. Flat archive dir (one level).
#
# CONSTRAINT: This script never touches the external tracker — humans
# transition tickets there. It only tidies the local working folder, and
# never edits the ticket file's contents. See CONVENTIONS.md
# "Ticket-driven workflows".
set -euo pipefail

if [ -z "${BASH_VERSION:-}" ]; then
  echo "error: archive-ticket.sh requires bash" >&2
  exit 1
fi

usage() {
  cat <<EOF
Usage: archive-ticket.sh <KEY> [--working-folder <path>] [--dry-run]

Move a resolved per-ticket scratchpad from tickets/ into tickets/archive/.
Finds the file matching <KEY>-*.md, moves it, and never edits its contents
or touches the external tracker.

Arguments:
  <KEY>                  The ticket key (e.g. ACME-1234, INFRA-42, 123).

Options:
  --working-folder PATH  Path to the Claude working folder for the current
                         project. If omitted, defaults to
                         \$HOME/Documents/Claude/Projects/\$(basename \$(pwd))
                         (the same default \`bootstrap.sh\` / \`pull-ticket.sh\` use).
  --dry-run              Print what would move and exit without writing.
  -h, --help             Show this help and exit.

Examples:
  cd ~/Code/my-terraform-modules
  ~/Code/claude-project-kit/archive-ticket.sh ACME-1234

  ~/Code/claude-project-kit/archive-ticket.sh 42 \\
      --working-folder ~/Documents/Claude/Projects/my-project
EOF
}

KEY=""
WORKING_FOLDER=""
DRY_RUN=0

while [ $# -gt 0 ]; do
  case "$1" in
    -h|--help) usage; exit 0 ;;
    --dry-run) DRY_RUN=1; shift ;;
    --working-folder)
      if [ $# -lt 2 ]; then
        echo "error: --working-folder requires a value" >&2
        usage >&2
        exit 2
      fi
      WORKING_FOLDER="$2"
      shift 2
      ;;
    --*) echo "error: unknown option: $1" >&2; usage >&2; exit 2 ;;
    *)
      if [ -z "$KEY" ]; then
        KEY="$1"
      else
        echo "error: unexpected extra argument: $1" >&2
        usage >&2
        exit 2
      fi
      shift
      ;;
  esac
done

if [ -z "$KEY" ]; then
  echo "error: <KEY> argument is required" >&2
  usage >&2
  exit 2
fi

# Default working folder follows bootstrap.sh's default convention.
if [ -z "$WORKING_FOLDER" ]; then
  WORKING_FOLDER="$HOME/Documents/Claude/Projects/$(basename "$(pwd)")"
fi

case "$WORKING_FOLDER" in
  "~") WORKING_FOLDER="$HOME" ;;
  "~/"*) WORKING_FOLDER="$HOME/${WORKING_FOLDER#"~/"}" ;;
esac

if [ ! -d "$WORKING_FOLDER" ]; then
  echo "error: working folder does not exist: $WORKING_FOLDER" >&2
  echo "       Run bootstrap.sh first, or pass --working-folder explicitly." >&2
  exit 1
fi

# Determine the tickets dir the same way pull-ticket.sh does: workspace mode
# (../workspace-CONTEXT.md exists) puts tickets one level up; single-repo mode
# keeps them in the working folder.
if [ -f "$WORKING_FOLDER/../workspace-CONTEXT.md" ]; then
  TICKETS_DIR="$WORKING_FOLDER/../tickets"
elif [ -f "$WORKING_FOLDER/CONTEXT.md" ]; then
  TICKETS_DIR="$WORKING_FOLDER/tickets"
else
  echo "error: no CONTEXT.md found at $WORKING_FOLDER/CONTEXT.md" >&2
  echo "       (and no workspace-CONTEXT.md one level up)." >&2
  exit 1
fi

if [ ! -d "$TICKETS_DIR" ]; then
  echo "error: no tickets/ directory found at $TICKETS_DIR" >&2
  exit 1
fi

ARCHIVE_DIR="$TICKETS_DIR/archive"

# Find the active scratchpad. maxdepth 1 so we never match files already
# inside archive/.
MATCHES=()
while IFS= read -r line; do
  [ -n "$line" ] && MATCHES+=("$line")
done < <(find "$TICKETS_DIR" -maxdepth 1 -type f -name "${KEY}-*.md" 2>/dev/null | sort)

if [ "${#MATCHES[@]}" -eq 0 ]; then
  # Already archived? Give a clearer message than "not found".
  if find "$ARCHIVE_DIR" -maxdepth 1 -type f -name "${KEY}-*.md" 2>/dev/null | grep -q .; then
    echo "error: ${KEY} is already archived (found under $ARCHIVE_DIR)." >&2
    exit 1
  fi
  echo "error: no active ticket matching ${KEY}-*.md in $TICKETS_DIR" >&2
  echo "       (looked for <KEY>-<slug>.md; check the key.)" >&2
  exit 1
fi

if [ "${#MATCHES[@]}" -gt 1 ]; then
  echo "error: multiple tickets match ${KEY}-*.md — refusing to guess:" >&2
  for m in "${MATCHES[@]}"; do echo "         $m" >&2; done
  echo "       Resolve the ambiguity (rename/remove one) and re-run." >&2
  exit 1
fi

SRC="${MATCHES[0]}"
BASENAME="$(basename "$SRC")"
DEST="$ARCHIVE_DIR/$BASENAME"

if [ -e "$DEST" ]; then
  echo "error: an archived ticket with that name already exists: $DEST" >&2
  echo "       Inspect both files and reconcile by hand." >&2
  exit 1
fi

if [ "$DRY_RUN" -eq 1 ]; then
  echo "=== DRY RUN — no files will be moved ==="
  echo "Tickets dir:  $TICKETS_DIR"
  echo "Would move:   $SRC"
  echo "          ->  $DEST"
  exit 0
fi

mkdir -p "$ARCHIVE_DIR"
mv "$SRC" "$DEST"

echo "  ✓ Archived $BASENAME"
echo "    $SRC"
echo "    -> $DEST"
echo
echo "Next:"
echo "  1. Tracker is unchanged — transition the ticket in your tracker yourself if needed."
echo "  2. Note the archival in SESSION-LOG.md, e.g.:"
echo "       - Archived ${KEY} — <one-line outcome>"
