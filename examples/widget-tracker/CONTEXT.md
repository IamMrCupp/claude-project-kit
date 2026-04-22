# Claude Working Context — widget-tracker
**Last updated:** 2026-04-12
**Project:** `exampleco/widget-tracker`
**Repo path:** `/Users/dev/Code/widget-tracker`

---

## How to load this context

At the start of any new Claude session, say:
> "Read CONTEXT.md and SESSION-LOG.md in this folder before we start."

Or rely on `reference_ai_working_folder.md` in auto-memory, which points here.

---

## Project Overview

`widget-tracker` is a single-binary Go CLI for tracking inventory of physical widgets across multiple storage locations. SQLite storage, no server, no GUI. Built because spreadsheet-based tracking kept losing data to concurrent edits and the team didn't want to introduce a cloud service. Each operator runs a local instance; CSV import/export is the sync mechanism between operators.

- **GitHub / host:** https://github.com/exampleco/widget-tracker
- **Visibility:** public
- **Platform targets:** macOS (arm64 + x86_64), Linux (x86_64 primary; arm64 P1), Windows-via-WSL (P2)
- **This folder:** private AI working context — never commit to repo

---

## Planning Document System

- **`plan.md`** — phases, goals, open questions, risks
- **`implementation.md`** — detailed specs per numbered task; other docs reference (§X.Y)
- **`phase-N-checklist.md`** — trackable items for one phase; one file per phase
- **`acceptance-test-results.md`** — manual verification log for the current phase
- **`research.md`** — frozen technical research (SQLite vs. key-value store, etc.)
- **`SESSION-LOG.md`** — chronological session history, append-only
- **`CONTEXT.md`** — this file

---

## Working Rules

### Git & commits
- Conventional Commits, single line, signed off (`git commit -s -m "type(scope): message"`)
- Branch naming: `feat/…`, `fix/…`, `ci/…`, `docs/…`, `test/…`, `chore/…`
- Merge-commit PR strategy (preserves granular commits for git-cliff changelog generation at release time)
- Push branches to origin by default after committing

### PRs
- Title ≤ 70 chars, Conventional Commit form
- Body includes a manual test plan for any change touching runtime behavior
- Tick the test plan off with evidence after passing
- Required CI checks: `lint`, `test-macos`, `test-linux`

### Shell / build
- Shell: zsh (macOS) / bash (Linux); scripts target Bash 3+
- Local build: `go build ./cmd/widget-tracker`
- Local test: `go test ./...`
- Lint: `golangci-lint run` (config in `.golangci.yml`)

### File editing
- Repo is mounted at `/Users/dev/Code/widget-tracker`
- Claude reads + edits directly; never copy-paste code through chat

---

## Current Phase Status

**Phase 0 — Setup: ✅ complete** (wrapped 2026-03-22; see `SESSION-LOG.md`).

**Phase 1 — Core CRUD + SQLite: ⏳ in progress.** Section A done (schema + `add`), Section B mid-flight (`list` command works, filters pending), Section C not yet started (SQLite backend swap).

**Known issues / open threads:**
- `list` currently uses the in-memory store — will be swapped to SQLite in Section C
- Composite-unique-key decision for `(name, location)` still open (Open Question #2 in `plan.md`)
- CI on Linux-arm64 is P1 — matrix not yet expanded, acceptable for Phase 1

---

## Key Dependencies

- Go 1.22+ (generics used in `internal/store/`)
- `modernc.org/sqlite` — pure-Go SQLite driver. Avoids CGO so we can statically cross-compile. Trade-off: slightly slower than cgo-based `mattn/go-sqlite3`, but acceptable for single-operator CLI workloads. See `research.md` §1.
- `golangci-lint` v1.57+ — pinned in CI
- No runtime network dependencies — fully offline tool

---

## CI Overview

- **CI platform:** GitHub Actions
- **Targets:** macOS-latest (arm64), ubuntu-latest (x86_64)
- **Quality gates:** `golangci-lint`, `go test ./...` with race detector, cross-compile check for linux/arm64
- **Release:** `gh release create` + GoReleaser for multi-arch binary builds (Phase 2 scope)

---

## Acceptance Testing Setup

Manual acceptance testing runs against a fresh SQLite file at `~/.local/share/widget-tracker/db.sqlite` (Linux) or `~/Library/Application Support/widget-tracker/db.sqlite` (macOS). See `acceptance-test-results.md` for the current phase's test log and reset procedure.

---

## Open Questions

| # | Question | Status |
|---|---|---|
| 2 | Should `add` allow duplicate widget names? | ⏳ Open — see `plan.md` §Open Questions |
| 3 | Concurrent SQLite access across terminals — WAL mode enough? | ⏳ Open |
| 4 | Data file location — XDG vs. dotfile? | ⏳ Open |

(Open Question #1 — SQLite vs. key-value store — resolved in Phase 0; see `research.md` §1.)

---

## Reference

- `plan.md` — phase breakdown and scope
- `phase-1-checklist.md` — current phase, with branch/PR info per item
- `implementation.md` — numbered specs referenced from checklists
- `research.md` — frozen technical research (SQLite driver choice, data file location)
- `SESSION-LOG.md` — chronological session history
