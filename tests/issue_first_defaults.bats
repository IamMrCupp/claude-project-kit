#!/usr/bin/env bats
# Issue-first defaults when the user owns the tracker (#181).
#
# Static checks that the kit's shipped templates / conventions / memory
# templates carry the issue-first language consistently. Doesn't require
# bootstrap.sh to run — these are content checks against the kit itself.

load 'helpers'

KIT_ROOT="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"

@test "CONVENTIONS.md has Issue-first sub-section under Ticket-driven workflows" {
  grep -q '^### Issue-first when you own the tracker$' "$KIT_ROOT/CONVENTIONS.md"
}

@test "CONVENTIONS.md Issue-first section names the tracker-authority bright line" {
  # Section asserts the bright line; the verbatim phrasing is load-bearing
  # because feedback_no_tracker_creation.md and the tracker memory variants
  # cross-reference it.
  grep -q 'Bright line: tracker authority decides the default' "$KIT_ROOT/CONVENTIONS.md"
}

@test "CONVENTIONS.md Issue-first section requires confirm-before-bulk-create" {
  grep -q -i 'Confirm before bulk-create' "$KIT_ROOT/CONVENTIONS.md"
}

@test "templates/phase-N-checklist.md includes an Issue: field per item" {
  grep -q '^- \*\*Issue:\*\*' "$KIT_ROOT/templates/phase-N-checklist.md"
}

@test "templates/phase-N-checklist.md How-to block mentions issue-first when user owns the tracker" {
  grep -q -i 'Issue-first when you own the tracker' "$KIT_ROOT/templates/phase-N-checklist.md"
}

@test "templates/CONTEXT.md Tracker Configuration carries Tracker authority field" {
  grep -q '^- \*\*Tracker authority:\*\*' "$KIT_ROOT/templates/CONTEXT.md"
}

@test "templates/workspace/workspace-CONTEXT.md Tracker Configuration carries Tracker authority field" {
  grep -q '^- \*\*Tracker authority:\*\*' "$KIT_ROOT/templates/workspace/workspace-CONTEXT.md"
}

@test "memory-templates/feedback_no_tracker_creation.md keeps the read-only rule for externally-owned trackers" {
  grep -q -i 'Externally-owned trackers' "$KIT_ROOT/memory-templates/feedback_no_tracker_creation.md"
  grep -q -i 'Read/reference only' "$KIT_ROOT/memory-templates/feedback_no_tracker_creation.md"
}

@test "memory-templates/feedback_no_tracker_creation.md states issue-first default for personally-owned trackers" {
  grep -q -i 'Personally-owned trackers' "$KIT_ROOT/memory-templates/feedback_no_tracker_creation.md"
  grep -q -i 'Issue-first by default' "$KIT_ROOT/memory-templates/feedback_no_tracker_creation.md"
}

@test "memory-templates/feedback_no_tracker_creation.md still forbids project-level structural artifacts" {
  # Project / label / workflow creation stays off-limits regardless of authority —
  # the new convention is about *issues*, not *projects*.
  grep -q 'gh project create' "$KIT_ROOT/memory-templates/feedback_no_tracker_creation.md"
}

@test "memory-templates/MEMORY.md index line for tracker memory mentions issue-first" {
  grep -q 'feedback_no_tracker_creation.md' "$KIT_ROOT/memory-templates/MEMORY.md"
  grep -q -i 'issue-first' "$KIT_ROOT/memory-templates/MEMORY.md"
}

@test "memory-templates/trackers/github.md carries issue-first instruction for user-owned repos" {
  grep -q -i 'Issue-first when this is the user' "$KIT_ROOT/memory-templates/trackers/github.md"
  grep -q 'gh issue create' "$KIT_ROOT/memory-templates/trackers/github.md"
}

@test "memory-templates/trackers/gitlab.md carries issue-first instruction for user-owned projects" {
  grep -q -i 'Issue-first when this is the user' "$KIT_ROOT/memory-templates/trackers/gitlab.md"
  grep -q 'glab issue create' "$KIT_ROOT/memory-templates/trackers/gitlab.md"
}

@test "memory-templates/trackers/jira.md does NOT carry issue-first instruction" {
  # JIRA is overwhelmingly externally-owned (work projects). Keeping it free of
  # issue-first language is intentional — the rule only applies when the user
  # owns the tracker, and that is rare on JIRA. Same logic applies to linear.md
  # and shortcut.md (also typically team/business-owned).
  ! grep -q -i 'Issue-first when this is the user' "$KIT_ROOT/memory-templates/trackers/jira.md"
}

@test "PROMPTS.md has Prompt 12 for carving a phase checklist into issues" {
  grep -q '^## 12\. Carving a phase checklist into issues' "$KIT_ROOT/PROMPTS.md"
}

@test "PROMPTS.md Prompt 12 references CONVENTIONS.md issue-first rule" {
  # The prompt should anchor to the convention, not invent its own rule.
  awk '/^## 12\. Carving a phase checklist into issues/,/^## 13\.|^## When to write a new prompt/' \
    "$KIT_ROOT/PROMPTS.md" | grep -q -i 'Issue-first when you own the tracker'
}

@test "FEATURES.md Issue tracker awareness section mentions issue-first defaults" {
  grep -q -i 'Issue-first defaults when you own the tracker' "$KIT_ROOT/FEATURES.md"
}

@test "SETUP.md normal-flow section calls out the carve-issues step" {
  grep -q -i 'Carve issues' "$KIT_ROOT/SETUP.md"
}
