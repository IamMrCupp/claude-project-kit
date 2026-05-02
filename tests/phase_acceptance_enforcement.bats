#!/usr/bin/env bats
# Regression check — the kit's "Acceptance tests at phase boundaries"
# convention must be reflected in three places:
#
#   1. CONVENTIONS.md carries the rule.
#   2. templates/phase-N-checklist.md retains the `## Acceptance testing`
#      section and the matching exit-criterion line.
#   3. templates/.claude/commands/close-phase.md carries the enforcement
#      block that refuses to close without results or an explicit skip.
#
# Closes the D.1 + D.2 acceptance criteria of #153. Substring checks rather
# than exact-wording matches — keeps the test honest without coupling to
# editorial polish.

load 'helpers'

CONVENTIONS="$KIT_ROOT/CONVENTIONS.md"
PHASE_TEMPLATE="$KIT_ROOT/templates/phase-N-checklist.md"
RESULTS_TEMPLATE="$KIT_ROOT/templates/acceptance-test-results.md"
CLOSE_PHASE="$KIT_ROOT/templates/.claude/commands/close-phase.md"

@test "CONVENTIONS.md declares the acceptance-tests-at-phase-boundaries rule" {
  [ -f "$CONVENTIONS" ]
  grep -q "^## Acceptance tests at phase boundaries$" "$CONVENTIONS"
  grep -q "non-empty .acceptance-test-results" "$CONVENTIONS"
  grep -q "Acceptance tests intentionally skipped" "$CONVENTIONS"
}

@test "templates/phase-N-checklist.md retains the Acceptance testing section" {
  [ -f "$PHASE_TEMPLATE" ]
  grep -q "^## Acceptance testing$" "$PHASE_TEMPLATE"
}

@test "templates/phase-N-checklist.md retains the Acceptance tests pass exit criterion" {
  grep -q "Acceptance tests pass" "$PHASE_TEMPLATE"
}

@test "templates/phase-N-checklist.md documents the explicit-skip escape hatch" {
  grep -q "Acceptance tests intentionally skipped" "$PHASE_TEMPLATE"
}

@test "templates/acceptance-test-results.md references the convention" {
  [ -f "$RESULTS_TEMPLATE" ]
  grep -q "Acceptance tests at phase boundaries" "$RESULTS_TEMPLATE"
}

@test "/close-phase carries an Enforcement section" {
  [ -f "$CLOSE_PHASE" ]
  grep -q "^## Enforcement — acceptance tests must exist$" "$CLOSE_PHASE"
}

@test "/close-phase enforcement refuses on missing Acceptance testing section" {
  grep -q "missing the .## Acceptance testing. section" "$CLOSE_PHASE"
}

@test "/close-phase enforcement refuses on missing results + missing skip line" {
  grep -q "no acceptance test results found and no explicit skip-rationale" "$CLOSE_PHASE"
}

@test "/close-phase surfaces the skip rationale in the SESSION-LOG entry" {
  grep -q "skip-rationale line is present" "$CLOSE_PHASE"
  grep -q "surface it in the SESSION-LOG entry\|surface the rationale\|surface .*rationale" "$CLOSE_PHASE"
}
