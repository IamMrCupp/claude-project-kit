#!/usr/bin/env bats
# scripts/kit-session-start.sh — SessionStart hook that auto-grounds a
# kit-bootstrapped repo (closes #266).
#
# Hard constraints under test:
#   - DEFAULT output is a capped grounding floor (<=25 lines) and NEVER inlines
#     CONTEXT.md.
#   - Non-kit repos and `resume` sessions cost nothing — zero output, exit 0.
#   - Lint verdicts surface correctly (clear vs. a deliberately stale fixture).
#   - KIT_SESSION_FULL=1 opts in to the full /session-start-equivalent load.

load 'helpers'

HOOK="$KIT_ROOT/scripts/kit-session-start.sh"

# Run the hook with the given stdin (so we can exercise the resume skip) and
# a neutral env. cwd is TEST_REPO (set in setup).
run_hook() {
  local stdin_data="${1:-}"
  run bash -c "printf '%s' '$stdin_data' | '$HOOK'"
}

# Self-contained fixture. Canonicalize the tmp root with `pwd -P` so that
# git's absolute-path resolution (/private/var on macOS) matches the raw $PWD
# the drift lint infers from — otherwise the kit's two resolvers disagree under
# a symlinked /tmp and the fixture lands where the hook can't see it.
setup() {
  TEST_TMP="$(cd "$(mktemp -d)" && pwd -P)"
  TEST_HOME="$TEST_TMP/home"
  TEST_REPO="$TEST_TMP/repo"
  WF="$TEST_TMP/wf"
  mkdir -p "$TEST_HOME" "$TEST_REPO" "$WF"
  export HOME="$TEST_HOME"
  git -C "$TEST_REPO" init -q
  cd "$TEST_REPO"

  # Place the auto-memory pointer where the kit's OWN resolver says it lives,
  # so the hook (which calls the same resolver) always finds it.
  POINTER="$("$KIT_ROOT/scripts/kit-print-memory-pointer.sh")"
  MEM="$(dirname "$POINTER")"
  mkdir -p "$MEM"

  # Pointer -> the working folder's CONTEXT.md (backtick-quoted absolute path,
  # exactly how the kit writes it).
  cat > "$POINTER" <<EOF
---
name: AI working folder for testproj
type: reference
---
- \`$WF/CONTEXT.md\` — project overview, working rules, current phase status
- \`$WF/SESSION-LOG.md\` — chronological history
EOF

  cat > "$WF/CONTEXT.md" <<EOF
# Claude Working Context — testproj
**Last updated:** 2026-11-05 (Phase 2 in flight)

## Current Phase Status
**Phase 2 — wiring:** in progress; 2 of 5 items done.

## Working Rules
### Git & commits
- Merge strategy → see feedback_merge_strategy
EOF

  cat > "$WF/SESSION-LOG.md" <<EOF
# Session Log — testproj
## Session: 2026-11-04 — first session
**Focus:** set things up.
EOF

  # Neutralize gh by default: a stub that errors => the open-PR line is omitted,
  # keeping these tests offline and deterministic. Individual tests override it.
  STUBBIN="$TEST_TMP/stubbin"
  mkdir -p "$STUBBIN"
  printf '#!/usr/bin/env bash\nexit 1\n' > "$STUBBIN/gh"
  chmod +x "$STUBBIN/gh"
  export PATH="$STUBBIN:$PATH"
}

teardown() { [ -n "${TEST_TMP:-}" ] && rm -rf "$TEST_TMP"; }

@test "emits a grounding floor in a kit-bootstrapped repo" {
  run_hook ""
  [ "$status" -eq 0 ]
  [[ "$output" == *"Kit project grounding"* ]]
  [[ "$output" == *"$WF"* ]]
  [[ "$output" == *"Phase/status:"* ]]
  [[ "$output" == *"Last SESSION-LOG entry: Session: 2026-11-04"* ]]
  [[ "$output" == *"Run /session-start for the full context load"* ]]
}

@test "default floor NEVER inlines CONTEXT.md" {
  run_hook ""
  [ "$status" -eq 0 ]
  # The floor surfaces the "Last updated" line and the phase status line, but
  # must not dump the body of CONTEXT.md (e.g. its "Working Rules" heading).
  [[ "$output" != *"## Working Rules"* ]]
}

@test "default floor is capped at <=25 lines (hard contract, #266)" {
  run_hook ""
  [ "$status" -eq 0 ]
  local lines
  lines="$(printf '%s\n' "$output" | wc -l | tr -d ' ')"
  [ "$lines" -le 25 ]
}

@test "reports a clear lint verdict when conventions agree" {
  run_hook ""
  [ "$status" -eq 0 ]
  [[ "$output" == *"Lints: 1 clear."* ]]
}

@test "surfaces a lint FLAG when a convention drifts (stale fixture)" {
  # Memory (source of truth) says merge-commit; CONTEXT.md restates a stale
  # squash rule — check-convention-drift.sh flags it, so the floor must too.
  cat > "$MEM/feedback_merge_strategy.md" <<'EOF'
---
name: PR merge strategy — always merge commits
description: Always use "Create a merge commit". Never squash or rebase-merge.
type: feedback
---
When merging PRs, always choose "Create a merge commit". Never squash-merge.
EOF
  cat > "$WF/CONTEXT.md" <<EOF
# Claude Working Context — testproj
**Last updated:** 2026-11-05

## Current Phase Status
Phase 2 in progress.

## Working Rules
### Git & commits
- Merge strategy: squash merge into main
EOF
  run_hook ""
  [ "$status" -eq 0 ]
  [[ "$output" == *"Lint FLAG"* ]]
}

@test "surfaces an open-PR line when gh is available" {
  # Override the stub: a gh that prints a summary line (ignoring --jq) proves
  # the hook plumbs gh output into the floor.
  printf '#!/usr/bin/env bash\necho "Open PRs: 3 (1 green/mergeable) (release PR open)"\n' > "$STUBBIN/gh"
  chmod +x "$STUBBIN/gh"
  run_hook ""
  [ "$status" -eq 0 ]
  [[ "$output" == *"Open PRs: 3 (1 green/mergeable) (release PR open)"* ]]
}

@test "stays silent in a non-kit repo (no pointer)" {
  rm -f "$MEM/reference_ai_working_folder.md"
  run_hook ""
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "stays silent when the pointer resolves but CONTEXT.md is missing" {
  rm -f "$WF/CONTEXT.md"
  run_hook ""
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "stays silent on a resume session" {
  run_hook '{"source":"resume","foo":1}'
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "KIT_SESSION_FULL=1 inlines the full CONTEXT.md and SESSION-LOG tail" {
  run bash -c "printf '' | KIT_SESSION_FULL=1 '$HOOK'"
  [ "$status" -eq 0 ]
  [[ "$output" == *"FULL"* ]]
  # Proof the full file is inlined: a heading only present in the body.
  [[ "$output" == *"## Working Rules"* ]]
  [[ "$output" == *"## SESSION-LOG.md"* ]]
}

@test "FULL mode is still silent on resume and in non-kit repos" {
  run bash -c "printf '{\"source\":\"resume\"}' | KIT_SESSION_FULL=1 '$HOOK'"
  [ "$status" -eq 0 ]
  [ -z "$output" ]

  rm -f "$MEM/reference_ai_working_folder.md"
  run bash -c "printf '' | KIT_SESSION_FULL=1 '$HOOK'"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "the hook script is executable" {
  [ -x "$HOOK" ]
}
