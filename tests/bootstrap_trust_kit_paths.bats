#!/usr/bin/env bats
# --trust-kit-paths flag (and its deprecated --trust-working-folder-root alias)
# — opt-in writes to ~/.claude/settings.json that silence per-session
# permission prompts. Combined behavior:
#   1. Append the working folder's parent to permissions.additionalDirectories
#      (so Claude Code stops prompting on every read of CONTEXT.md /
#      SESSION-LOG.md / phase checklists).
#   2. Append Bash(<absolute path to kit-print-memory-pointer.sh>) to
#      permissions.allow (so the slash-command precheck stops prompting on
#      every fresh session — closes #218; absolute path required because of
#      anthropics/claude-code #16800).
#
# Both writes are idempotent, backed up before write, honor --dry-run.

load 'helpers'

setup() { bootstrap_setup; }
teardown() { bootstrap_teardown; }

# Echo the trusted-root path bootstrap would compute for $TEST_WF (the parent
# directory of the working folder, in single-repo mode).
trusted_root() {
  dirname "$TEST_WF"
}

# Echo the absolute path of the precheck helper script that --trust-kit-paths
# would append to permissions.allow. Mirrors precheck_script_absolute_path()
# in bootstrap.sh.
precheck_script_path() {
  echo "$TEST_HOME/.claude/scripts/kit-print-memory-pointer.sh"
}

# Echo the literal Bash(...) allowlist entry that --trust-kit-paths writes.
precheck_allow_entry() {
  echo "Bash($(precheck_script_path))"
}

@test "--trust-kit-paths creates settings.json if absent with both entries" {
  [ ! -f "$TEST_HOME/.claude/settings.json" ]
  run "$BOOTSTRAP" "$TEST_WF" --skip-memory --skip-scripts --trust-kit-paths
  [ "$status" -eq 0 ]

  [ -f "$TEST_HOME/.claude/settings.json" ]
  python3 -c "
import json, sys
d = json.load(open(sys.argv[1]))
ROOT = sys.argv[2]
ENTRY = sys.argv[3]
assert ROOT in d['permissions']['additionalDirectories'], d
assert ENTRY in d['permissions']['allow'], d
" "$TEST_HOME/.claude/settings.json" "$(trusted_root)" "$(precheck_allow_entry)"
}

@test "--trust-kit-paths appends to existing settings.json without clobbering" {
  mkdir -p "$TEST_HOME/.claude"
  cat > "$TEST_HOME/.claude/settings.json" <<EOF
{
  "permissions": {
    "additionalDirectories": ["/some/existing/path"],
    "allow": ["Bash(gh run *)"]
  },
  "theme": "dark"
}
EOF

  run "$BOOTSTRAP" "$TEST_WF" --skip-memory --skip-scripts --trust-kit-paths
  [ "$status" -eq 0 ]

  # Existing entries preserved; both new entries appended.
  python3 -c "
import json, sys
d = json.load(open(sys.argv[1]))
ROOT = sys.argv[2]
ENTRY = sys.argv[3]
assert '/some/existing/path' in d['permissions']['additionalDirectories'], d
assert ROOT in d['permissions']['additionalDirectories'], d
assert 'Bash(gh run *)' in d['permissions']['allow'], d
assert ENTRY in d['permissions']['allow'], d
assert d['theme'] == 'dark', d
" "$TEST_HOME/.claude/settings.json" "$(trusted_root)" "$(precheck_allow_entry)"
}

@test "--trust-kit-paths is idempotent across re-runs" {
  run "$BOOTSTRAP" "$TEST_WF" --skip-memory --skip-scripts --trust-kit-paths
  [ "$status" -eq 0 ]

  HASH1="$(md5 -q "$TEST_HOME/.claude/settings.json" 2>/dev/null || md5sum "$TEST_HOME/.claude/settings.json" | awk '{print $1}')"

  # Second working folder under the SAME parent — same trusted root, same
  # script path. Both entries should be detected as already-present.
  TEST_WF2="$(dirname "$TEST_WF")/wf2"
  run "$BOOTSTRAP" "$TEST_WF2" --skip-memory --skip-scripts --trust-kit-paths
  [ "$status" -eq 0 ]

  HASH2="$(md5 -q "$TEST_HOME/.claude/settings.json" 2>/dev/null || md5sum "$TEST_HOME/.claude/settings.json" | awk '{print $1}')"
  [ "$HASH1" = "$HASH2" ]

  # Both already-present signals should appear in the output.
  [[ "$output" == *"already in permissions.additionalDirectories"* ]]
  [[ "$output" == *"already in permissions.allow"* ]]
}

@test "--trust-kit-paths backs up before overwriting" {
  mkdir -p "$TEST_HOME/.claude"
  cat > "$TEST_HOME/.claude/settings.json" <<'EOF'
{ "permissions": { "additionalDirectories": ["/x"] } }
EOF

  run "$BOOTSTRAP" "$TEST_WF" --skip-memory --skip-scripts --trust-kit-paths
  [ "$status" -eq 0 ]

  # At least one backup file exists.
  ls "$TEST_HOME/.claude/settings.json.bak."* >/dev/null
  # Backup contents match the original (no new entries).
  BACKUP="$(ls "$TEST_HOME/.claude/settings.json.bak."* | head -1)"
  grep -q '"/x"' "$BACKUP"
  ! grep -q "$(trusted_root)" "$BACKUP"
  ! grep -q "kit-print-memory-pointer.sh" "$BACKUP"
}

@test "--trust-kit-paths + --dry-run writes nothing" {
  run "$BOOTSTRAP" --dry-run "$TEST_WF" --skip-memory --skip-scripts --trust-kit-paths
  [ "$status" -eq 0 ]

  [ ! -f "$TEST_HOME/.claude/settings.json" ]
  # Preview must mention both entries that would be written.
  [[ "$output" == *"permissions.additionalDirectories"* ]]
  [[ "$output" == *"permissions.allow"* ]]
  [[ "$output" == *"kit-print-memory-pointer.sh"* ]]
}

@test "without --trust-kit-paths, settings.json is not touched" {
  run "$BOOTSTRAP" "$TEST_WF" --skip-memory --skip-scripts
  [ "$status" -eq 0 ]

  [ ! -f "$TEST_HOME/.claude/settings.json" ]
}

@test "--trust-kit-paths with workspace mode uses workspace parent dir" {
  WS="$TEST_TMP/acme-platform"
  run "$BOOTSTRAP" --workspace "$WS" --skip-memory --skip-scripts --trust-kit-paths
  [ "$status" -eq 0 ]

  EXPECTED_ROOT="$(dirname "$WS")"
  python3 -c "
import json, sys
d = json.load(open(sys.argv[1]))
ROOT = sys.argv[2]
ENTRY = sys.argv[3]
assert ROOT in d['permissions']['additionalDirectories'], d
assert ENTRY in d['permissions']['allow'], d
" "$TEST_HOME/.claude/settings.json" "$EXPECTED_ROOT" "$(precheck_allow_entry)"
}

@test "--trust-kit-paths errors gracefully when settings.json is malformed" {
  mkdir -p "$TEST_HOME/.claude"
  echo "this is not json" > "$TEST_HOME/.claude/settings.json"

  run "$BOOTSTRAP" "$TEST_WF" --skip-memory --skip-scripts --trust-kit-paths
  # Bootstrap itself still succeeds (trust step is best-effort); the
  # bad-JSON error must be surfaced.
  [[ "$output" == *"could not parse"* ]] || [[ "$output" == *"settings.json inspection failed"* ]]
}

@test "--trust-kit-paths flag appears in --help with both entry types described" {
  run "$BOOTSTRAP" --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"--trust-kit-paths"* ]]
  [[ "$output" == *"additionalDirectories"* ]]
  [[ "$output" == *"permissions.allow"* ]]
}

# ─── Deprecation alias: --trust-working-folder-root ──────────────────────

@test "--trust-working-folder-root alias still works and produces both entries" {
  run "$BOOTSTRAP" "$TEST_WF" --skip-memory --skip-scripts --trust-working-folder-root
  [ "$status" -eq 0 ]

  # Deprecation warning must be surfaced so scripted users know to switch.
  [[ "$output" == *"deprecated"* ]]
  [[ "$output" == *"--trust-kit-paths"* ]]

  # And the alias must produce the SAME combined output as the canonical flag.
  python3 -c "
import json, sys
d = json.load(open(sys.argv[1]))
ROOT = sys.argv[2]
ENTRY = sys.argv[3]
assert ROOT in d['permissions']['additionalDirectories'], d
assert ENTRY in d['permissions']['allow'], d
" "$TEST_HOME/.claude/settings.json" "$(trusted_root)" "$(precheck_allow_entry)"
}

@test "--trust-working-folder-root is documented as deprecated in --help" {
  run "$BOOTSTRAP" --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"--trust-working-folder-root"* ]]
  # Help text must explicitly call out that it's deprecated.
  [[ "$output" == *"Deprecated"* ]]
}
