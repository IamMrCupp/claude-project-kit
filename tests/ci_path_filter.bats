#!/usr/bin/env bats
# Regression guard for #282 — the bats workflow must run on every path the
# suite reads.
#
# .github/workflows/bats.yml filters pull_request runs by path. The filter
# was written when the suite only covered bootstrap.sh and the templates;
# by the time it had 40 files it also read scripts/, .claude/, examples/,
# docs/ and four top-level docs — none of them in the filter. A PR touching
# only one of those merged without the suite running. These tests derive
# the paths the suite references ($KIT_ROOT/<x>) and assert the filter
# covers each one, so the next new test directory can't fall outside CI.

load 'helpers'

WORKFLOW="$KIT_ROOT/.github/workflows/bats.yml"

# Patterns under `on.pull_request.paths`, one per line, quotes stripped.
pr_paths() {
  awk '
    /^  pull_request:/ { in_pr = 1; next }
    in_pr && /^  [A-Za-z]/ { in_pr = 0 }
    in_pr && /^      - / { sub(/^      - /, ""); gsub(/'\''/, ""); print }
  ' "$WORKFLOW"
}

# Paths the suite reads, relative to the kit root. A reference that continues
# with a shell variable (`$KIT_ROOT/tests/$name`) is cut at the variable, so
# it resolves to the directory — which is what the filter has to cover.
referenced_paths() {
  grep -ohE '\$KIT_ROOT/[A-Za-z0-9_./-]+' "$KIT_ROOT"/tests/*.bats "$KIT_ROOT"/tests/helpers.bash \
    | sed -e 's|^\$KIT_ROOT/||' -e 's|/$||' | sort -u
}

# 0 if $1 is matched by at least one filter pattern. A pattern `X/**`
# covers X itself and everything under it; anything else must match exactly.
covered() {
  local ref="$1" p prefix
  while IFS= read -r p; do
    [ -n "$p" ] || continue
    case "$p" in
      "$ref") return 0 ;;
      */'**')
        prefix="${p%/\*\*}"
        case "$ref" in "$prefix"|"$prefix"/*) return 0 ;; esac
        ;;
    esac
  done <<< "$(pr_paths)"
  return 1
}

@test "bats.yml declares a pull_request path filter that this test can read" {
  patterns="$(pr_paths)"
  [ -n "$patterns" ] || { echo "no pull_request.paths found — parser broke or filter removed"; return 1; }
  echo "$patterns" | grep -qx 'tests/\*\*'
  echo "$patterns" | grep -qx '.github/workflows/bats.yml'
}

@test "covered() rejects a path that is not in the filter (guard is not vacuous)" {
  run covered "no-such-dir-$$"
  [ "$status" -ne 0 ]
  run covered "no-such-dir-$$/file.md"
  [ "$status" -ne 0 ]
}

@test "the suite references at least the directories that motivated #282" {
  refs="$(referenced_paths)"
  for want in scripts .claude examples docs; do
    echo "$refs" | grep -qE "^$want(/|$)" || { echo "expected tests to reference \$KIT_ROOT/$want"; return 1; }
  done
}

@test "every path the suite reads is covered by the pull_request filter" {
  missing=""
  while IFS= read -r ref; do
    [ -n "$ref" ] || continue
    covered "$ref" || missing="$missing $ref"
  done <<< "$(referenced_paths)"
  [ -z "$missing" ] || { echo "referenced by tests but not in bats.yml paths:$missing"; return 1; }
}

@test "every filter entry points at something that exists" {
  while IFS= read -r p; do
    [ -n "$p" ] || continue
    target="${p%/\*\*}"
    [ -e "$KIT_ROOT/$target" ] || { echo "filter entry '$p' matches nothing in the repo"; return 1; }
  done <<< "$(pr_paths)"
}
