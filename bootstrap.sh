#!/usr/bin/env bash
# bootstrap.sh — create a Claude working folder and seed auto-memory
# for the project whose repo you run this from.
#
# Run this from the root of the project repo you want to bootstrap. The
# auto-memory path is derived from the current working directory using
# the Claude harness's sanitization rule ('/' -> '-', prefixed with '-').
#
# CONSTRAINT: This script never creates resources in external trackers
# (issues, labels, projects, workflows, sprints). It only captures
# references to existing trackers via --tracker / --jira-project /
# --linear-team flags. See ADR-0001 D3 and CONVENTIONS.md
# "Ticket-driven workflows → What the kit does NOT do with trackers".
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
  --workspace        Treat <working-folder> as a workspace path (multi-repo
                     mode) instead of a single-repo working folder. Bootstrap
                     creates a per-repo subfolder for the current repo inside
                     the workspace, and on first use also seeds the
                     workspace's workspace-CONTEXT.md and tickets/ directory.
                     Subsequent runs against an existing workspace add new
                     repo subfolders without recreating workspace files.
                     See ADR-0001 in the kit for the workspace folder model.
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
  --ci TYPE          Primary CI/automation tool: github-actions,
                     gitlab-ci, jenkins, circleci, atlantis, ansible-cli,
                     other, or none. Seeds a tool-specific reference_ci.md
                     into the project's auto-memory. If omitted in non-
                     interactive mode, CI-reference setup is skipped.
  --force            Proceed even if the working folder already exists
                     and is non-empty. Does NOT override the auto-memory
                     safety check — existing memory files are never
                     overwritten.
  --dry-run          Print what would be created (paths, placeholder
                     substitutions, tracker memory, MEMORY.md index
                     line) and exit without writing anything. Safe to
                     run repeatedly to preview config before committing.
  --trust-working-folder-root
                     Add the working folder's parent directory to
                     permissions.additionalDirectories in
                     ~/.claude/settings.json so Claude Code stops
                     prompting on every read of CONTEXT.md /
                     SESSION-LOG.md / phase checklists. Backs up the
                     existing settings.json before writing; idempotent
                     (skip if already present); honors --dry-run. In
                     interactive mode, bootstrap also asks before
                     making this change — this flag opts in for
                     scripted runs.
  -h, --help         Show this help and exit.

Examples:
  # Interactive (recommended for first-time use)
  cd ~/Code/my-new-project
  ~/Code/claude-project-kit/bootstrap.sh

  # Non-interactive, minimal
  cd ~/Code/my-new-project
  ~/Code/claude-project-kit/bootstrap.sh ~/Documents/Claude/Projects/my-new-project

  # Non-interactive, fully specified (typical real invocation)
  cd ~/Code/my-new-project
  ~/Code/claude-project-kit/bootstrap.sh ~/Documents/Claude/Projects/my-new-project \\
    --tracker jira --jira-project INFRA \\
    --ci github-actions

  # Workspace mode (multi-repo initiative — adds this repo to the workspace)
  cd ~/Code/my-terraform-modules
  ~/Code/claude-project-kit/bootstrap.sh --workspace \\
    ~/Documents/Claude/Projects/acme-platform/ \\
    --tracker jira --jira-project ACME --ci atlantis

After running, edit the copied files (placeholders marked {{LIKE_THIS}}).
Most common memory placeholders are auto-filled; any that couldn't be
derived (e.g. {{REPO_SLUG}} when no git remote is set) stay as-is.

See also:
  SETUP.md      — full bootstrap walkthrough, upgrade flow, troubleshooting
  FEATURES.md   — feature-by-feature reference with example invocations
  CHANGELOG.md  — what's shipped, with notes for existing adopters
EOF
}

tracker_index_line() {
  # args: tracker_type project_name [jira_key] [linear_key]
  # emits the exact line that gets appended to MEMORY.md for this tracker.
  local tracker="$1" project="$2" jira_key="${3:-}" linear_key="${4:-}"
  printf -- '- [Issue tracker for %s](reference_issue_tracker.md) — ' "$project"
  case "$tracker" in
    github)   printf 'tickets live in GitHub Issues on this repo\n' ;;
    jira)     printf 'tickets live in JIRA project `%s`\n' "$jira_key" ;;
    linear)   printf 'issues live in Linear team `%s`\n' "$linear_key" ;;
    gitlab)   printf 'tickets live in GitLab Issues on this repo\n' ;;
    shortcut) printf 'stories live in Shortcut (sc-NNN refs)\n' ;;
    other)    printf 'tickets live in an external system — fill in the placeholders\n' ;;
  esac
}

ci_index_line() {
  # args: ci_tool project_name
  # emits the exact line that gets appended to MEMORY.md for this CI variant.
  local ci="$1" project="$2"
  printf -- '- [CI / automation for %s](reference_ci.md) — ' "$project"
  case "$ci" in
    github-actions) printf 'CI runs on GitHub Actions (`gh run` CLI)\n' ;;
    gitlab-ci)      printf 'CI runs on GitLab CI/CD (`glab ci` CLI)\n' ;;
    jenkins)        printf 'CI runs on Jenkins (host + job names documented in CONTEXT.md)\n' ;;
    circleci)       printf 'CI runs on CircleCI (`circleci` CLI)\n' ;;
    atlantis)       printf 'Terraform automation via Atlantis (PR-comment driven)\n' ;;
    ansible-cli)    printf 'automation via local `ansible-playbook` runs\n' ;;
    other)          printf 'CI/automation tool — fill in the placeholders\n' ;;
  esac
}

detect_terraform() {
  # args: repo_root
  # Returns 0 if the repo shows Terraform / Terragrunt signals.
  # Per ADR-0001 A.6: *.tf, *.tfvars, .terraform.lock.hcl, terragrunt.hcl,
  # or terraform/ / modules/ directories that contain *.tf files.
  local repo="$1"
  [ -f "$repo/.terraform.lock.hcl" ] && return 0
  [ -f "$repo/terragrunt.hcl" ] && return 0
  if compgen -G "$repo/*.tf" > /dev/null 2>&1; then return 0; fi
  if compgen -G "$repo/*.tfvars" > /dev/null 2>&1; then return 0; fi
  if [ -d "$repo/terraform" ] && \
     [ -n "$(find "$repo/terraform" -maxdepth 3 -name '*.tf' 2>/dev/null | head -1)" ]; then
    return 0
  fi
  if [ -d "$repo/modules" ] && \
     [ -n "$(find "$repo/modules" -maxdepth 3 -name '*.tf' 2>/dev/null | head -1)" ]; then
    return 0
  fi
  return 1
}

tracker_key_value() {
  # args: tracker jira_key linear_key
  # emits the value to substitute for {{TRACKER_KEY}} in CONTEXT.md.
  local tracker="$1" jira_key="${2:-}" linear_key="${3:-}"
  case "$tracker" in
    jira)     printf '%s' "$jira_key" ;;
    linear)   printf '%s' "$linear_key" ;;
    github|gitlab|shortcut|other)
              printf '(not applicable for %s tracker)' "$tracker" ;;
    none|"")  printf '(no tracker configured)' ;;
  esac
}

substitute_memory_placeholders_in_dir() {
  # Substitute all derivable placeholders in every .md file at the top level
  # of the given directory. Used for the auto-memory folder, where bootstrap
  # owns content end-to-end. Reads globals: WORKING_FOLDER, REPO_ROOT,
  # PROJECT_NAME, REPO_SLUG, JIRA_PROJECT_KEY, LINEAR_TEAM_KEY,
  # TRACKER_TYPE_VALUE, TRACKER_KEY_VALUE. Echos count of files modified.
  local target_dir="$1"
  local count=0
  local f tmp
  for f in "$target_dir"/*.md; do
    [ -e "$f" ] || continue
    tmp="$(mktemp)"
    if [ -n "$REPO_SLUG" ]; then
      sed -e "s|{{WORKING_FOLDER}}|$WORKING_FOLDER|g" \
          -e "s|{{REPO_PATH}}|$REPO_ROOT|g" \
          -e "s|{{PROJECT_NAME}}|$PROJECT_NAME|g" \
          -e "s|{{REPO_SLUG}}|$REPO_SLUG|g" \
          -e "s|{{JIRA_PROJECT_KEY}}|$JIRA_PROJECT_KEY|g" \
          -e "s|{{LINEAR_TEAM_KEY}}|$LINEAR_TEAM_KEY|g" \
          -e "s|{{TRACKER_TYPE}}|$TRACKER_TYPE_VALUE|g" \
          -e "s|{{TRACKER_KEY}}|$TRACKER_KEY_VALUE|g" \
          "$f" > "$tmp"
    else
      sed -e "s|{{WORKING_FOLDER}}|$WORKING_FOLDER|g" \
          -e "s|{{REPO_PATH}}|$REPO_ROOT|g" \
          -e "s|{{PROJECT_NAME}}|$PROJECT_NAME|g" \
          -e "s|{{JIRA_PROJECT_KEY}}|$JIRA_PROJECT_KEY|g" \
          -e "s|{{LINEAR_TEAM_KEY}}|$LINEAR_TEAM_KEY|g" \
          -e "s|{{TRACKER_TYPE}}|$TRACKER_TYPE_VALUE|g" \
          -e "s|{{TRACKER_KEY}}|$TRACKER_KEY_VALUE|g" \
          "$f" > "$tmp"
    fi
    if ! cmp -s "$f" "$tmp"; then
      mv "$tmp" "$f"
      count=$((count + 1))
    else
      rm -f "$tmp"
    fi
  done
  printf '%s' "$count"
}

substitute_tracker_placeholders_in_dir() {
  # Substitute only tracker placeholders in every .md file at the top level
  # of the given directory. Used for working-folder + workspace-CONTEXT.md
  # where SEED-PROMPT.md owns deep-read content; bootstrap only fills the
  # tracker config it was explicitly told via flags. Reads globals:
  # TRACKER_TYPE_VALUE, TRACKER_KEY_VALUE. Echos count of files modified.
  local target_dir="$1"
  local count=0
  local f tmp
  for f in "$target_dir"/*.md; do
    [ -e "$f" ] || continue
    tmp="$(mktemp)"
    sed -e "s|{{TRACKER_TYPE}}|$TRACKER_TYPE_VALUE|g" \
        -e "s|{{TRACKER_KEY}}|$TRACKER_KEY_VALUE|g" \
        "$f" > "$tmp"
    if ! cmp -s "$f" "$tmp"; then
      mv "$tmp" "$f"
      count=$((count + 1))
    else
      rm -f "$tmp"
    fi
  done
  printf '%s' "$count"
}

kit_version() {
  # Best-effort kit version string — git describe if the kit is a checkout,
  # else "unknown". Never errors.
  local v
  if v="$(git -C "$KIT_ROOT" describe --tags --always --dirty 2>/dev/null)"; then
    printf '%s' "$v"
  else
    printf 'unknown'
  fi
}

write_initial_session_log_entry() {
  # Append a factual Bootstrap entry to <working-folder>/SESSION-LOG.md so the
  # bootstrap session is durable even if a hand-off interrupts before
  # /session-end runs. Reads globals: WORKING_FOLDER, REPO_ROOT, MEMORY_DIR,
  # WORKSPACE_MODE, WORKSPACE_DIR, WORKSPACE_REPO_NAME, WORKSPACE_FIRST_REPO,
  # TRACKER, JIRA_PROJECT_KEY, LINEAR_TEAM_KEY, CI_TOOL, SKIP_MEMORY.
  local target="$WORKING_FOLDER/SESSION-LOG.md"
  [ -f "$target" ] || return 0

  local today; today="$(date +%Y-%m-%d)"
  local mode_label="single-repo"
  if [ "$WORKSPACE_MODE" -eq 1 ]; then
    if [ "$WORKSPACE_FIRST_REPO" -eq 1 ]; then
      mode_label="workspace (new — first repo)"
    else
      mode_label="workspace (added repo to existing workspace)"
    fi
  fi

  local tracker_line="(none)"
  case "$TRACKER" in
    jira)     tracker_line="jira (project: $JIRA_PROJECT_KEY)" ;;
    linear)   tracker_line="linear (team: $LINEAR_TEAM_KEY)" ;;
    github|gitlab|shortcut|other) tracker_line="$TRACKER" ;;
  esac

  local ci_line="(none)"
  if [ -n "$CI_TOOL" ] && [ "$CI_TOOL" != "none" ]; then
    ci_line="$CI_TOOL"
  fi

  local memory_line
  if [ "$SKIP_MEMORY" -eq 1 ]; then
    memory_line="skipped (--skip-memory)"
  else
    memory_line="$MEMORY_DIR"
  fi

  {
    printf '\n## Session: %s — Bootstrap\n\n' "$today"
    printf '**Focus:** Initial bootstrap of the working folder%s.\n\n' \
      "$( [ "$SKIP_MEMORY" -eq 0 ] && printf ' + auto-memory' )"
    printf '**Bootstrap config:**\n'
    printf -- '- Mode: %s\n' "$mode_label"
    if [ "$WORKSPACE_MODE" -eq 1 ]; then
      printf -- '- Workspace: `%s`\n' "$WORKSPACE_DIR"
      printf -- '- Repo subfolder: `%s` (full path: `%s`)\n' \
        "$WORKSPACE_REPO_NAME" "$WORKING_FOLDER"
    else
      printf -- '- Working folder: `%s`\n' "$WORKING_FOLDER"
    fi
    printf -- '- Repo: `%s`\n' "$REPO_ROOT"
    printf -- '- Tracker: %s\n' "$tracker_line"
    printf -- '- CI: %s\n' "$ci_line"
    printf -- '- Auto-memory: %s\n' "$memory_line"
    printf -- '- Kit version: %s\n\n' "$(kit_version)"
    printf '**Open threads / next steps:**\n'
    printf -- '- Run the seed prompt: `Follow the instructions in %s/SEED-PROMPT.md.`\n' \
      "$WORKING_FOLDER"
    if [ "$SKIP_MEMORY" -eq 0 ]; then
      printf -- '- Tune auto-memory at `%s` — prune what does not apply, customize feedback files.\n' "$MEMORY_DIR"
    fi
    if [ "$WORKSPACE_MODE" -eq 1 ]; then
      printf -- '- For each sibling repo in this workspace, re-run `bootstrap.sh --workspace %s` from that repo.\n' "$WORKSPACE_DIR"
    fi
    printf -- '- Fill `[CLAUDE-INFERRED]` / `[HUMAN-CONFIRM]` markers in `CONTEXT.md` once SEED-PROMPT runs.\n'
    printf '\n---\n'
  } >> "$target"
}

trusted_root_for_working_folder() {
  # Echo the directory that should be added to ~/.claude/settings.json's
  # additionalDirectories so Claude Code stops prompting on every read of
  # CONTEXT.md / SESSION-LOG.md / phase checklists. For workspace mode this
  # is the parent of the workspace dir; for single-repo it's the parent of
  # the working folder. Reads globals: WORKSPACE_MODE, WORKSPACE_DIR,
  # WORKING_FOLDER.
  if [ "$WORKSPACE_MODE" -eq 1 ]; then
    dirname "$WORKSPACE_DIR"
  else
    dirname "$WORKING_FOLDER"
  fi
}

add_trusted_root_to_settings() {
  # Append a path to permissions.additionalDirectories in
  # ~/.claude/settings.json. Idempotent — skips if already present. Creates
  # the file if absent. Backs up to settings.json.bak.<timestamp> before
  # any write. Honors $DRY_RUN — prints the diff and returns without
  # writing in dry-run mode.
  #
  # args: trusted_root (absolute path)
  # returns: 0 on success or no-op, 1 on Python failure / unwritable target.
  local trusted_root="$1"
  local settings_dir="$HOME/.claude"
  local settings_file="$settings_dir/settings.json"
  local mode_label=""
  local result=""

  if ! command -v python3 >/dev/null 2>&1; then
    echo "  ! python3 not found — skipping ~/.claude/settings.json update." >&2
    echo "    Add \"$trusted_root\" to permissions.additionalDirectories by hand." >&2
    return 1
  fi

  # Decide current state and what would change. Python returns one of:
  #   ALREADY_PRESENT
  #   WOULD_CREATE
  #   WOULD_APPEND
  # followed by a newline-terminated diff block.
  result="$(python3 - "$trusted_root" "$settings_file" <<'PY' 2>&1
import json, os, sys

trusted_root = sys.argv[1]
settings_file = sys.argv[2]

if os.path.exists(settings_file):
    try:
        with open(settings_file) as f:
            data = json.load(f)
        if not isinstance(data, dict):
            print(f"ERROR existing {settings_file} is not a JSON object", file=sys.stderr)
            sys.exit(2)
    except json.JSONDecodeError as e:
        print(f"ERROR could not parse {settings_file}: {e}", file=sys.stderr)
        sys.exit(2)
else:
    data = None

if data is None:
    print("WOULD_CREATE")
    print(f"  + create {settings_file} with:")
    print(f'      permissions.additionalDirectories: ["{trusted_root}"]')
    sys.exit(0)

perms = data.get("permissions") or {}
additional = perms.get("additionalDirectories") or []
if not isinstance(additional, list):
    print(f"ERROR permissions.additionalDirectories in {settings_file} is not a list", file=sys.stderr)
    sys.exit(2)

if trusted_root in additional:
    print("ALREADY_PRESENT")
    print(f"  ✓ {trusted_root} already in permissions.additionalDirectories")
    sys.exit(0)

print("WOULD_APPEND")
print(f"  + append to permissions.additionalDirectories in {settings_file}:")
print(f'      "{trusted_root}"')
PY
  )" || { echo "  ! settings.json inspection failed:" >&2; echo "$result" >&2; return 1; }

  mode_label="$(printf '%s' "$result" | head -1)"

  case "$mode_label" in
    ALREADY_PRESENT)
      printf '%s\n' "$result" | tail -n +2
      return 0
      ;;
    WOULD_CREATE|WOULD_APPEND)
      printf '%s\n' "$result" | tail -n +2
      ;;
    *)
      echo "  ! unexpected output from settings.json inspector:" >&2
      echo "$result" >&2
      return 1
      ;;
  esac

  if [ "$DRY_RUN" -eq 1 ]; then
    echo "    (dry-run — no changes written)"
    return 0
  fi

  mkdir -p "$settings_dir"

  # Back up if the file exists, then write.
  local backup=""
  if [ -f "$settings_file" ]; then
    backup="$settings_file.bak.$(date +%Y%m%d-%H%M%S)"
    cp "$settings_file" "$backup"
  fi

  if ! python3 - "$trusted_root" "$settings_file" <<'PY'
import json, os, sys

trusted_root = sys.argv[1]
settings_file = sys.argv[2]

if os.path.exists(settings_file):
    with open(settings_file) as f:
        data = json.load(f)
else:
    data = {}

perms = data.setdefault("permissions", {})
additional = perms.setdefault("additionalDirectories", [])
if trusted_root not in additional:
    additional.append(trusted_root)

with open(settings_file, "w") as f:
    json.dump(data, f, indent=2)
    f.write("\n")
PY
  then
    echo "  ! settings.json update failed; restoring backup" >&2
    [ -n "$backup" ] && [ -f "$backup" ] && cp "$backup" "$settings_file"
    return 1
  fi

  if [ -n "$backup" ]; then
    echo "    ✓ updated $settings_file (backup: $backup)"
  else
    echo "    ✓ created $settings_file"
  fi
  return 0
}

SKIP_MEMORY=0
FORCE=0
DRY_RUN=0
WORKSPACE_MODE=0
TRUST_WORKING_FOLDER_ROOT=0
WORKING_FOLDER=""
PROJECT_NAME=""
TRACKER=""
JIRA_PROJECT_KEY=""
LINEAR_TEAM_KEY=""
CI_TOOL=""

while [ $# -gt 0 ]; do
  case "$1" in
    --skip-memory) SKIP_MEMORY=1; shift ;;
    --force) FORCE=1; shift ;;
    --dry-run) DRY_RUN=1; shift ;;
    --workspace) WORKSPACE_MODE=1; shift ;;
    --trust-working-folder-root) TRUST_WORKING_FOLDER_ROOT=1; shift ;;
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
    --ci)
      if [ $# -lt 2 ]; then
        echo "error: --ci requires a value (github-actions|gitlab-ci|jenkins|circleci|atlantis|ansible-cli|other|none)" >&2
        usage >&2
        exit 2
      fi
      CI_TOOL="$2"
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

case "$CI_TOOL" in
  ""|github-actions|gitlab-ci|jenkins|circleci|atlantis|ansible-cli|other|none) ;;
  *) echo "error: --ci must be one of: github-actions, gitlab-ci, jenkins, circleci, atlantis, ansible-cli, other, none (got: $CI_TOOL)" >&2; exit 2 ;;
esac

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

REPO_ROOT="$(pwd)"

if [ "$WORKSPACE_MODE" -eq 0 ] && detect_terraform "$REPO_ROOT"; then
  if [ "$INTERACTIVE" -eq 1 ]; then
    echo
    echo "Detected Terraform-shaped repo (.tf / *.tfvars / .terraform.lock.hcl /"
    echo "terragrunt.hcl / terraform/ / modules/ with .tf files)."
    echo "If a sibling envs/modules repo is part of the same initiative, consider"
    echo "workspace mode (--workspace) so both repos share one working folder."
    echo "See ADR-0001 (docs/adr/0001-multi-repo-folder-model.md)."
    echo
    read -r -p "Sibling envs/modules repo for this initiative? [y/N]: " INPUT
    case "$(printf '%s' "$INPUT" | tr '[:upper:]' '[:lower:]')" in
      y|yes)
        echo
        echo "Recommended: re-run with --workspace pointing at a shared workspace path"
        echo "(e.g. ~/Documents/Claude/Projects/<initiative>) so this repo and the"
        echo "sibling end up as subfolders under one workspace-CONTEXT.md."
        read -r -p "Continue in single-repo mode anyway? [y/N]: " INPUT
        case "$(printf '%s' "$INPUT" | tr '[:upper:]' '[:lower:]')" in
          y|yes) ;;
          *) echo "Aborted."; exit 0 ;;
        esac
        ;;
      *) ;;
    esac
  else
    echo "note: Terraform-shaped repo detected — consider --workspace if a sibling envs/modules repo exists for the same initiative." >&2
  fi
fi

if [ "$INTERACTIVE" -eq 1 ]; then
  REPO_BASENAME="$(basename "$REPO_ROOT")"
  DEFAULT_WF="$HOME/Documents/Claude/Projects/$REPO_BASENAME"

  echo "bootstrap.sh — interactive mode"
  echo "(Run with -h for flags and non-interactive usage.)"
  echo
  echo "Repo: $REPO_ROOT"
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
  "~/"*) WORKING_FOLDER="$HOME/${WORKING_FOLDER#"~/"}" ;;
esac

case "$WORKING_FOLDER" in
  /*) ;;
  *) echo "error: <working-folder> must be an absolute path (got: $WORKING_FOLDER)" >&2; exit 2 ;;
esac

if [ ! -d "$KIT_ROOT/templates" ] || [ ! -d "$KIT_ROOT/memory-templates" ]; then
  echo "error: bootstrap.sh must live alongside templates/ and memory-templates/ in a claude-project-kit checkout" >&2
  exit 1
fi

SANITIZED="$(echo "$REPO_ROOT" | sed 's|/|-|g')"
MEMORY_DIR="$HOME/.claude/projects/${SANITIZED}/memory"

WORKSPACE_DIR=""
WORKSPACE_REPO_NAME=""
if [ "$WORKSPACE_MODE" -eq 1 ]; then
  WORKSPACE_DIR="$WORKING_FOLDER"
  WORKSPACE_REPO_NAME="$(basename "$REPO_ROOT")"
  WORKING_FOLDER="$WORKSPACE_DIR/$WORKSPACE_REPO_NAME"
fi

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

  if [ "$SKIP_MEMORY" -eq 0 ] && [ -z "$CI_TOOL" ]; then
    read -r -p "Primary CI/automation tool? [github-actions/gitlab-ci/jenkins/circleci/atlantis/ansible-cli/other/none, default none]: " INPUT
    CI_TOOL="$(printf '%s' "$INPUT" | tr '[:upper:]' '[:lower:]')"
    CI_TOOL="${CI_TOOL:-none}"
    case "$CI_TOOL" in
      github-actions|gitlab-ci|jenkins|circleci|atlantis|ansible-cli|other|none) ;;
      *) echo "error: invalid CI tool: $CI_TOOL" >&2; exit 2 ;;
    esac
  fi

  if [ "$TRUST_WORKING_FOLDER_ROOT" -eq 0 ]; then
    INTERACTIVE_TRUSTED_ROOT="$(trusted_root_for_working_folder)"
    echo
    echo "Add $INTERACTIVE_TRUSTED_ROOT to permissions.additionalDirectories"
    echo "in ~/.claude/settings.json? This stops Claude Code from prompting on"
    echo "every read of CONTEXT.md / SESSION-LOG.md / phase checklists."
    read -r -p "[y/N]: " INPUT
    case "$(printf '%s' "$INPUT" | tr '[:upper:]' '[:lower:]')" in
      y|yes) TRUST_WORKING_FOLDER_ROOT=1 ;;
    esac
    unset INTERACTIVE_TRUSTED_ROOT
  fi
fi

REPO_SLUG=""
if REMOTE_URL="$(git -C "$REPO_ROOT" remote get-url origin 2>/dev/null)"; then
  REPO_SLUG="$(printf '%s\n' "$REMOTE_URL" \
    | sed -E 's|^https?://[^/]+/||; s|^git@[^:]+:||; s|\.git$||')"
fi

TRACKER_TYPE_VALUE="${TRACKER:-none}"
TRACKER_KEY_VALUE="$(tracker_key_value "$TRACKER" "$JIRA_PROJECT_KEY" "$LINEAR_TEAM_KEY")"

if [ "$WORKSPACE_MODE" -eq 1 ]; then
  echo "Workspace:      $WORKSPACE_DIR"
  echo "Repo subfolder: $WORKSPACE_REPO_NAME (full path: $WORKING_FOLDER)"
else
  echo "Working folder: $WORKING_FOLDER"
fi
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
  if [ -n "$CI_TOOL" ] && [ "$CI_TOOL" != "none" ]; then
    echo "CI / automation: $CI_TOOL"
  fi
fi
echo

if [ "$DRY_RUN" -eq 1 ]; then
  echo "=== DRY RUN — no files will be written ==="
  echo
  if [ "$WORKSPACE_MODE" -eq 1 ]; then
    echo "Workspace dir: $WORKSPACE_DIR"
    if [ -f "$WORKSPACE_DIR/workspace-CONTEXT.md" ]; then
      echo "  ✓ existing workspace (workspace-CONTEXT.md present) — no workspace-level changes"
    else
      echo "  + create workspace dir + tickets/archive/"
      echo "  + copy $KIT_ROOT/templates/workspace/workspace-CONTEXT.md → workspace-CONTEXT.md"
    fi
    echo
  fi
  echo "Would create working folder: $WORKING_FOLDER"
  echo "  + copy $KIT_ROOT/templates/*.md"
  echo "  + rename phase-N-checklist.md → phase-0-checklist.md"
  if [ -d "$KIT_ROOT/templates/.claude" ]; then
    echo "  + copy templates/.claude/ → $WORKING_FOLDER/.claude/ (starter agents + commands)"
  fi
  echo "  + substitute tracker placeholders in CONTEXT.md:"
  echo "      {{TRACKER_TYPE}}      → $TRACKER_TYPE_VALUE"
  echo "      {{TRACKER_KEY}}       → $TRACKER_KEY_VALUE"
  if [ "$WORKSPACE_MODE" -eq 1 ] && [ ! -f "$WORKSPACE_DIR/workspace-CONTEXT.md" ]; then
    echo "  + same substitution in workspace-CONTEXT.md"
  fi
  if [ -e "$WORKING_FOLDER" ] && [ -n "$(ls -A "$WORKING_FOLDER" 2>/dev/null)" ] && [ "$FORCE" -eq 0 ]; then
    echo "  ! working folder already non-empty — real run would fail without --force"
  fi
  echo
  if [ "$SKIP_MEMORY" -eq 0 ]; then
    echo "Would create memory folder: $MEMORY_DIR"
    echo "  + copy $KIT_ROOT/memory-templates/*.md"
    if [ -n "$TRACKER" ] && [ "$TRACKER" != "none" ]; then
      echo "  + copy memory-templates/trackers/$TRACKER.md → reference_issue_tracker.md"
      echo "  + append to MEMORY.md:"
      echo "      $(tracker_index_line "$TRACKER" "$PROJECT_NAME" "$JIRA_PROJECT_KEY" "$LINEAR_TEAM_KEY")"
    fi
    if [ -n "$CI_TOOL" ] && [ "$CI_TOOL" != "none" ]; then
      echo "  + copy memory-templates/ci/$CI_TOOL.md → reference_ci.md"
      echo "  + append to MEMORY.md:"
      echo "      $(ci_index_line "$CI_TOOL" "$PROJECT_NAME")"
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

WORKSPACE_FIRST_REPO=0
if [ "$WORKSPACE_MODE" -eq 1 ]; then
  mkdir -p "$WORKSPACE_DIR/tickets/archive"
  if [ ! -f "$WORKSPACE_DIR/workspace-CONTEXT.md" ]; then
    cp "$KIT_ROOT/templates/workspace/workspace-CONTEXT.md" "$WORKSPACE_DIR/"
    echo "  ✓ Created workspace at $WORKSPACE_DIR (workspace-CONTEXT.md, tickets/archive/)"
    WORKSPACE_FIRST_REPO=1
  else
    echo "  ✓ Existing workspace at $WORKSPACE_DIR — adding repo subfolder $WORKSPACE_REPO_NAME"
  fi
fi

cp "$KIT_ROOT/templates/"*.md "$WORKING_FOLDER/"
mv "$WORKING_FOLDER/phase-N-checklist.md" "$WORKING_FOLDER/phase-0-checklist.md"
echo "  ✓ Copied template files to $WORKING_FOLDER"
echo "  ✓ Renamed phase-N-checklist.md → phase-0-checklist.md"

if [ -d "$KIT_ROOT/templates/.claude" ]; then
  cp -R "$KIT_ROOT/templates/.claude" "$WORKING_FOLDER/"
  echo "  ✓ Copied .claude/ starters (agents + commands) to $WORKING_FOLDER/.claude/"
fi

WF_FILLED="$(substitute_tracker_placeholders_in_dir "$WORKING_FOLDER")"
if [ "$WF_FILLED" -gt 0 ]; then
  echo "  ✓ Filled tracker config in CONTEXT.md"
fi

if [ "$WORKSPACE_MODE" -eq 1 ] && [ -f "$WORKSPACE_DIR/workspace-CONTEXT.md" ]; then
  WS_FILLED="$(substitute_tracker_placeholders_in_dir "$WORKSPACE_DIR")"
  if [ "$WS_FILLED" -gt 0 ]; then
    echo "  ✓ Filled tracker config in workspace-CONTEXT.md"
  fi
fi

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
    tracker_index_line "$TRACKER" "$PROJECT_NAME" "$JIRA_PROJECT_KEY" "$LINEAR_TEAM_KEY" >> "$MEMORY_DIR/MEMORY.md"
    echo "  ✓ Seeded tracker memory ($TRACKER) → reference_issue_tracker.md"
  fi

  if [ -n "$CI_TOOL" ] && [ "$CI_TOOL" != "none" ]; then
    CI_SRC="$KIT_ROOT/memory-templates/ci/$CI_TOOL.md"
    if [ ! -f "$CI_SRC" ]; then
      echo "error: CI template not found: $CI_SRC" >&2
      exit 1
    fi
    cp "$CI_SRC" "$MEMORY_DIR/reference_ci.md"
    ci_index_line "$CI_TOOL" "$PROJECT_NAME" >> "$MEMORY_DIR/MEMORY.md"
    echo "  ✓ Seeded CI memory ($CI_TOOL) → reference_ci.md"
  fi

  FILLED_FILES="$(substitute_memory_placeholders_in_dir "$MEMORY_DIR")"
  echo "  ✓ Filled placeholders in $FILLED_FILES memory files"
  if [ -z "$REPO_SLUG" ]; then
    echo "    (no git remote 'origin' found — {{REPO_SLUG}} left for manual fill)"
  fi
fi

write_initial_session_log_entry
echo "  ✓ Wrote initial Bootstrap entry to $WORKING_FOLDER/SESSION-LOG.md"

if [ "$TRUST_WORKING_FOLDER_ROOT" -eq 1 ]; then
  TRUSTED_ROOT_PATH="$(trusted_root_for_working_folder)"
  echo
  echo "  Updating ~/.claude/settings.json (working-folder root trust):"
  add_trusted_root_to_settings "$TRUSTED_ROOT_PATH" || true
  unset TRUSTED_ROOT_PATH
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
  if [ "$CI_TOOL" = "other" ]; then
    echo "     Also fill in the {{placeholders}} in reference_ci.md"
    echo "     — the 'other' CI template needs your specifics."
  fi
else
  echo "  3. Memory was skipped (--skip-memory). See SETUP.md §Manual alternative"
  echo "     if you want to seed it by hand later."
fi

if [ "$WORKSPACE_MODE" -eq 1 ]; then
  echo
  echo "  ⚠ Workspace mode — per-repo bootstrap required:"
  echo
  echo "    The per-repo subfolder and auto-memory are keyed to each repo's"
  echo "    path, so this run only set them up for $REPO_ROOT."
  if [ "$WORKSPACE_FIRST_REPO" -eq 1 ]; then
    echo "    Every additional repo participating in this workspace needs its"
    echo "    own bootstrap. For each sibling repo:"
  else
    echo "    Repeat for any other sibling repos that haven't been added yet:"
  fi
  echo
  echo "        cd <sibling-repo>"
  echo "        $SCRIPT_DIR/bootstrap.sh --workspace $WORKSPACE_DIR"
  echo
  echo "    Without that step, /session-start and other kit commands will fail"
  echo "    in the sibling repo because reference_ai_working_folder.md won't"
  echo "    be in its auto-memory. See SETUP.md §Workspace mode."
fi
echo
echo "Prefer to fill the templates manually instead? See SETUP.md §3."
