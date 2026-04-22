# Session Log — widget-tracker

Chronological record of Claude working sessions. Each entry captures what was done, decisions made, and anything non-obvious that future sessions should know.

**Append-only.** Never delete past entries. If something in an old entry turns out wrong, note the correction in the current session's entry rather than editing history.

---

## Session: 2026-03-15 — Bootstrap + Phase 0 kickoff

**Focus:** Initial project bootstrap. Set up repo, working folder, auto-memory, CI skeleton.

**Branches/PRs:**
- `chore/initial-scaffold` → PR [#1](https://github.com/exampleco/widget-tracker/pull/1) (merged) — Go module init, dir layout
- `ci/github-actions-baseline` → PR [#2](https://github.com/exampleco/widget-tracker/pull/2) (merged) — lint, test, cross-compile matrix

**Key decisions:**
- **Layout:** `cmd/widget-tracker/` for main, `internal/store/` for storage, `internal/widget/` for domain types. Rejected `pkg/` (not an exported library).
- **SQLite driver:** `modernc.org/sqlite` (pure Go). Rationale: avoids CGO so we can static-cross-compile from any host. Slightly slower than `mattn/go-sqlite3` but acceptable for single-operator CLI. See `research.md` §1.
- **License:** Apache 2.0 (matches team's other public tools).

**Non-obvious findings:**
- `golangci-lint` 1.57 has a regression on Go 1.22 generics — pinned to 1.56 in CI for now, tracked upstream.
- GitHub Actions cache for Go modules cuts CI time from ~2 min to ~45 s — worth the config.

**Open threads / next steps:**
- Start Phase 0 acceptance: hello-world binary should build and run from the CI artifact.
- Scaffold `phase-0-checklist.md`.

---

## Session: 2026-03-22 — Phase 0 complete, Phase 1 schema work begins

**Focus:** Close out Phase 0 acceptance, scaffold Phase 1 checklist, start on SQLite schema.

**Branches/PRs:**
- `feat/hello-world` → PR [#3](https://github.com/exampleco/widget-tracker/pull/3) (merged) — minimal main that prints version, proves CI artifact pipeline
- `feat/schema-and-migrations` → PR [#4](https://github.com/exampleco/widget-tracker/pull/4) (open → merged 2026-03-28)

**Key decisions:**
- **Migration strategy:** forward-only, idempotent numbered migrations under `internal/store/migrations/`. No rollback — too much complexity for a single-operator tool. If a migration breaks, users restore from CSV export.
- **Schema v1:** `widgets(id, name, location, tags, created_at, updated_at)`. Tags stored as JSON array in a TEXT column for v1 — room to normalize later if search perf matters.

**Non-obvious findings:**
- The `modernc.org/sqlite` driver doesn't support `PRAGMA journal_mode=WAL` via the standard DSN params — have to issue it as a query after opening. Found the hard way when WAL file wasn't appearing in testing.
- Phase 0 acceptance tests took longer than planned because the cross-compile matrix surfaced a darwin/arm64 specific build tag issue (fixed in PR #3).

**Open threads / next steps:**
- Finish migration runner (PR #4 still open)
- Next session: start on `add` command (§A.2)
- Reconcile Open Question #4 (data file location) before Section C — affects docs, not code, so deferrable.

---

## Session: 2026-04-05 — `add` done, starting `list`

**Focus:** Acceptance-test `add` end-to-end, kick off `list` command.

**Branches/PRs:**
- `test/add-integration` → PR [#6](https://github.com/exampleco/widget-tracker/pull/6) (merged 2026-04-03)
- `feat/list-command` → PR [#7](https://github.com/exampleco/widget-tracker/pull/7) (open)

**Key decisions:**
- **Table output format:** fixed-width columns for now; will add `--json` output in Phase 2. Rejected `tabwriter` flush-on-every-row because it flickered in tailed scenarios — buffer-and-flush-once is fine for the expected row counts.
- **Empty-list behavior:** `list` on empty store exits 0 with message "no widgets found" on stderr, nothing on stdout. Matches `grep`-friendly conventions.

**Non-obvious findings:**
- Feedback from Aaron: single-word `list` output header was ambiguous when piping into `awk`. Switched to `NAME    LOCATION    TAGS` with explicit column headers. Saved as feedback memory "stdout headers are data too".
- Integration test for `add` initially flaked in CI because the test dir was being created inside the repo — migrated to `t.TempDir()` and flakes disappeared.

**Open threads / next steps:**
- B.2 filter flags next — AND vs OR semantics decision needed. Lean AND.
- Start thinking about Section C's in-memory → SQLite swap. Not urgent; Section B first.
- Open Question #4 still unresolved; try to resolve before Section C so README docs can be authoritative.

---
