#!/usr/bin/env bats
# Regression guard for #276 — the `feedback_chips_use_the_kit.md` starter.
#
# A task chip spawned with `spawn_task` starts a cold session that knows only
# what the chip prompt says. The starter tells Claude to open every chip prompt
# in a kit project with the kit itself: /session-start, the auto-memory rules
# the task will hit, issue-first when the tracker is user-owned, /session-end —
# and to say nothing about the kit when it isn't present.
#
# Also guards the template set as a whole: every shipped memory template must
# have an index line in memory-templates/MEMORY.md, because auto-memory loads
# only the index — an unindexed template is invisible to a fresh session.

load 'helpers'

TEMPLATES="$KIT_ROOT/memory-templates"
CHIPS="$TEMPLATES/feedback_chips_use_the_kit.md"
MEMORY_INDEX="$TEMPLATES/MEMORY.md"

# Only the bootstrap test builds a sandbox; the rest are static reads.
teardown() { [ -z "${TEST_TMP:-}" ] || bootstrap_teardown; }

@test "feedback_chips_use_the_kit.md exists with feedback frontmatter" {
  [ -f "$CHIPS" ]
  [ "$(head -1 "$CHIPS")" = "---" ]
  grep -q '^name: ' "$CHIPS"
  grep -q '^description: .*spawn_task' "$CHIPS"
  grep -q '^type: feedback$' "$CHIPS"
}

@test "chip rule opens with /session-start" {
  grep -q '1\. \*\*Invoke `/session-start`' "$CHIPS"
}

@test "chip rule says to name the auto-memory rules the task will hit" {
  grep -q '2\. \*\*Follow this project.s auto-memory rules — and name the ones the task will hit' "$CHIPS"
}

@test "chip rule is issue-first for user-owned trackers and links the tracker-authority starter" {
  grep -q '3\. \*\*Issue-first when the tracker is user-owned\*\* (\[\[feedback_no_tracker_creation\]\])' "$CHIPS"
}

@test "chip rule finishes with /session-end" {
  grep -q '4\. \*\*Finish with `/session-end`' "$CHIPS"
}

@test "chip rule says nothing about the kit when the kit is absent" {
  grep -q '\*\*Kit absent\*\* → say nothing about it' "$CHIPS"
}

@test "chip rule carries no project-specific leftovers from its source" {
  run grep -niE 'openscad|3d-printer|ubuntu' "$CHIPS"
  [ "$status" -ne 0 ]
}

@test "every [[link]] in the chip rule resolves to a shipped memory template" {
  links="$(grep -oE '\[\[[a-z_]+\]\]' "$CHIPS" | tr -d '[]' | sort -u)"
  [ -n "$links" ]
  for name in $links; do
    [ -f "$TEMPLATES/$name.md" ] || { echo "dangling link: [[$name]]"; return 1; }
  done
}

@test "MEMORY.md index carries a line for the chip rule" {
  grep -qF '(feedback_chips_use_the_kit.md)' "$MEMORY_INDEX"
}

@test "every shipped memory template has an index line in MEMORY.md" {
  for f in "$TEMPLATES"/*.md; do
    name="$(basename "$f")"
    [ "$name" = "MEMORY.md" ] && continue
    grep -qF "($name)" "$MEMORY_INDEX" || { echo "unindexed template: $name"; return 1; }
  done
}

@test "widget-tracker memory example lists the chip rule among shipped starters" {
  grep -qF '`feedback_chips_use_the_kit.md`' "$KIT_ROOT/examples/widget-tracker/memory-example/MEMORY.md"
}

@test "bootstrap copies the chip rule into auto-memory" {
  bootstrap_setup
  run "$BOOTSTRAP" "$TEST_WF"
  [ "$status" -eq 0 ]
  [ -f "$(memory_dir)/feedback_chips_use_the_kit.md" ]
}
