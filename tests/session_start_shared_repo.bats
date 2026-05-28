#!/usr/bin/env bats
# /session-start surfacing of the shared-repo "## Referenced by" section (#199 PR C).
#
# The slash command itself is markdown instructions — these tests assert the
# instructions are present in both the dogfood and shipped copies, and ride on
# the existing dogfood_claude_in_sync test for byte-identical parity.

load 'helpers'

DOGFOOD_CMD="$KIT_ROOT/.claude/commands/session-start.md"
SHIPPED_CMD="$KIT_ROOT/templates/.claude/commands/session-start.md"
ADR="$KIT_ROOT/docs/adr/0003-shared-repos-across-workspaces.md"

@test "both /session-start copies exist" {
  [ -f "$DOGFOOD_CMD" ]
  [ -f "$SHIPPED_CMD" ]
}

@test "/session-start instructs Claude to detect a 'Referenced by' section" {
  grep -q "## Referenced by" "$SHIPPED_CMD"
  grep -q "Shared-repo surfacing" "$SHIPPED_CMD"
}

@test "/session-start surfacing tells Claude to skip silently when section is absent" {
  # Non-shared repos should not see any extra output. Critical: otherwise the
  # hand-back gets noisy for every project.
  grep -q "skip silently" "$SHIPPED_CMD"
  grep -q "non-shared repos shouldn't see this line" "$SHIPPED_CMD"
}

@test "/session-start surfacing format shows the 'referenced by' workspace list" {
  grep -q "Shared repo — referenced by:" "$SHIPPED_CMD"
}

@test "/session-start surfacing points at SETUP and ADR-0003 for context" {
  grep -q "Shared repos across workspaces" "$SHIPPED_CMD"
  grep -q "ADR-0003" "$SHIPPED_CMD"
}

@test "ADR-0003 exists and is Accepted" {
  [ -f "$ADR" ]
  grep -q "^# ADR 0003" "$ADR"
  grep -q "Status:\*\* Accepted" "$ADR"
}

@test "ADR-0003 rejects true multi-home, symlinks, and primary-workspace alternatives" {
  # The three explicit rejections from the design — pin them so a future refactor
  # can't accidentally drop the rationale.
  grep -q "True multi-home" "$ADR"
  grep -q "Symlinks under each workspace" "$ADR"
  grep -q "Primary workspace + cross-workspace" "$ADR"
}

@test "ADR-0003 documents the read-only-on-shared-side decision" {
  grep -q "Read-only on the shared side" "$ADR"
}

@test "ADR index lists ADR-0003" {
  grep -q "0003-shared-repos-across-workspaces.md" "$KIT_ROOT/docs/adr/README.md"
}
