#!/usr/bin/env bash
# check-convention-drift.sh — flag when a mutable convention stated in a
# working folder's CONTEXT.md contradicts the auto-memory `feedback_*.md`
# that owns that convention.
#
# Background (#258): conventions like merge strategy were stored in BOTH
# CONTEXT.md "Working Rules" AND auto-memory, with no precedence. When one
# changed, the other went stale and the two contradicted each other. A real
# failure: a stale "squash merge" line in CONTEXT.md overrode a correct
# "merge commit" memory, and a production PR was squash-merged against the
# rule. Auto-memory is the source of truth; CONTEXT.md must only point at it.
#
# This is a READ-ONLY lint. It never edits anything. It exits:
#   0  — no conflicts (or nothing to compare: no working folder / no memory)
#   1  — at least one convention conflict found
#   2  — usage error
#
# Usage:
#   check-convention-drift.sh [WORKING_FOLDER]
#
# WORKING_FOLDER defaults to the working folder inferred from $PWD (via the
# same auto-memory pointer the rest of the kit uses). The auto-memory dir is
# always inferred from $PWD's repo root.
#
# The match is deliberately heuristic and SCOPED to the convention sections
# (CONTEXT.md "Working Rules", workspace-CONTEXT.md "Cross-repo notes") so a
# stray "we squashed a bug" in prose elsewhere doesn't false-positive. It is
# a warning aid, not a parser — when in doubt it favors silence over noise.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ ! -f "$SCRIPT_DIR/lib/infer.sh" ]; then
  echo "check-convention-drift: missing shared lib at $SCRIPT_DIR/lib/infer.sh" >&2
  echo "  re-run install-scripts.sh to (re)install the kit helpers." >&2
  exit 2
fi
# shellcheck source=lib/infer.sh
. "$SCRIPT_DIR/lib/infer.sh"

usage() {
  sed -n '2,30p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
  exit 2
}

case "${1:-}" in
  -h|--help) usage ;;
esac

WORKING_FOLDER="${1:-$(infer_working_folder "$PWD")}"
MEMORY_DIR="$(infer_memory_dir "$PWD")"

if [ -z "$WORKING_FOLDER" ] || [ ! -f "$WORKING_FOLDER/CONTEXT.md" ]; then
  echo "check-convention-drift: no working folder with CONTEXT.md found — nothing to check." >&2
  exit 0
fi
if [ ! -d "$MEMORY_DIR" ]; then
  echo "check-convention-drift: no auto-memory dir at $MEMORY_DIR — nothing to check." >&2
  exit 0
fi

# Extract the named section of a markdown file: lines from "## <heading>"
# up to (but not including) the next "## " heading. Echoes nothing if the
# heading is absent.
section() {
  local file="$1" heading="$2"
  [ -f "$file" ] || return 0
  awk -v h="## $heading" '
    BEGIN { lh = tolower(h) }
    { line = $0; sub(/[ \t]+$/, "", line) }
    tolower(line) == lh {inseg=1; next}
    inseg && /^## / {inseg=0}
    inseg {print}
  ' "$file"
}

# Does $text affirmatively assert $keyword? True when the keyword appears on
# a line that is NOT negated (no never/not/no/don't/avoid before it). Used
# both to read a memory's asserted pole and to find a contradicting CONTEXT
# directive. Case-insensitive.
# NEGATORS is deliberately conservative — a missed negator produces a FALSE
# POSITIVE (we claim drift where the two sources agree), which is the costlier
# error for a check wired into session start. The bare-"no" alternative is
# boundary-anchored so "piano" doesn't read as a negation of "no".
NEGATORS="never|not |n't|no longer|avoid|do not|don't|instead of|(^|[^[:alnum:]])no[[:space:]]"

asserts() {
  local text="$1" keyword="$2"
  echo "$text" | grep -iE "$keyword" | grep -qivE "$NEGATORS"
}

# One convention row: memory file | human label | pole-A regex | pole-B regex.
# A memory asserts whichever pole it does NOT negate; a conflict is the
# CONTEXT section affirmatively asserting the OPPOSITE pole.
#
# Add rows as more conventions gain clean binary poles. Merge strategy is the
# only row today — it is the #258 failure, and the one convention with a clean,
# unambiguous binary. Others (commit co-authorship, branch naming) need a pole
# pair that survives paraphrase before they earn a row here.
CONVENTIONS=(
  "feedback_merge_strategy.md|merge strategy|merge commit|squash"
)

conflicts=0
compared=0
context_md="$WORKING_FOLDER/CONTEXT.md"
workspace_md="$WORKING_FOLDER/../workspace-CONTEXT.md"

# Sections of the working folder where convention prose would (wrongly) live.
rules_text="$(section "$context_md" "Working Rules")"
if [ -f "$workspace_md" ]; then
  rules_text="$rules_text
$(section "$workspace_md" "Cross-repo notes")"
fi

for row in "${CONVENTIONS[@]}"; do
  IFS='|' read -r mem_file label pole_a pole_b <<<"$row"
  mem_path="$MEMORY_DIR/$mem_file"
  [ -f "$mem_path" ] || continue
  mem_text="$(cat "$mem_path")"

  # Which pole does the memory assert? Read the un-negated one.
  mem_pole="" ; opposite=""
  if asserts "$mem_text" "$pole_a"; then mem_pole="$pole_a"; opposite="$pole_b"
  elif asserts "$mem_text" "$pole_b"; then mem_pole="$pole_b"; opposite="$pole_a"
  else
    continue   # memory is ambiguous; don't guess
  fi
  compared=$((compared + 1))

  # Conflict: the CONTEXT rules section affirmatively asserts the opposite.
  if asserts "$rules_text" "$opposite"; then
    conflicts=$((conflicts + 1))
    echo "CONFLICT — $label:"
    echo "  auto-memory ($mem_file) asserts: \"$mem_pole\""
    echo "  but CONTEXT.md Working Rules asserts: \"$opposite\""
    echo "  → auto-memory wins. Remove the rule text from CONTEXT.md and point at the memory instead."
    echo "    (see CONVENTIONS.md → Auto-memory, and #258)"
  fi
done

if [ "$conflicts" -gt 0 ]; then
  echo ""
  echo "check-convention-drift: $conflicts convention conflict(s) found." >&2
  exit 1
fi

# "Checked and clean" and "could not check" are different answers. Reporting the
# second as the first is how a blind lint hands out a green light — which matters
# more now that this runs unattended at session start.
if [ -z "${rules_text//[[:space:]]/}" ]; then
  echo "check-convention-drift: nothing to compare — no '## Working Rules' section found in $context_md." >&2
  exit 0
fi
if [ "$compared" -eq 0 ]; then
  echo "check-convention-drift: nothing to compare — no owning feedback_*.md memory asserted a known convention pole." >&2
  exit 0
fi

echo "check-convention-drift: no convention drift between CONTEXT.md and auto-memory ($compared convention(s) compared)."
exit 0
