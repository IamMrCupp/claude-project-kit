#!/usr/bin/env bats
# Regression guard for #278 — hand-maintained lists must match what ships.
#
# Two lists had drifted silently: the widget-tracker memory example still
# named two starters retired in #161 and was missing seven current ones, and
# tests/README.md's layout table covered 5 of ~40 bats files. Same shape as
# #258 / #263: a stated list with nothing comparing it to reality. These
# tests are the comparison — both directions, so a retired entry fails as
# loudly as a missing one.

load 'helpers'

TEMPLATES="$KIT_ROOT/memory-templates"
EXAMPLE_DIR="$KIT_ROOT/examples/widget-tracker/memory-example"
EXAMPLE_INDEX="$EXAMPLE_DIR/MEMORY.md"
TESTS_README="$KIT_ROOT/tests/README.md"

# Shipped starters that a bootstrapped project receives unchanged — every
# memory-templates/*.md except the index and the per-project files the
# example reproduces in its own directory.
shipped_as_is() {
  for f in "$TEMPLATES"/*.md; do
    name="$(basename "$f")"
    case "$name" in
      MEMORY.md|project_current.md|reference_ai_working_folder.md) continue ;;
    esac
    echo "$name"
  done | sort
}

# File names listed in the example's "Ships as-is" section.
example_as_is() {
  sed -n '/^## Ships as-is/,$p' "$EXAMPLE_INDEX" \
    | grep -oE '^- `[A-Za-z0-9_.-]+\.md`' | tr -d '`' | sed 's/^- //' | sort
}

# File names in the README's layout tables (backtick-quoted first column).
readme_listed() {
  grep -oE '^\| `[A-Za-z0-9_./-]+\.(bats|exp)`' "$TESTS_README" | tr -d '|` ' | sort
}

@test "widget-tracker example 'Ships as-is' list matches memory-templates/ exactly" {
  expected="$(shipped_as_is)"
  actual="$(example_as_is)"
  [ -n "$actual" ] || { echo "no 'Ships as-is' entries found in $EXAMPLE_INDEX"; return 1; }
  diff <(echo "$expected") <(echo "$actual") \
    || { echo "example list drifted from memory-templates/ (< shipped, > listed)"; return 1; }
}

@test "widget-tracker example reproduces exactly the per-project files its note names" {
  actual="$(ls "$EXAMPLE_DIR" | sort)"
  expected="$(printf '%s\n' MEMORY.md project_current.md reference_ai_working_folder.md reference_issue_tracker.md)"
  diff <(echo "$expected") <(echo "$actual")
}

@test "widget-tracker example issue-tracker memory carries the issue-first rule from trackers/github.md" {
  grep -q 'Issue-first' "$TEMPLATES/trackers/github.md"
  grep -q 'Issue-first' "$EXAMPLE_DIR/reference_issue_tracker.md"
}

@test "tests/README.md layout table lists every bats and expect file, and nothing else" {
  expected="$( { ls "$KIT_ROOT/tests"/*.bats | xargs -n1 basename;
                 ls "$KIT_ROOT/tests/interactive"/*.exp | xargs -n1 basename | grep -v '^helpers\.exp$' | sed 's|^|interactive/|'; } | sort)"
  actual="$(readme_listed)"
  diff <(echo "$expected") <(echo "$actual") \
    || { echo "tests/README.md table drifted from tests/ (< on disk, > listed)"; return 1; }
}
