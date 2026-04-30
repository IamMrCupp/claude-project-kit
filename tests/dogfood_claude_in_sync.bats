#!/usr/bin/env bats
# The kit dogfoods its own slash commands and agents — .claude/commands/ and
# .claude/agents/ at the repo root must stay byte-identical with their
# canonical sources under templates/.claude/. Bootstrap copies templates/ into
# new working folders, so any drift means the kit's own copy diverges from
# what ships to adopters.
#
# Sync via scripts/sync-claude-dogfood.sh after editing templates/.claude/.

load 'helpers'

@test "templates/.claude/commands/ matches .claude/commands/ (kit dogfoods its commands)" {
  run diff -r "$KIT_ROOT/templates/.claude/commands" "$KIT_ROOT/.claude/commands"
  if [ "$status" -ne 0 ]; then
    echo "templates/.claude/commands/ and .claude/commands/ have diverged."
    echo "Run scripts/sync-claude-dogfood.sh to bring them back in sync."
    echo "Diff output:"
    echo "$output"
    return 1
  fi
}

@test "templates/.claude/agents/ matches .claude/agents/ (kit dogfoods its agents)" {
  run diff -r "$KIT_ROOT/templates/.claude/agents" "$KIT_ROOT/.claude/agents"
  if [ "$status" -ne 0 ]; then
    echo "templates/.claude/agents/ and .claude/agents/ have diverged."
    echo "Run scripts/sync-claude-dogfood.sh to bring them back in sync."
    echo "Diff output:"
    echo "$output"
    return 1
  fi
}
