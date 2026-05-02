#!/usr/bin/env bash
# pull-ticket.sh — terminal-driven version of /pull-ticket
#
# Reads tracker config from CONTEXT.md (or ../workspace-CONTEXT.md in
# workspace mode) and creates a per-ticket scratchpad at
# tickets/<KEY>-<slug>.md, fetching ticket data via CLI when available
# (gh for GitHub Issues; jira-cli for JIRA; glab for GitLab) or falling
# back to a stub template when not.
#
# CONSTRAINT: This script is read-only against external trackers. It
# never creates, edits, transitions, or comments on tracker resources.
# See ADR-0001 D3 and CONVENTIONS.md "Ticket-driven workflows → What
# the kit does NOT do with trackers".
set -euo pipefail

if [ -z "${BASH_VERSION:-}" ]; then
  echo "error: pull-ticket.sh requires bash" >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KIT_ROOT="$SCRIPT_DIR"

usage() {
  cat <<EOF
Usage: pull-ticket.sh <KEY> [--working-folder <path>]

Fetch a tracker ticket (read-only) and write a per-ticket scratchpad
to tickets/<KEY>-<slug>.md. Pulls from CLI tools (\`gh\`, \`jira\`, \`glab\`)
when the tracker type is configured in the working folder's CONTEXT.md.
For trackers without a CLI fallback, writes a placeholder stub for
manual fill.

Arguments:
  <KEY>                  The ticket key (e.g. ACME-1234, INFRA-42, 123 for
                         GitHub Issues).

Options:
  --working-folder PATH  Path to the Claude working folder for the
                         current project. If omitted, defaults to
                         \$HOME/Documents/Claude/Projects/\$(basename \$(pwd))
                         (the same default \`bootstrap.sh\` uses).
  --dry-run              Print what would be created and exit without
                         writing anything.
  -h, --help             Show this help and exit.

Tracker support:
  github       \`gh issue view <NUM> --json title,body,state,...\`
  jira         \`jira issue view <KEY>\` (requires jira-cli)
  gitlab       \`glab issue view <NUM>\`
  linear       (no CLI fallback — writes a stub; use the /pull-ticket
               slash command in Claude with the Linear MCP instead)
  shortcut     (no CLI fallback — writes a stub)
  other        (writes a stub for manual fill)
  none         (errors — set up tracker config first or pass --working-folder)

Examples:
  cd ~/Code/my-terraform-modules
  ~/Code/claude-project-kit/pull-ticket.sh ACME-1234

  ~/Code/claude-project-kit/pull-ticket.sh 42 \\
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

CONTEXT_FILE=""
if [ -f "$WORKING_FOLDER/../workspace-CONTEXT.md" ]; then
  # Workspace mode: workspace-CONTEXT.md takes precedence
  CONTEXT_FILE="$WORKING_FOLDER/../workspace-CONTEXT.md"
  TICKETS_DIR="$WORKING_FOLDER/../tickets"
elif [ -f "$WORKING_FOLDER/CONTEXT.md" ]; then
  CONTEXT_FILE="$WORKING_FOLDER/CONTEXT.md"
  TICKETS_DIR="$WORKING_FOLDER/tickets"
else
  echo "error: no CONTEXT.md found at $WORKING_FOLDER/CONTEXT.md" >&2
  echo "       (and no workspace-CONTEXT.md one level up)." >&2
  exit 1
fi

# Parse tracker config from the CONTEXT file. Looking for lines like
#   - **Tracker type:** jira
#   - **Project / team key:** ACME
TRACKER_TYPE="$(grep -E '^- \*\*Tracker type:\*\*' "$CONTEXT_FILE" | sed -E 's/.*\*\*Tracker type:\*\*[[:space:]]+//' | head -1)"
TRACKER_KEY="$(grep -E '^- \*\*Project / team key:\*\*' "$CONTEXT_FILE" | sed -E 's/.*\*\*Project \/ team key:\*\*[[:space:]]+//' | head -1)"

if [ -z "$TRACKER_TYPE" ]; then
  echo "error: could not parse 'Tracker type:' from $CONTEXT_FILE" >&2
  echo "       Expected a line like '- **Tracker type:** jira'." >&2
  exit 1
fi

# Strip trailing whitespace
TRACKER_TYPE="$(printf '%s' "$TRACKER_TYPE" | sed 's/[[:space:]]*$//')"

if [ "$TRACKER_TYPE" = "none" ]; then
  echo "error: tracker type is 'none' in $CONTEXT_FILE" >&2
  echo "       Set up tracker config first (re-run bootstrap with --tracker)" >&2
  echo "       or fill in CONTEXT.md manually." >&2
  exit 1
fi

# Try to fetch summary + status. Fall back to stub if no CLI / fetch fails.
TITLE=""
STATUS="Open"
SUMMARY=""
TRACKER_URL=""
FETCH_METHOD="stub"

case "$TRACKER_TYPE" in
  github)
    NUM="${KEY#\#}"  # accept '#42' or '42'
    if command -v gh > /dev/null 2>&1; then
      if FETCH="$(gh issue view "$NUM" --json title,state,body,url 2>/dev/null)"; then
        TITLE="$(printf '%s' "$FETCH" | sed -nE 's/.*"title":"([^"]*)".*/\1/p')"
        STATUS="$(printf '%s' "$FETCH" | sed -nE 's/.*"state":"([^"]*)".*/\1/p')"
        TRACKER_URL="$(printf '%s' "$FETCH" | sed -nE 's/.*"url":"([^"]*)".*/\1/p')"
        FETCH_METHOD="gh-cli"
      fi
    fi
    ;;
  jira)
    if command -v jira > /dev/null 2>&1; then
      # jira-cli (https://github.com/ankitpokhrel/jira-cli) — best-effort
      if FETCH="$(jira issue view "$KEY" --plain 2>/dev/null)"; then
        TITLE="$(printf '%s' "$FETCH" | head -1 | sed -E 's/^[[:space:]]*//')"
        STATUS="$(printf '%s' "$FETCH" | grep -i '^Status:' | head -1 | sed -E 's/^[Ss]tatus:[[:space:]]*//' || echo "Open")"
        FETCH_METHOD="jira-cli"
      fi
    fi
    ;;
  gitlab)
    NUM="${KEY#\#}"
    if command -v glab > /dev/null 2>&1; then
      if FETCH="$(glab issue view "$NUM" 2>/dev/null)"; then
        TITLE="$(printf '%s' "$FETCH" | grep -i '^title:' | head -1 | sed -E 's/^[Tt]itle:[[:space:]]*//')"
        FETCH_METHOD="glab-cli"
      fi
    fi
    ;;
esac

# Generate slug. Fall back to "stub" if no title fetched.
if [ -n "$TITLE" ]; then
  SLUG="$(printf '%s' "$TITLE" \
    | tr '[:upper:]' '[:lower:]' \
    | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//' \
    | cut -c1-40 \
    | sed -E 's/-+$//')"
else
  SLUG="stub"
fi

TICKET_FILE="$TICKETS_DIR/${KEY}-${SLUG}.md"
TODAY="$(date +%Y-%m-%d)"

# Idempotence guard: refuse to overwrite an existing scratchpad.
if [ -e "$TICKET_FILE" ]; then
  echo "error: ticket file already exists: $TICKET_FILE" >&2
  echo "       Inspect or remove it manually, or pick a different slug." >&2
  exit 1
fi
EXISTING="$(find "$TICKETS_DIR" -maxdepth 2 -name "${KEY}-*.md" 2>/dev/null | head -1 || true)"
if [ -n "$EXISTING" ]; then
  echo "error: a scratchpad with key prefix ${KEY}- already exists: $EXISTING" >&2
  echo "       Remove or rename it, or use the /pull-ticket slash command in Claude" >&2
  echo "       to update via the tracker MCP." >&2
  exit 1
fi

if [ "$DRY_RUN" -eq 1 ]; then
  echo "=== DRY RUN — no files will be written ==="
  echo "Tracker file:   $CONTEXT_FILE"
  echo "Tracker type:   $TRACKER_TYPE"
  echo "Tracker key:    $TRACKER_KEY"
  echo "Tickets dir:    $TICKETS_DIR"
  echo "Fetch method:   $FETCH_METHOD"
  echo "Ticket key:     $KEY"
  echo "Title:          ${TITLE:-(not fetched — stub will be written)}"
  echo "Slug:           $SLUG"
  echo "Would write:    $TICKET_FILE"
  exit 0
fi

mkdir -p "$TICKETS_DIR"
[ -d "$TICKETS_DIR/archive" ] || mkdir -p "$TICKETS_DIR/archive"

TEMPLATE="$KIT_ROOT/templates/workspace/ticket.md"
if [ ! -f "$TEMPLATE" ]; then
  echo "error: ticket template not found: $TEMPLATE" >&2
  exit 1
fi

# Use a here-doc for status with placeholder when not fetched.
TITLE_FILL="${TITLE:-{{TITLE — fill in from tracker}}}"
URL_FILL="${TRACKER_URL:-{{TRACKER_URL}}}"

sed -e "s|{{KEY}}|$KEY|g" \
    -e "s|{{TITLE}}|$TITLE_FILL|g" \
    -e "s|{{TRACKER_URL}}|$URL_FILL|g" \
    -e "s#{{Open | In progress | Blocked | Done}}#$STATUS#g" \
    -e "s|{{YYYY-MM-DD}}|$TODAY|g" \
    "$TEMPLATE" > "$TICKET_FILE"

echo "  ✓ Wrote $TICKET_FILE"
echo "  ✓ Fetch method: $FETCH_METHOD"
if [ "$FETCH_METHOD" = "stub" ]; then
  echo "    (no CLI fallback for tracker '$TRACKER_TYPE' — fill Summary / AC manually,"
  echo "     or use the /pull-ticket slash command in Claude with the relevant MCP.)"
fi
echo
echo "Next:"
echo "  1. Open $TICKET_FILE and fill or verify Summary / Acceptance criteria."
echo "  2. See CONVENTIONS.md \"Ticket-driven workflows\" for branch / PR / commit shape."
