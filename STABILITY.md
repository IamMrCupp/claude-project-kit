# Stability contract

As of **v1.0.0**, `claude-project-kit` commits to not breaking the surfaces below without a major version bump. This is the promise behind the `1.x` line: you can adopt the kit, build habits and tooling around it, and trust that a `1.x` upgrade won't silently change the things you depend on.

Versioning follows [Semantic Versioning](https://semver.org/):

- **MAJOR** (`2.0.0`) — a breaking change to a stable surface below.
- **MINOR** (`1.1.0`) — new, backward-compatible capability (a new flag, a new template, a new slash command).
- **PATCH** (`1.0.1`) — backward-compatible fixes and editorial changes.

Releases are cut automatically by [release-please](https://github.com/googleapis/release-please) from Conventional Commit history. From `1.0.0` on, `feat!:` / `BREAKING CHANGE:` commits trigger a major bump rather than being folded into a minor.

---

## Stable surfaces — what `1.x` will not break

- **`bootstrap.sh` CLI** — flag names, default behavior, and what it writes where. Adding new flags is non-breaking; **removing or renaming** a flag, or changing a default's effect, is breaking.
- **Helper script CLI surface** — `sync-templates.sh`, `sync-memory.sh`, `install-commands.sh` (incl. `--force-update`), `install-scripts.sh`, `rename-workspace.sh`, `pull-ticket.sh`, `upgrade.sh` (incl. `--force-commands` / `--force-scripts`). Same flag-rename-is-breaking rule as `bootstrap.sh`.
- **Template field names + structure** — `CONTEXT.md`'s required sections (Project Overview, Working Rules, Current Phase Status, …); `phase-N-checklist.md`'s `## Acceptance testing` and `## Phase exit` blocks; `acceptance-test-results.md`'s Goal / Setup / Steps / Expected / Actual / Result fields; the workspace templates' `workspace-CONTEXT.md` and `ticket.md` shapes.
- **Auto-memory schema** — frontmatter fields (`name`, `description`, `type`), the four `type` values (`user` / `feedback` / `project` / `reference`), and the `MEMORY.md` index-line format.
- **Slash command names** — `/session-start`, `/session-end`, `/session-handoff`, `/session-verify`, `/refresh-context`, `/close-phase`, `/pull-ticket`, `/run-acceptance`, `/research`, `/plan`, plus any added after `1.0.0`. Renames or removals are breaking; adding new prechecks or enforcement *within* a command is not.
- **Working-folder location convention** — the working folder lives **outside** the repo, with its parent dir trustable via `permissions.additionalDirectories`. The kit doesn't promise a specific path, but it does promise the "separate from the repo" model.

## Explicitly NOT covered — may change in any release

- Editorial wording in `README.md` / `CONVENTIONS.md` / `FEATURES.md` / `SETUP.md` and other prose docs.
- Internal helper functions inside `bootstrap.sh` and the `scripts/lib/` helpers.
- Bats test names and structure (kit-internal).
- The specific entries shipped in `memory-templates/` — adding, removing, or renaming a starter memory file is allowed; the auto-memory **schema** is what's stable, not the particular starter set.
- The **prose body** of a slash command (the `.md` Claude follows) — the contract is on the command's name and invocation, not the exact instructions inside it.

---

## How to read a release

Each release's `CHANGELOG.md` entry carries a **For existing adopters** note when an upgrade needs any action. A `1.x → 1.y` upgrade should never require changing your filled-in templates, memory, or scripts to keep working. If you ever hit one that does, that's a bug — please [open an issue](https://github.com/IamMrCupp/claude-project-kit/issues).
