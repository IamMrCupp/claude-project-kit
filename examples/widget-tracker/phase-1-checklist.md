# Phase 1 Checklist — Core CRUD + SQLite

**Goal:** Ship `add` + `list` commands backed by SQLite, with tests covering happy path and common error paths.
**Status:** ⏳ In progress (Section A done, Section B mid-flight, Section C not started)
**Exit criteria:** `add` + `list` work against a real SQLite file; CI green on macOS and Linux; README quickstart walkable in under 5 min by a new user.

---

## How to use this doc

- One item ≈ one branch ≈ one PR.
- Each item records branch name, commit message(s), and PR number once merged.
- Reference `implementation.md` specs by number (`see §A.2`).
- Tick items ✅ the moment the PR merges — not at end of phase.

---

## Section A — Schema & `add` command

### A.1 Schema design + migration runner

- **Spec:** `implementation.md` §A.1
- **Branch:** `feat/schema-and-migrations`
- **Commits:**
  - `feat(store): add schema v1 with widgets table`
  - `feat(store): add migration runner with version tracking`
- **PR:** [#4](https://github.com/exampleco/widget-tracker/pull/4) — merged 2026-03-28
- **Status:** [x] merged ✅

### A.2 `add` command — required fields validation

- **Spec:** `implementation.md` §A.2
- **Branch:** `feat/add-command`
- **Commits:**
  - `feat(cmd): add 'add' subcommand with name/location/tag flags`
  - `test(add): cover missing-required-field error paths`
- **PR:** [#5](https://github.com/exampleco/widget-tracker/pull/5) — merged 2026-04-02
- **Status:** [x] merged ✅

### A.3 Integration test for `add` against real SQLite file

- **Spec:** `implementation.md` §A.3
- **Branch:** `test/add-integration`
- **Commits:**
  - `test(integration): round-trip add through sqlite file`
- **PR:** [#6](https://github.com/exampleco/widget-tracker/pull/6) — merged 2026-04-03
- **Status:** [x] merged ✅

---

**Checkpoint A:** ✅ `add` works end-to-end. SQLite file on disk matches stdout output. Proceeded to B.

---

## Section B — `list` command

### B.1 `list` command — table output

- **Spec:** `implementation.md` §B.1
- **Branch:** `feat/list-command`
- **Commits:**
  - `feat(cmd): add 'list' subcommand with table output`
- **PR:** [#7](https://github.com/exampleco/widget-tracker/pull/7) — merged 2026-04-08
- **Status:** [x] merged ✅

### B.2 `list` — `--location` and `--tag` filter flags

- **Spec:** `implementation.md` §B.2
- **Branch:** `feat/list-filters`
- **Commits:**
  - `feat(cmd): add --location and --tag filters to list` (WIP)
- **PR:** [#8](https://github.com/exampleco/widget-tracker/pull/8) — ⏳ open, awaiting filter-precedence decision
- **Status:** [ ] in progress
- **Blocker:** need to decide whether `--location X --tag Y` is AND or OR semantics. Discussion in PR thread; leaning AND.

### B.3 Integration tests for `list` filters

- **Spec:** `implementation.md` §B.3
- **Branch:** `test/list-filters-integration`
- **Depends on:** B.2 merging first
- **Status:** [ ] not started

---

**Checkpoint B:** ⏳ blocked on B.2 filter semantics. Once decided, B.3 tests flow naturally.

---

## Section C — SQLite-backed store

### C.1 Replace in-memory store with SQLite-backed implementation

- **Spec:** `implementation.md` §C.1
- **Branch:** `refactor/sqlite-store` (not yet created)
- **Status:** [ ] not started
- **Notes:** depends on Section B completing so we have a stable `list` behavior to port. Section A's migration runner is already SQLite-native; only the in-memory path in `internal/store/mem.go` needs retiring.

### C.2 Document data file location + backup guidance in README

- **Spec:** `implementation.md` §C.2
- **Branch:** `docs/data-file-guidance`
- **Status:** [ ] not started
- **Notes:** depends on Open Question #4 (XDG vs. dotfile) being resolved.

---

**Checkpoint C:** end of Phase 1. Run acceptance tests before marking Phase 1 done.

---

## Acceptance testing

Before marking Phase 1 ✅ complete:

- [ ] Fresh-install: delete data dir, run `widget-tracker add` three times, `widget-tracker list` — confirm output matches insert order
- [ ] Filter correctness: `--location X`, `--tag Y`, `--location X --tag Y` all return expected rows
- [ ] Cross-platform: binary built on macOS runs on Linux without libc issues
- [ ] Quickstart: a new user can follow the README from clone → first `list` in under 5 minutes (time it)
- [ ] Upgrade path: older-schema DB file migrates cleanly without data loss

Record results in `acceptance-test-results.md`.

---

## Phase exit

- [ ] All items in A, B, C ticked
- [ ] Acceptance tests pass
- [ ] `plan.md` status line updated to "Phase 1 complete"
- [ ] `CONTEXT.md` updated — current phase, open threads reset for Phase 2
- [ ] Session entry appended to `SESSION-LOG.md`
