# PLAN: widget-tracker
**Repository:** `exampleco/widget-tracker`
**Last updated:** 2026-04-12
**Status:** Phase 1 in progress — list command + SQLite backend

---

## Overview

`widget-tracker` is a small command-line tool for tracking inventory of physical widgets across multiple storage locations. It's built for a single operator who needs to add, list, and search items without spinning up a database server — SQLite is the storage backend, the binary is a single static Go executable.

The project exists because spreadsheet-based tracking has repeatedly lost data when users overwrite each other's edits, and the team doesn't want to introduce a cloud service for something this small. A local CLI with an import/export path lets each operator run their own instance and swap data files when they need to collaborate.

Public on GitHub under Apache 2.0.

---

## Goals

- Add / list / search widgets by name, location, tag
- SQLite storage — single file, portable, scriptable with `sqlite3` CLI
- Cross-platform: macOS + Linux (Windows via WSL acceptable; not a primary target)
- Import / export as CSV so the tool doesn't lock data in
- Binary size ≤ 15 MB; startup ≤ 50 ms on commodity laptops

## Non-Goals (for now)

- No multi-user / server mode
- No GUI
- No realtime sync between instances — CSV round-trip is the sync mechanism
- No web UI / TUI — plain stdout + stderr

---

## Platform / Target Environment

| Platform | Architecture | Priority |
|---|---|---|
| macOS | arm64 + x86_64 | P0 |
| Linux | x86_64 | P0 |
| Linux | arm64 | P1 |
| Windows (WSL) | x86_64 | P2 |

---

## Phases

### Phase 0 — Setup ✅ complete

**Goal:** Scaffold the repo, CI, and a "hello world" binary that proves the build + test pipeline works end-to-end.

**Status:** Complete. See `SESSION-LOG.md` entries from 2026-03-15 and 2026-03-22.

**Summary of landed work:**
- Go module init, layout chosen (`cmd/widget-tracker/`, `internal/`)
- GitHub Actions CI: lint (golangci-lint), test, cross-compile for macOS/Linux
- License, README, AI disclosure
- Hello-world binary confirmed CI artifact pipeline

---

### Phase 1 — Core CRUD + SQLite ⏳ in progress

**Goal:** Ship the core commands (`add`, `list`) backed by SQLite, with tests covering the happy path and common error paths. End of Phase 1 = a usable tool for single-operator inventory work.

**Tasks** — tracked in `phase-1-checklist.md`:
- [x] A.1: Schema design + migration system
- [x] A.2: `add` command with required fields
- [x] A.3: Integration test for `add`
- [x] B.1: `list` command — table output
- [ ] B.2: `list` — `--location` and `--tag` filters
- [ ] B.3: Integration tests for `list` filters
- [ ] C.1: Replace in-memory store with SQLite-backed store
- [ ] C.2: Document the data file location and backup expectations in README

**Exit criteria:** `add` + `list` work against a real SQLite file; CI green on macOS and Linux; README has a quickstart that a new user can follow in under 5 minutes.

---

### Phase 2 — Search + import/export

**Goal:** Make the tool useful for a second operator by adding search and CSV import/export.

**Scoped but not detailed yet** — promote to `phase-2-checklist.md` when Phase 1 closes.

- `search <term>` — substring match across name, location, tags
- `export --format csv` — dump the entire DB to stdout
- `import --format csv` — load from a CSV file, with conflict handling (skip / overwrite / merge)
- Shell completion (zsh + bash) — stretch goal

---

## Open Questions

| # | Question | Status | Notes |
|---|---|---|---|
| 1 | SQLite in-process vs. a lightweight embedded key-value store? | ✅ Resolved | Chose SQLite — see `research.md` §1 |
| 2 | Should `add` allow duplicate widget names? | ⏳ Open | Leaning "unique by (name, location)" composite; final call at end of Phase 1 |
| 3 | How do we handle concurrent access to the SQLite file across terminals? | ⏳ Open | SQLite has WAL mode; confirm it's enough or add advisory lock |
| 4 | Data file location — `~/.local/share/widget-tracker/db.sqlite` (XDG) or `~/.widget-tracker/db.sqlite`? | ⏳ Open | Leaning XDG on Linux, `~/Library/Application Support/widget-tracker/` on macOS |

---

## Risks

- **SQLite migration churn** — if the schema changes a lot during Phase 1, users who tried early builds may end up with orphaned data files. Mitigation: stamp a schema version early, implement migration runner before shipping the first release.
- **CSV round-trip fidelity** — free-text fields with commas/quotes/newlines. Mitigation: use the standard library's `encoding/csv`, not a hand-rolled parser.
- **Binary size creep** — Go binaries with SQLite (pure-Go driver) are already ~10 MB. Additional deps could push past 15 MB. Mitigation: review each new import; prefer stdlib.
