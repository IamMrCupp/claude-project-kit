#!/usr/bin/env bats
# Regression check — every kit-coupled slash command and the session-summarizer
# agent must include a "Precheck — is this a kit project?" block instructing
# Claude to bail with a friendly message when invoked outside a kit working
# folder. Closes #82's "graceful degradation" requirement.

load 'helpers'

# Slash commands that read/write kit files (everything except code-reviewer
# is kit-coupled).
KIT_COUPLED_COMMANDS=(
  templates/.claude/commands/session-start.md
  templates/.claude/commands/session-end.md
  templates/.claude/commands/session-handoff.md
  templates/.claude/commands/refresh-context.md
  templates/.claude/commands/close-phase.md
  templates/.claude/commands/pull-ticket.md
  templates/.claude/commands/run-acceptance.md
)

# Kit-coupled agents (code-reviewer is universal — no kit dependency).
KIT_COUPLED_AGENTS=(
  templates/.claude/agents/session-summarizer.md
)

@test "every kit-coupled slash command includes a Precheck block" {
  for cmd in "${KIT_COUPLED_COMMANDS[@]}"; do
    f="$KIT_ROOT/$cmd"
    [ -f "$f" ]
    if ! grep -q "^## Precheck — is this a kit project?$" "$f"; then
      echo "missing Precheck block: $cmd"
      return 1
    fi
  done
}

@test "every kit-coupled command Precheck mentions reference_ai_working_folder.md" {
  for cmd in "${KIT_COUPLED_COMMANDS[@]}"; do
    f="$KIT_ROOT/$cmd"
    if ! grep -q 'reference_ai_working_folder\.md' "$f"; then
      echo "missing reference_ai_working_folder.md probe in: $cmd"
      return 1
    fi
  done
}

@test "every kit-coupled command Precheck has a friendly bail message" {
  for cmd in "${KIT_COUPLED_COMMANDS[@]}"; do
    f="$KIT_ROOT/$cmd"
    if ! grep -q 'No kit working folder found for this project' "$f"; then
      echo "missing bail message in: $cmd"
      return 1
    fi
  done
}

@test "kit-coupled agents include a Precheck block" {
  for agent in "${KIT_COUPLED_AGENTS[@]}"; do
    f="$KIT_ROOT/$agent"
    [ -f "$f" ]
    if ! grep -q "^## Precheck — is this a kit project?$" "$f"; then
      echo "missing Precheck block: $agent"
      return 1
    fi
  done
}

@test "code-reviewer agent does NOT include the kit Precheck (universal agent)" {
  f="$KIT_ROOT/templates/.claude/agents/code-reviewer.md"
  [ -f "$f" ]
  ! grep -q "Precheck — is this a kit project" "$f"
}
