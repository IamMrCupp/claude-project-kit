#!/usr/bin/env bats
# Regression check — auto-memory path sanitization must replace BOTH `/` and
# `.` with `-`. Closes #205. Claude Code's runtime auto-memory normalizes
# both characters; if the kit only replaces `/`, any user with a `.` in their
# `$HOME` (e.g. macOS username `firstname.lastname`) or repo path gets a
# split where bootstrap seeds memory at one directory and Claude Code's
# runtime auto-loads `MEMORY.md` from a different one.

load 'helpers'

# Source the inference helper for behavioral tests.
source "$KIT_ROOT/scripts/lib/infer.sh"

# Files that embed the sanitization sed inline (slash-command prechecks +
# session-summarizer agent + the kit's own dogfooded copies).
KIT_COUPLED_FILES=(
  bootstrap.sh
  scripts/lib/infer.sh
  tests/helpers.bash
  tests/sync_memory.bats
  tests/sync_templates.bats
  templates/.claude/commands/session-start.md
  templates/.claude/commands/session-end.md
  templates/.claude/commands/session-handoff.md
  templates/.claude/commands/session-verify.md
  templates/.claude/commands/refresh-context.md
  templates/.claude/commands/close-phase.md
  templates/.claude/commands/pull-ticket.md
  templates/.claude/commands/run-acceptance.md
  templates/.claude/commands/plan.md
  templates/.claude/commands/research.md
  templates/.claude/agents/session-summarizer.md
  .claude/commands/session-start.md
  .claude/commands/session-end.md
  .claude/commands/session-handoff.md
  .claude/commands/session-verify.md
  .claude/commands/refresh-context.md
  .claude/commands/close-phase.md
  .claude/commands/pull-ticket.md
  .claude/commands/run-acceptance.md
  .claude/commands/plan.md
  .claude/commands/research.md
  .claude/agents/session-summarizer.md
)

@test "sanitize_path_for_memory replaces / with -" {
  run sanitize_path_for_memory "/Users/aaroncupp/Code/myproj"
  [ "$status" -eq 0 ]
  [ "$output" = "-Users-aaroncupp-Code-myproj" ]
}

@test "sanitize_path_for_memory replaces . in dotted username with -" {
  # Real-world trigger: macOS work account with a dotted username.
  run sanitize_path_for_memory "/Users/aaron.cupp/Code/myproj"
  [ "$status" -eq 0 ]
  [ "$output" = "-Users-aaron-cupp-Code-myproj" ]
}

@test "sanitize_path_for_memory replaces . in repo path with -" {
  # Less common but possible: a repo whose path includes a dot
  # (e.g. a worktree under .claude/worktrees/).
  run sanitize_path_for_memory "/Users/foo/Code/myproj/.claude/worktrees/abc"
  [ "$status" -eq 0 ]
  [ "$output" = "-Users-foo-Code-myproj--claude-worktrees-abc" ]
}

@test "infer_memory_dir produces dot-stripped path for dotted home" {
  HOME="/Users/aaron.cupp"
  run infer_memory_dir "/Users/aaron.cupp/Code/myproj"
  [ "$status" -eq 0 ]
  [ "$output" = "/Users/aaron.cupp/.claude/projects/-Users-aaron-cupp-Code-myproj/memory" ]
}

@test "no kit-tracked file uses the old slash-only sanitization" {
  # Old buggy form: sed 's|/|-|g' — must be gone everywhere.
  for f in "${KIT_COUPLED_FILES[@]}"; do
    full="$KIT_ROOT/$f"
    [ -f "$full" ]
    if grep -qF "sed 's|/|-|g'" "$full"; then
      echo "regression — old slash-only sanitization still present in: $f"
      return 1
    fi
  done
}

@test "every sanitization site uses the dot-and-slash form" {
  # New correct form: sed 's|[/.]|-|g' — must be present in every file
  # that embeds the sanitization sed inline.
  for f in "${KIT_COUPLED_FILES[@]}"; do
    full="$KIT_ROOT/$f"
    [ -f "$full" ]
    if ! grep -qF "sed 's|[/.]|-|g'" "$full"; then
      echo "missing dot-and-slash sanitization in: $f"
      return 1
    fi
  done
}
