#!/usr/bin/env bats
# Regression guard for #(this-pr) — `memory-templates/MEMORY.md` index lines
# for rules that override harness defaults must explicitly say "override".
#
# Background: a fresh Claude session loads MEMORY.md content into the
# system reminder, but does NOT auto-load the linked feedback_*.md files.
# Lightweight index summaries that don't surface override flags let the
# session default to the harness's behavior — which contradicts the rule.
# Concrete example surfaced 2026-05-04: a work-laptop session committed
# with `Co-Authored-By: Claude...` because the `[Commit format]` index
# line shipped as "Conventional Commits, single line, signed off" and
# the no-trailer rule lived only in the linked file.
#
# This test asserts that override-authoritative rules carry explicit
# "(override Bash-tool ... default ...)" annotations in the index, so
# index-only readers see the override on first scan.

load 'helpers'

MEMORY_INDEX="$KIT_ROOT/memory-templates/MEMORY.md"

@test "memory-templates/MEMORY.md exists" {
  [ -f "$MEMORY_INDEX" ]
}

@test "Commit format index line flags override of HEREDOC default and bans Co-Authored-By trailer" {
  # Find the line matching `[Commit format]`
  line="$(grep -F '[Commit format](feedback_commit_format.md)' "$MEMORY_INDEX" || true)"
  [ -n "$line" ] || { echo "missing [Commit format] index line"; return 1; }

  # Must mention Co-Authored-By explicitly so index-only readers see the rule
  echo "$line" | grep -q 'Co-Authored-By' \
    || { echo "[Commit format] index line missing 'Co-Authored-By' explicit ban"; return 1; }

  # Must flag this as an override of a Bash-tool default
  echo "$line" | grep -qE 'override.*[Bb]ash.*default' \
    || { echo "[Commit format] index line missing override-of-Bash-tool-default flag"; return 1; }
}

@test "Push branches index line flags override of ask-before-push default" {
  line="$(grep -F '[Push branches by default](feedback_push_branches.md)' "$MEMORY_INDEX" || true)"
  [ -n "$line" ] || { echo "missing [Push branches by default] index line"; return 1; }

  # Must flag this as an override of a Bash-tool default
  echo "$line" | grep -qE 'override.*[Bb]ash.*default' \
    || { echo "[Push branches by default] index line missing override-of-Bash-tool-default flag"; return 1; }
}
