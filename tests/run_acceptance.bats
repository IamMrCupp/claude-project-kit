#!/usr/bin/env bats
# Regression check — the kit's "AT execution + writeback" surface
# (#154) lives in three places that must stay in sync:
#
#   1. CONVENTIONS.md carries the heuristic ("Automating acceptance tests
#      where it makes sense") + the PR-body writeback how-to.
#   2. templates/.claude/commands/run-acceptance.md exists with the right
#      shape (classify → run → propose writebacks to BOTH surfaces).
#   3. templates/.claude/commands/close-phase.md offers /run-acceptance
#      when ATs are pending.
#
# Substring checks rather than exact-wording matches — keeps the test
# honest without coupling to editorial polish.

load 'helpers'

CONVENTIONS="$KIT_ROOT/CONVENTIONS.md"
PROMPTS="$KIT_ROOT/PROMPTS.md"
RUN_ACCEPTANCE="$KIT_ROOT/templates/.claude/commands/run-acceptance.md"
CLOSE_PHASE="$KIT_ROOT/templates/.claude/commands/close-phase.md"
CLAUDE_README="$KIT_ROOT/templates/.claude/README.md"

@test "CONVENTIONS.md declares the AT-automation heuristic" {
  [ -f "$CONVENTIONS" ]
  grep -q "^### Automating acceptance tests where it makes sense$" "$CONVENTIONS"
  grep -q "Run automatically" "$CONVENTIONS"
  grep -q "Run with confirmation" "$CONVENTIONS"
  grep -q "Defer to human" "$CONVENTIONS"
}

@test "CONVENTIONS.md documents the PR-body writeback flow" {
  grep -q "^### How to post test results back to the PR$" "$CONVENTIONS"
  grep -q "gh pr edit" "$CONVENTIONS"
  grep -q "body-file" "$CONVENTIONS"
}

@test "CONVENTIONS.md makes writeback the default, not opt-in" {
  grep -q "Posting back is the \*\*default\*\*\|Posting back is the default" "$CONVENTIONS"
}

@test "/run-acceptance command file exists" {
  [ -f "$RUN_ACCEPTANCE" ]
}

@test "/run-acceptance describes the classify → run → writeback flow" {
  grep -q "Run automatically" "$RUN_ACCEPTANCE"
  grep -q "Run with confirmation" "$RUN_ACCEPTANCE"
  grep -q "Defer to human" "$RUN_ACCEPTANCE"
}

@test "/run-acceptance proposes writebacks to BOTH acceptance-test-results.md and PR body" {
  grep -q "acceptance-test-results\.md" "$RUN_ACCEPTANCE"
  grep -q "gh pr edit" "$RUN_ACCEPTANCE"
}

@test "/run-acceptance includes failure-reporting discipline" {
  grep -qE "exact command.*exact output|silently retry|candidate fix" "$RUN_ACCEPTANCE"
}

@test "/close-phase offers /run-acceptance when ATs are pending" {
  grep -q "/run-acceptance" "$CLOSE_PHASE"
  grep -q "still pending\|pending\b" "$CLOSE_PHASE"
}

@test "/close-phase enforcement refusal mentions /run-acceptance as a path" {
  grep -q "Run \`/run-acceptance\`\|run \`/run-acceptance\`\|/run-acceptance" "$CLOSE_PHASE"
}

@test "templates/.claude/README.md lists /run-acceptance" {
  [ -f "$CLAUDE_README" ]
  grep -q "/run-acceptance" "$CLAUDE_README"
  grep -q "seven slash commands" "$CLAUDE_README"
}

@test "PROMPTS.md adds Prompt 8 mirroring /run-acceptance" {
  [ -f "$PROMPTS" ]
  grep -q "^## 8\. Running acceptance tests with writeback$" "$PROMPTS"
  grep -q "/run-acceptance" "$PROMPTS"
}
