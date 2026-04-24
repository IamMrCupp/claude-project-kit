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
Usage: bootstrap.sh [options] [<working-folder>]

Create a Claude working folder and seed auto-memory for the project
whose repo you run this from. The current working directory is assumed
to be the repo root.

If <working-folder> is omitted and stdin is a terminal, bootstrap.sh
prompts interactively for path, project name, and whether to seed
auto-memory — intended for first-time users. Scripted invocations
without a path argument still error (no hang waiting for input).

Arguments:
  <working-folder>   Absolute path where the Claude working folder will
                     be created (e.g. ~/Documents/Claude/Projects/foo).
                     Omit to run interactively.

Options:
  --skip-memory      Skip copying memory-templates/ into the auto-memory
                     folder. Only the working folder will be seeded.
  --project-name NAME
                     Override the auto-derived project name used to fill
                     {{PROJECT_NAME}} placeholders in seeded memory files.
                     Defaults to the basename of <working-folder>.
  --tracker TYPE     Issue tracker type: github, jira, linear, gitlab,
                     shortcut, other, or none. Seeds a tracker-specific
                     reference_issue_tracker.md into the project's
                     auto-memory. If omitted in non-interactive mode,
                     tracker setup is skipped entirely.
  --jira-project KEY Set the JIRA project key (e.g. INFRA). Implies
                     --tracker jira if --tracker isn't also passed.
  --linear-team KEY  Set the Linear team key (e.g. ENG). Implies
                     --tracker linear if --tracker isn't also passed.
  --force            Proceed even if the working folder already exists
                     and is non-empty. Does NOT override the auto-memory
                     safety check — existing memory files are never
                     overwritten.
  --dry-run          Print what would be created (paths, placeholder
                     substitutions, tracker memory, MEMORY.md index
                     line) and exit without writing anything. Safe to
                     run repeatedly to preview config before committing.
  -h, --help         Show this help and exit.

Examples:
  # Non-interactive
  cd ~/Code/my-new-project
  ~/Code/claude-project-kit/bootstrap.sh ~/Documents/Claude/Projects/my-new-project

  # Interactive
  cd ~/Code/my-new-project
  ~/Code/claude-project-kit/bootstrap.sh

After running, edit the copied files (placeholders marked {{LIKE_THIS}}).
Most common memory placeholders are auto-filled; any that couldn't be
derived (e.g. {{REPO_SLUG}} when no git remote is set) stay as-is.
See SETUP.md in the kit repo for the full walk-through.
EOF
}

SKIP_MEMORY=0
FORCE=0
DRY_RUN=0
WORKING_FOLDER=""
PROJECT_NAME=""
TRACKER=""
JIRA_PROJECT_KEY=""
LINEAR_TEAM_KEY=""

while [ $# -gt 0 ]; do
  case "$1" in
    --skip-memory) SKIP_MEMORY=1; shift ;;
    --force) FORCE=1; shift ;;
    --dry-run) DRY_RUN=1; shift ;;
    --project-name)
      if [ $# -lt 2 ]; then
        echo "error: --project-name requires a value" >&2
        usage >&2
        exit 2
      fi
      PROJECT_NAME="$2"
      shift 2
      ;;
    --tracker)
      if [ $# -lt 2 ]; then
        echo "error: --tracker requires a value (github|jira|other|none)" >&2
        usage >&2
        exit 2
      fi
      TRACKER="$2"
      shift 2
      ;;
    --jira-project)
      if [ $# -lt 2 ]; then
        echo "error: --jira-project requires a value" >&2
        usage >&2
        exit 2
      fi
      JIRA_PROJECT_KEY="$2"
      shift 2
      ;;
    --linear-team)
      if [ $# -lt 2 ]; then
        echo "error: --linear-team requires a value" >&2
        usage >&2
        exit 2
      fi
      LINEAR_TEAM_KEY="$2"
      shift 2
      ;;
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

if [ -n "$JIRA_PROJECT_KEY" ] && [ -z "$TRACKER" ]; then
  TRACKER="jira"
fi
if [ -n "$LINEAR_TEAM_KEY" ] && [ -z "$TRACKER" ]; then
  TRACKER="linear"
fi

case "$TRACKER" in
  ""|github|jira|linear|gitlab|shortcut|other|none) ;;
  *) echo "error: --tracker must be one of: github, jira, linear, gitlab, shortcut, other, none (got: $TRACKER)" >&2; exit 2 ;;
esac

if [ "$TRACKER" = "jira" ] && [ -z "$JIRA_PROJECT_KEY" ] && [ ! -t 0 ]; then
  echo "error: --tracker jira requires --jira-project <KEY> in non-interactive mode" >&2
  exit 2
fi
if [ "$TRACKER" = "linear" ] && [ -z "$LINEAR_TEAM_KEY" ] && [ ! -t 0 ]; then
  echo "error: --tracker linear requires --linear-team <KEY> in non-interactive mode" >&2
  exit 2
fi

INTERACTIVE=0
if [ -z "$WORKING_FOLDER" ]; then
  if [ -t 0 ] && [ -t 1 ]; then
    INTERACTIVE=1
  else
    echo "error: missing <working-folder> argument" >&2
    usage >&2
    exit 2
  fi
fi

if [ "$INTERACTIVE" -eq 1 ]; then
  REPO_BASENAME="$(basename "$(pwd)")"
  DEFAULT_WF="$HOME/Documents/Claude/Projects/$REPO_BASENAME"

  echo "bootstrap.sh — interactive mode"
  echo "(Run with -h for flags and non-interactive usage.)"
  echo
  echo "Repo: $(pwd)"
  echo
  echo "Working-folder path. Examples:"
  echo "  $DEFAULT_WF"
  echo "  $HOME/claude-projects/$REPO_BASENAME"
  echo "  (any absolute path outside the repo — see SETUP.md §1)"
  read -r -p "Path [$DEFAULT_WF]: " INPUT
  WORKING_FOLDER="${INPUT:-$DEFAULT_WF}"
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

if [ -z "$PROJECT_NAME" ]; then
  PROJECT_NAME="$(basename "$WORKING_FOLDER")"
fi

if [ "$INTERACTIVE" -eq 1 ]; then
  read -r -p "Project name [$PROJECT_NAME]: " INPUT
  PROJECT_NAME="${INPUT:-$PROJECT_NAME}"

  read -r -p "Seed auto-memory? [Y/n]: " INPUT
  case "$(printf '%s' "$INPUT" | tr '[:upper:]' '[:lower:]')" in
    ""|y|yes) ;;
    n|no) SKIP_MEMORY=1 ;;
    *) echo "error: invalid response: $INPUT" >&2; exit 2 ;;
  esac

  if [ "$SKIP_MEMORY" -eq 0 ] && [ -z "$TRACKER" ]; then
    read -r -p "Issue tracker? [github/jira/linear/gitlab/shortcut/other/none, default github]: " INPUT
    TRACKER="$(printf '%s' "$INPUT" | tr '[:upper:]' '[:lower:]')"
    TRACKER="${TRACKER:-github}"
    case "$TRACKER" in
      github|jira|linear|gitlab|shortcut|other|none) ;;
      *) echo "error: invalid tracker: $TRACKER" >&2; exit 2 ;;
    esac

    if [ "$TRACKER" = "jira" ] && [ -z "$JIRA_PROJECT_KEY" ]; then
      read -r -p "JIRA project key (e.g. INFRA): " JIRA_PROJECT_KEY
      if [ -z "$JIRA_PROJECT_KEY" ]; then
        echo "error: JIRA project key is required when tracker is jira" >&2
        exit 2
      fi
    fi

    if [ "$TRACKER" = "linear" ] && [ -z "$LINEAR_TEAM_KEY" ]; then
      read -r -p "Linear team key (e.g. ENG): " LINEAR_TEAM_KEY
      if [ -z "$LINEAR_TEAM_KEY" ]; then
        echo "error: Linear team key is required when tracker is linear" >&2
        exit 2
      fi
    fi
  fi
fi

REPO_SLUG=""
if REMOTE_URL="$(git -C "$REPO_ROOT" remote get-url origin 2>/dev/null)"; then
  REPO_SLUG="$(printf '%s\n' "$REMOTE_URL" \
    | sed -E 's|^https?://[^/]+/||; s|^git@[^:]+:||; s|\.git$||')"
fi

echo "Working folder: $WORKING_FOLDER"
echo "Repo root:      $REPO_ROOT"
echo "Project name:   $PROJECT_NAME"
if [ "$SKIP_MEMORY" -eq 0 ]; then
  echo "Memory folder:  $MEMORY_DIR"
  if [ -n "$REPO_SLUG" ]; then
    echo "Repo slug:      $REPO_SLUG (from git remote origin)"
  fi
  if [ -n "$TRACKER" ] && [ "$TRACKER" != "none" ]; then
    case "$TRACKER" in
      jira)   echo "Issue tracker:  jira (project: $JIRA_PROJECT_KEY)" ;;
      linear) echo "Issue tracker:  linear (team: $LINEAR_TEAM_KEY)" ;;
      *)      echo "Issue tracker:  $TRACKER" ;;
    esac
  fi
fi
echo

if [ "$DRY_RUN" -eq 1 ]; then
  echo "=== DRY RUN — no files will be written ==="
  echo
  echo "Would create working folder: $WORKING_FOLDER"
  echo "  + copy $KIT_ROOT/templates/*.md"
  echo "  + rename phase-N-checklist.md → phase-0-checklist.md"
  if [ -e "$WORKING_FOLDER" ] && [ -n "$(ls -A "$WORKING_FOLDER" 2>/dev/null)" ] && [ "$FORCE" -eq 0 ]; then
    echo "  ! working folder already non-empty — real run would fail without --force"
  fi
  echo
  if [ "$SKIP_MEMORY" -eq 0 ]; then
    echo "Would create memory folder: $MEMORY_DIR"
    echo "  + copy $KIT_ROOT/memory-templates/*.md"
    if [ -n "$TRACKER" ] && [ "$TRACKER" != "none" ]; then
      echo "  + copy memory-templates/trackers/$TRACKER.md → reference_issue_tracker.md"
      echo "  + append index line to MEMORY.md"
    fi
    echo "  + substitute placeholders:"
    echo "      {{WORKING_FOLDER}}    → $WORKING_FOLDER"
    echo "      {{REPO_PATH}}         → $REPO_ROOT"
    echo "      {{PROJECT_NAME}}      → $PROJECT_NAME"
    if [ -n "$REPO_SLUG" ]; then
      echo "      {{REPO_SLUG}}         → $REPO_SLUG"
    else
      echo "      {{REPO_SLUG}}         → (not set — no git remote 'origin')"
    fi
    if [ -n "$JIRA_PROJECT_KEY" ]; then
      echo "      {{JIRA_PROJECT_KEY}}  → $JIRA_PROJECT_KEY"
    fi
    if [ -n "$LINEAR_TEAM_KEY" ]; then
      echo "      {{LINEAR_TEAM_KEY}}   → $LINEAR_TEAM_KEY"
    fi
    if [ -d "$MEMORY_DIR" ] && [ -n "$(ls -A "$MEMORY_DIR" 2>/dev/null)" ]; then
      echo "  ! memory folder already non-empty — real run would fail (never overwrites memory)"
    fi
  else
    echo "Memory seeding skipped (--skip-memory)."
  fi
  echo
  echo "No changes made. Re-run without --dry-run to apply."
  exit 0
fi

if [ "$INTERACTIVE" -eq 1 ]; then
  read -r -p "Proceed? [Y/n]: " INPUT
  case "$(printf '%s' "$INPUT" | tr '[:upper:]' '[:lower:]')" in
    ""|y|yes) ;;
    *) echo "Aborted."; exit 0 ;;
  esac
  echo
fi

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

  if [ -n "$TRACKER" ] && [ "$TRACKER" != "none" ]; then
    TRACKER_SRC="$KIT_ROOT/memory-templates/trackers/$TRACKER.md"
    if [ ! -f "$TRACKER_SRC" ]; then
      echo "error: tracker template not found: $TRACKER_SRC" >&2
      exit 1
    fi
    cp "$TRACKER_SRC" "$MEMORY_DIR/reference_issue_tracker.md"
    {
      printf -- '- [Issue tracker for %s](reference_issue_tracker.md) — ' "$PROJECT_NAME"
      case "$TRACKER" in
        github)   printf 'tickets live in GitHub Issues on this repo\n' ;;
        jira)     printf 'tickets live in JIRA project `%s`\n' "$JIRA_PROJECT_KEY" ;;
        linear)   printf 'issues live in Linear team `%s`\n' "$LINEAR_TEAM_KEY" ;;
        gitlab)   printf 'tickets live in GitLab Issues on this repo\n' ;;
        shortcut) printf 'stories live in Shortcut (sc-NNN refs)\n' ;;
        other)    printf 'tickets live in an external system — fill in the placeholders\n' ;;
      esac
    } >> "$MEMORY_DIR/MEMORY.md"
    echo "  ✓ Seeded tracker memory ($TRACKER) → reference_issue_tracker.md"
  fi

  FILLED_FILES=0
  for f in "$MEMORY_DIR"/*.md; do
    tmp="$(mktemp)"
    if [ -n "$REPO_SLUG" ]; then
      sed -e "s|{{WORKING_FOLDER}}|$WORKING_FOLDER|g" \
          -e "s|{{REPO_PATH}}|$REPO_ROOT|g" \
          -e "s|{{PROJECT_NAME}}|$PROJECT_NAME|g" \
          -e "s|{{REPO_SLUG}}|$REPO_SLUG|g" \
          -e "s|{{JIRA_PROJECT_KEY}}|$JIRA_PROJECT_KEY|g" \
          -e "s|{{LINEAR_TEAM_KEY}}|$LINEAR_TEAM_KEY|g" \
          "$f" > "$tmp"
    else
      sed -e "s|{{WORKING_FOLDER}}|$WORKING_FOLDER|g" \
          -e "s|{{REPO_PATH}}|$REPO_ROOT|g" \
          -e "s|{{PROJECT_NAME}}|$PROJECT_NAME|g" \
          -e "s|{{JIRA_PROJECT_KEY}}|$JIRA_PROJECT_KEY|g" \
          -e "s|{{LINEAR_TEAM_KEY}}|$LINEAR_TEAM_KEY|g" \
          "$f" > "$tmp"
    fi
    if ! cmp -s "$f" "$tmp"; then
      mv "$tmp" "$f"
      FILLED_FILES=$((FILLED_FILES + 1))
    else
      rm -f "$tmp"
    fi
  done
  echo "  ✓ Filled placeholders in $FILLED_FILES memory files"
  if [ -z "$REPO_SLUG" ]; then
    echo "    (no git remote 'origin' found — {{REPO_SLUG}} left for manual fill)"
  fi
fi

echo
echo "Bootstrap complete."
echo
echo "Next steps:"
echo "  1. Open Claude Code in this repo (from $REPO_ROOT)."
echo "  2. Paste this prompt:"
echo
echo "       Follow the instructions in $WORKING_FOLDER/SEED-PROMPT.md."
echo
echo "     Claude will deep-read the repo, fill the working-folder templates,"
echo "     flag inferences with [CLAUDE-INFERRED] / [HUMAN-CONFIRM] markers,"
echo "     and stop for your review before doing anything else."
if [ "$SKIP_MEMORY" -eq 0 ]; then
  if [ -n "$REPO_SLUG" ]; then
    echo "  3. (Optional) Review memory at $MEMORY_DIR —"
    echo "     common placeholders pre-filled; tune feedback files to taste."
  else
    echo "  3. Review memory at $MEMORY_DIR —"
    echo "     {{REPO_SLUG}} needs manual fill in project_current.md; others done."
  fi
  if [ "$TRACKER" = "other" ]; then
    echo "     Also fill in the {{placeholders}} in reference_issue_tracker.md"
    echo "     — the 'other' tracker template needs your specifics."
  fi
else
  echo "  3. Memory was skipped (--skip-memory). See SETUP.md §Manual alternative"
  echo "     if you want to seed it by hand later."
fi
echo
echo "Prefer to fill the templates manually instead? See SETUP.md §3."
