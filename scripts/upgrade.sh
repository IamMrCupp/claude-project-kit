#!/usr/bin/env bash
# Upgrade orchestrator — runs the kit upgrade flow end-to-end with one
# command. Replaces the multi-step ritual of: pull the kit, run
# sync-memory.sh, run sync-templates.sh (+ --workspace if applicable), run
# install-commands.sh --global.
#
# Run from inside any kit-bootstrapped repo. Paths are inferred from $PWD
# via lib/infer.sh (per #163), so no path args are needed.
#
# Pre-flight:
#   - Kit checkout (where this script lives) must be clean. Refuses to run
#     if uncommitted changes are present, to protect against upgrading
#     against in-flight kit work. Pass --skip-pull to bypass.
#   - $PWD must be inside a kit-bootstrapped repo (must have an auto-memory
#     dir at ~/.claude/projects/<sanitized>/memory/).
#
# Default flow (each step is a separately-tested helper, well-isolated):
#   1. git pull --ff-only on the kit checkout
#   2. sync-memory.sh           — auto-memory templates
#   3. sync-templates.sh        — working-folder templates
#   4. sync-templates.sh --workspace  — only if $PWD is inside a workspace
#   5. install-commands.sh --global   — slash commands + agents
#
# Each step is invoked with the same $PWD-inference the user would get if
# they ran the helper themselves. See scripts/lib/infer.sh.
#
# Closes #169.
set -euo pipefail

if [ -z "${BASH_VERSION:-}" ]; then
  echo "error: upgrade.sh requires bash" >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KIT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# shellcheck source=lib/infer.sh
. "$SCRIPT_DIR/lib/infer.sh"

usage() {
  cat <<EOF
Usage: upgrade.sh [options]

Run the kit upgrade flow end-to-end:
  1. (kit checkout) Verify clean, then git pull --ff-only
  2. (current project) sync-memory.sh
  3. (current project) sync-templates.sh
  4. (workspace, if applicable) sync-templates.sh --workspace
  5. (global) install-commands.sh --global

Run from inside any kit-bootstrapped repo. Paths inferred from \$PWD.

Options:
  --dry-run         Print the plan; run nothing destructive. Sub-scripts
                    run in their own --dry-run mode where supported.
  --skip-pull       Don't git-pull the kit; assume already current.
                    Also bypasses the kit-checkout-clean pre-flight check.
  --skip-commands   Don't install/update global slash commands or agents.
  -h, --help        Show this help and exit.

Examples:
  # Default — from inside any kit-bootstrapped repo
  cd ~/Code/some-project && ~/Code/claude-project-kit/scripts/upgrade.sh

  # Preview without writing
  ~/Code/claude-project-kit/scripts/upgrade.sh --dry-run

  # Kit already pulled separately
  ~/Code/claude-project-kit/scripts/upgrade.sh --skip-pull

After completion, restart Claude.app (Cmd+Q + reopen) to pick up new
slash commands. Existing commands are preserved (write-once invariant);
to update changed commands, see install-commands.sh --force-update once
issue #170 ships.
EOF
}

DRY_RUN=0
SKIP_PULL=0
SKIP_COMMANDS=0

while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run) DRY_RUN=1; shift ;;
    --skip-pull) SKIP_PULL=1; shift ;;
    --skip-commands) SKIP_COMMANDS=1; shift ;;
    -h|--help) usage; exit 0 ;;
    --*) echo "error: unknown option: $1" >&2; usage >&2; exit 2 ;;
    *) echo "error: unexpected positional argument: $1" >&2; usage >&2; exit 2 ;;
  esac
done

# ─── Pre-flight 1: kit checkout cleanliness ────────────────────────────────
if [ "$SKIP_PULL" -eq 0 ]; then
  if ! git -C "$KIT_ROOT" rev-parse --git-dir >/dev/null 2>&1; then
    echo "error: kit checkout at $KIT_ROOT is not a git repository." >&2
    echo "       Either point this script at a proper checkout, or pass --skip-pull." >&2
    exit 1
  fi
  if ! git -C "$KIT_ROOT" diff --quiet 2>/dev/null \
     || ! git -C "$KIT_ROOT" diff --cached --quiet 2>/dev/null \
     || [ -n "$(git -C "$KIT_ROOT" ls-files --others --exclude-standard 2>/dev/null)" ]; then
    echo "error: kit checkout has uncommitted changes — refusing to upgrade." >&2
    git -C "$KIT_ROOT" status --short | head -5 | sed 's/^/         /' >&2
    echo "       Resolve first (commit / stash / clean), then re-run, or pass --skip-pull." >&2
    exit 1
  fi
fi

# ─── Pre-flight 2: $PWD must be a kit-bootstrapped repo ───────────────────
INFERRED_MEMORY="$(infer_memory_dir)"
if [ ! -d "$INFERRED_MEMORY" ]; then
  echo "error: \$PWD is not inside a kit-bootstrapped repo." >&2
  echo "       Inferred memory path: $INFERRED_MEMORY" >&2
  echo "       cd into a kit-bootstrapped repo first, then re-run." >&2
  exit 1
fi

WORKING_FOLDER="$(infer_working_folder)"
WORKSPACE_ROOT="$(infer_workspace_root)"

# ─── Plan summary ─────────────────────────────────────────────────────────
if [ "$DRY_RUN" -eq 1 ]; then
  echo "=== DRY RUN — no changes will be made ==="
fi
echo "Upgrade plan"
echo "  Kit:             $KIT_ROOT"
echo "  Repo (\$PWD):     $PWD"
if [ "$SKIP_PULL" -eq 1 ]; then
  echo "  Step 1 (pull):       SKIPPED (--skip-pull)"
else
  echo "  Step 1 (pull):       git pull --ff-only origin main"
fi
echo "  Step 2 (memory):     sync-memory.sh        → $INFERRED_MEMORY"
if [ -n "$WORKING_FOLDER" ]; then
  echo "  Step 3 (templates):  sync-templates.sh     → $WORKING_FOLDER"
else
  echo "  Step 3 (templates):  SKIPPED (no working folder inferred from auto-memory)"
fi
if [ -n "$WORKSPACE_ROOT" ]; then
  echo "  Step 4 (workspace):  sync-templates.sh --workspace  → $WORKSPACE_ROOT"
else
  echo "  Step 4 (workspace):  SKIPPED (not in a workspace)"
fi
if [ "$SKIP_COMMANDS" -eq 1 ]; then
  echo "  Step 5 (commands):   SKIPPED (--skip-commands)"
else
  echo "  Step 5 (commands):   install-commands.sh --global"
fi
echo

if [ "$DRY_RUN" -eq 1 ]; then
  echo "(dry-run; no changes were made — re-run without --dry-run to execute)"
  exit 0
fi

# ─── Step 1 — pull ────────────────────────────────────────────────────────
if [ "$SKIP_PULL" -eq 0 ]; then
  echo "── Step 1 — pulling kit checkout ──"
  git -C "$KIT_ROOT" pull --ff-only origin main
  echo
fi

# ─── Step 2 — sync memory ─────────────────────────────────────────────────
echo "── Step 2 — syncing memory ──"
"$SCRIPT_DIR/sync-memory.sh"
echo

# ─── Step 3 — sync templates (working-folder mode) ────────────────────────
if [ -n "$WORKING_FOLDER" ]; then
  echo "── Step 3 — syncing working-folder templates ──"
  "$SCRIPT_DIR/sync-templates.sh"
  echo
else
  echo "── Step 3 — skipped (no working folder inferred) ──"
  echo
fi

# ─── Step 4 — sync templates (workspace mode) ─────────────────────────────
if [ -n "$WORKSPACE_ROOT" ]; then
  echo "── Step 4 — syncing workspace templates ──"
  "$SCRIPT_DIR/sync-templates.sh" --workspace
  echo
fi

# ─── Step 5 — install commands ────────────────────────────────────────────
if [ "$SKIP_COMMANDS" -eq 0 ]; then
  echo "── Step 5 — installing global slash commands + agents ──"
  "$SCRIPT_DIR/install-commands.sh" --global
  echo
fi

echo "✓ Upgrade complete."
echo
echo "Next steps:"
echo "  • Restart Claude.app (Cmd+Q + reopen) to pick up new slash commands."
echo "  • Existing commands are preserved (write-once invariant). To update"
echo "    changed commands, see install-commands.sh --force-update once #170 ships."
