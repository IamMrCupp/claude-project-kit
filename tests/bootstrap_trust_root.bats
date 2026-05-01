#!/usr/bin/env bats
# --trust-working-folder-root flag: opt-in append to permissions.additionalDirectories
# in ~/.claude/settings.json. Idempotent, never overwrites, backs up before writing.

load 'helpers'

setup() { bootstrap_setup; }
teardown() { bootstrap_teardown; }

# Echo the trusted-root path bootstrap would compute for $TEST_WF (the parent
# directory of the working folder, in single-repo mode).
trusted_root() {
  dirname "$TEST_WF"
}

@test "--trust-working-folder-root creates settings.json if absent" {
  [ ! -f "$TEST_HOME/.claude/settings.json" ]
  run "$BOOTSTRAP" "$TEST_WF" --skip-memory --trust-working-folder-root
  [ "$status" -eq 0 ]

  [ -f "$TEST_HOME/.claude/settings.json" ]
  python3 -c "import json,sys; d=json.load(open(sys.argv[1])); ROOT=sys.argv[2]; assert ROOT in d['permissions']['additionalDirectories'], d" \
    "$TEST_HOME/.claude/settings.json" "$(trusted_root)"
}

@test "--trust-working-folder-root appends to existing settings.json" {
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

  run "$BOOTSTRAP" "$TEST_WF" --skip-memory --trust-working-folder-root
  [ "$status" -eq 0 ]

  # Existing entries preserved, new entry appended
  python3 -c "
import json, sys
d = json.load(open(sys.argv[1]))
ROOT = sys.argv[2]
assert '/some/existing/path' in d['permissions']['additionalDirectories'], d
assert ROOT in d['permissions']['additionalDirectories'], d
assert d['permissions']['allow'] == ['Bash(gh run *)'], d
assert d['theme'] == 'dark', d
" "$TEST_HOME/.claude/settings.json" "$(trusted_root)"
}

@test "--trust-working-folder-root is idempotent" {
  run "$BOOTSTRAP" "$TEST_WF" --skip-memory --trust-working-folder-root
  [ "$status" -eq 0 ]

  HASH1="$(md5 -q "$TEST_HOME/.claude/settings.json" 2>/dev/null || md5sum "$TEST_HOME/.claude/settings.json" | awk '{print $1}')"

  # Second working folder under the SAME parent — same trusted root
  TEST_WF2="$(dirname "$TEST_WF")/wf2"
  run "$BOOTSTRAP" "$TEST_WF2" --skip-memory --trust-working-folder-root
  [ "$status" -eq 0 ]

  HASH2="$(md5 -q "$TEST_HOME/.claude/settings.json" 2>/dev/null || md5sum "$TEST_HOME/.claude/settings.json" | awk '{print $1}')"
  [ "$HASH1" = "$HASH2" ]

  # Output should mention the path is already present
  [[ "$output" == *"already in permissions.additionalDirectories"* ]]
}

@test "--trust-working-folder-root backs up before overwriting" {
  mkdir -p "$TEST_HOME/.claude"
  cat > "$TEST_HOME/.claude/settings.json" <<'EOF'
{ "permissions": { "additionalDirectories": ["/x"] } }
EOF

  run "$BOOTSTRAP" "$TEST_WF" --skip-memory --trust-working-folder-root
  [ "$status" -eq 0 ]

  # At least one backup file exists
  ls "$TEST_HOME/.claude/settings.json.bak."* >/dev/null
  # Backup contents match the original
  BACKUP="$(ls "$TEST_HOME/.claude/settings.json.bak."* | head -1)"
  grep -q '"/x"' "$BACKUP"
  ! grep -q "$(trusted_root)" "$BACKUP"
}

@test "--trust-working-folder-root + --dry-run writes nothing" {
  run "$BOOTSTRAP" --dry-run "$TEST_WF" --skip-memory --trust-working-folder-root
  [ "$status" -eq 0 ]

  [ ! -f "$TEST_HOME/.claude/settings.json" ]
}

@test "without --trust-working-folder-root, settings.json is not touched" {
  run "$BOOTSTRAP" "$TEST_WF" --skip-memory
  [ "$status" -eq 0 ]

  [ ! -f "$TEST_HOME/.claude/settings.json" ]
}

@test "--trust-working-folder-root with workspace mode uses workspace parent dir" {
  WS="$TEST_TMP/lx-platform"
  run "$BOOTSTRAP" --workspace "$WS" --skip-memory --trust-working-folder-root
  [ "$status" -eq 0 ]

  EXPECTED_ROOT="$(dirname "$WS")"
  python3 -c "
import json, sys
d = json.load(open(sys.argv[1]))
ROOT = sys.argv[2]
assert ROOT in d['permissions']['additionalDirectories'], d
" "$TEST_HOME/.claude/settings.json" "$EXPECTED_ROOT"
}

@test "--trust-working-folder-root errors gracefully when settings.json is malformed" {
  mkdir -p "$TEST_HOME/.claude"
  echo "this is not json" > "$TEST_HOME/.claude/settings.json"

  run "$BOOTSTRAP" "$TEST_WF" --skip-memory --trust-working-folder-root
  # Bootstrap itself should still succeed (the trust-root step is best-effort);
  # but the bad-JSON error must be surfaced.
  [[ "$output" == *"could not parse"* ]] || [[ "$output" == *"settings.json inspection failed"* ]]
}

@test "--trust-working-folder-root flag appears in --help" {
  run "$BOOTSTRAP" --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"--trust-working-folder-root"* ]]
  [[ "$output" == *"additionalDirectories"* ]]
}
