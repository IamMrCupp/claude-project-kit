#!/usr/bin/env bash
# Runner for tests/interactive/*.exp — drives bootstrap.sh interactive mode.
#
# Each .exp file gets a fresh sandbox: temp dir, sandboxed $HOME, fake target
# repo with a git remote. Mirrors the per-test isolation in tests/helpers.bash.
#
# Usage:
#   tests/interactive/run.sh           # run all *.exp tests
#   tests/interactive/run.sh foo.exp   # run a single file (path or basename)

set -uo pipefail

KIT_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

if ! command -v expect >/dev/null 2>&1; then
  echo "error: 'expect' is required to run interactive tests" >&2
  echo "       macOS: brew install expect" >&2
  echo "       Debian/Ubuntu: sudo apt-get install -y expect" >&2
  exit 2
fi

if [ "$#" -gt 0 ]; then
  TARGETS=()
  for arg in "$@"; do
    if [ -f "$arg" ]; then
      TARGETS+=("$arg")
    elif [ -f "$SCRIPT_DIR/$arg" ]; then
      TARGETS+=("$SCRIPT_DIR/$arg")
    else
      echo "error: cannot find test file: $arg" >&2
      exit 2
    fi
  done
else
  TARGETS=("$SCRIPT_DIR"/[0-9]*.exp)
fi

PASS=0
FAIL=0
FAILED_TESTS=()

for exp in "${TARGETS[@]}"; do
  [ -f "$exp" ] || continue
  name="$(basename "$exp" .exp)"

  TEST_TMP="$(mktemp -d)"
  TEST_HOME="$TEST_TMP/home"
  TEST_REPO="$TEST_TMP/repo"
  mkdir -p "$TEST_HOME" "$TEST_REPO"
  git -C "$TEST_REPO" init -q
  git -C "$TEST_REPO" remote add origin "https://github.com/example/test-repo.git"

  if HOME="$TEST_HOME" \
     KIT_ROOT="$KIT_ROOT" \
     TEST_REPO="$TEST_REPO" \
     TEST_TMP="$TEST_TMP" \
     expect "$exp" >/tmp/exp-out.$$ 2>&1; then
    PASS=$((PASS + 1))
    echo "  ok  $name"
  else
    FAIL=$((FAIL + 1))
    FAILED_TESTS+=("$name")
    echo "  FAIL $name"
    sed 's/^/      /' /tmp/exp-out.$$
  fi

  rm -f /tmp/exp-out.$$
  rm -rf "$TEST_TMP"
done

echo
echo "Passed: $PASS  Failed: $FAIL"
if [ "$FAIL" -gt 0 ]; then
  printf 'Failed: %s\n' "${FAILED_TESTS[@]}"
  exit 1
fi
