#!/usr/bin/env bash
# Sync the kit's own .claude/ slash commands and agents from the canonical
# templates/ source.
#
# The kit dogfoods its own slash commands and agents, so contributors who
# clone the repo can use /session-start, /close-phase, /session-end, etc.
# while working on the kit itself. The canonical copy lives in
# templates/.claude/ (which ships to bootstrapped projects via bootstrap.sh);
# the dogfood copy in .claude/ must stay byte-identical.
#
# Run this after editing anything under templates/.claude/commands/ or
# templates/.claude/agents/. CI verifies the two trees match via
# tests/dogfood_claude_in_sync.bats.

set -euo pipefail

KIT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

sync_dir() {
  local sub="$1"
  local src="$KIT_ROOT/templates/.claude/$sub"
  local dst="$KIT_ROOT/.claude/$sub"

  if [ ! -d "$src" ]; then
    echo "error: source missing: $src" >&2
    exit 1
  fi

  echo "Syncing .claude/$sub/ from templates/.claude/$sub/..."
  rm -rf "$dst"
  mkdir -p "$dst"
  cp -R "$src/." "$dst/"
}

sync_dir commands
sync_dir agents

echo "Done. Review the diff with 'git diff .claude/' and commit if it looks right."
