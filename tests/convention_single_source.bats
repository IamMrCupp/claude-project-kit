#!/usr/bin/env bats
# Regression guard for #258 — mutable conventions must be single-sourced in
# auto-memory `feedback_*.md`, not restated in the CONTEXT.md templates.
#
# Background: the working-folder model stored the same mutable conventions
# (merge strategy, branch naming, commit style) in BOTH `CONTEXT.md`'s
# "Working Rules" section AND auto-memory feedback files, with no declared
# precedence. When a rule changed, one copy went stale and the two
# contradicted each other. A real failure (2026-06): a stale "squash merge"
# line in CONTEXT.md overrode a correct "merge commit" memory and a prod PR
# got squash-merged against the rule.
#
# These tests assert the templates now POINT at memory rather than restating
# rule text, and that the precedence statement is present where it's needed.

load 'helpers'

CONTEXT_TMPL="$KIT_ROOT/templates/CONTEXT.md"
WORKSPACE_CONTEXT_TMPL="$KIT_ROOT/templates/workspace/workspace-CONTEXT.md"
MEMORY_INDEX="$KIT_ROOT/memory-templates/MEMORY.md"
MERGE_MEM="$KIT_ROOT/memory-templates/feedback_merge_strategy.md"
CONVENTIONS="$KIT_ROOT/CONVENTIONS.md"

# Extract the "## Working Rules" section of the CONTEXT template (up to the
# next top-level heading) so keyword checks are scoped, not whole-file.
working_rules_section() {
  awk '/^## Working Rules/{f=1} f&&/^## /&&!/^## Working Rules/{if(seen){exit}} /^## Working Rules/{seen=1} f' "$CONTEXT_TMPL"
}

@test "template + convention files exist" {
  [ -f "$CONTEXT_TMPL" ]
  [ -f "$WORKSPACE_CONTEXT_TMPL" ]
  [ -f "$MEMORY_INDEX" ]
  [ -f "$MERGE_MEM" ]
  [ -f "$CONVENTIONS" ]
}

@test "CONTEXT.md Working Rules declares auto-memory as source of truth" {
  section="$(working_rules_section)"
  echo "$section" | grep -qi 'source of truth' \
    || { echo "Working Rules section missing 'source of truth' precedence statement"; return 1; }
  echo "$section" | grep -q 'feedback_' \
    || { echo "Working Rules section does not point at feedback_* memory"; return 1; }
}

@test "CONTEXT.md Working Rules points at merge-strategy memory, does not restate it" {
  section="$(working_rules_section)"
  # Must reference the memory file by name (pointer form).
  echo "$section" | grep -q 'feedback_merge_strategy' \
    || { echo "Working Rules section missing feedback_merge_strategy pointer"; return 1; }
  # Must NOT restate the actual merge-policy verbs that belong in the memory.
  if echo "$section" | grep -qiE 'squash|rebase-merge|create a merge commit'; then
    echo "Working Rules section restates merge-policy text instead of pointing at memory"
    return 1
  fi
}

@test "merge-strategy memory no longer tells users to copy overrides into CONTEXT.md" {
  # The old anti-pattern: "override this rule but note it in CONTEXT.md".
  if grep -qiE 'note it in .?CONTEXT' "$MERGE_MEM"; then
    echo "feedback_merge_strategy.md still instructs copying overrides into CONTEXT.md"
    return 1
  fi
}

@test "CONVENTIONS.md Auto-memory section declares single-source + frontmatter-flip rules" {
  # Source-of-truth precedence.
  grep -qi 'source of truth for mutable conventions' "$CONVENTIONS" \
    || { echo "CONVENTIONS.md missing source-of-truth precedence rule"; return 1; }
  # Frontmatter description must flip with the body.
  grep -qi 'description:' "$CONVENTIONS" \
    || { echo "CONVENTIONS.md missing frontmatter description-flip guidance"; return 1; }
}

@test "MEMORY.md template header carries the single-source + description-flip hygiene note" {
  grep -qi 'source of truth for mutable conventions' "$MEMORY_INDEX" \
    || { echo "MEMORY.md header missing source-of-truth note"; return 1; }
  grep -qi 'description:' "$MEMORY_INDEX" \
    || { echo "MEMORY.md header missing description-flip hygiene note"; return 1; }
}

@test "workspace-CONTEXT.md warns against restating conventions in cross-repo notes" {
  grep -qiE "don't restate|do not restate" "$WORKSPACE_CONTEXT_TMPL" \
    || { echo "workspace-CONTEXT.md missing 'don't restate conventions' guard"; return 1; }
}
