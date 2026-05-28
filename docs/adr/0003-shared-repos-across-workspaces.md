# ADR 0003: Shared repos across workspaces

- **Status:** Accepted
- **Date:** 2026-05-28
- **Anchor issue:** [#199](https://github.com/IamMrCupp/claude-project-kit/issues/199)
- **Implementation:** [PR A #239](https://github.com/IamMrCupp/claude-project-kit/pull/239) (`bootstrap.sh --shared` + `--reference` + template sections), [PR B #241](https://github.com/IamMrCupp/claude-project-kit/pull/241) (`scripts/convert-to-shared.sh` migration helper), PR C (this commit — `/session-start` surfacing + this ADR).

## Context

ADR-0001 established the per-repo working-folder model: each repo gets exactly one canonical working folder, keyed by repo path. ADR-0002 extended the workspace model to host many initiatives over time within one workspace. Both ADRs share an implicit assumption: **one repo = at most one workspace**. The repo's per-repo subfolder lives under that workspace; the workspace's `workspace-CONTEXT.md` lists it; auto-memory's `reference_ai_working_folder.md` points there.

Real-world infra/platform repos break that assumption. A `flux/k8s` config repo gets consumed by multiple platform programs. An internal Terraform module repo is touched by half a dozen initiatives across teams. A shared Helm-chart repo is referenced from several deployment programs. The kit's per-repo auto-memory pointer can only hold one path, so trying to bootstrap the same repo under two workspaces overwrites the pointer each time — the second workspace's subfolder "wins," the first goes stale.

Before #199, the only workable patterns were both lossy:

- **Pick a "primary" workspace** and reference the repo from others by cross-pointing inside `workspace-CONTEXT.md`. The repo's per-repo state lives under the primary; other workspaces have no per-repo subfolder for it. Works, but no tooling support — references are hand-written, no slash command awareness, no migration path.
- **Bootstrap as a standalone single-repo working folder** (no `--workspace`). The repo is unattached to any workspace; consuming workspaces have no formal way to declare they depend on it. Workspaces drift out of sync with the repo's actual usage.

Both patterns were documented as a manual workaround in SETUP.md (v0.39.1) but lacked tooling. #199 makes them a first-class kit pattern.

## Decisions

### D1. Standalone working folder + reference pattern

The shared repo gets **one canonical working folder, outside any workspace**. Each workspace that depends on it adds a lightweight reference to its `workspace-CONTEXT.md` without creating a per-repo subfolder.

```
~/Documents/Claude/Projects/
├── shared-flux-config/           ← standalone working folder (--shared)
│   ├── CONTEXT.md                ← canonical per-repo state, with optional
│   │                                "## Referenced by" listing consuming workspaces
│   ├── SESSION-LOG.md
│   └── plan.md
├── platform-infra/               ← workspace A
│   ├── workspace-CONTEXT.md      ← "## Shared repos" entry → shared-flux-config
│   └── terraform-modules/        ← per-repo subfolder for a non-shared repo
└── data-platform/                ← workspace B (same shared-repo reference)
    ├── workspace-CONTEXT.md
    └── ...
```

Two `bootstrap.sh` flags make this directly invokable:

- `--shared` — bootstraps the standalone working folder with the optional `## Referenced by` section seeded in `CONTEXT.md`. Mutually exclusive with `--workspace`.
- `--workspace <ws> --reference <shared-wf>` — repeatable. Adds a `## Shared repos` entry to the workspace's `workspace-CONTEXT.md`. Read-only on the shared side.

The migration path (existing per-repo subfolder → standalone) is `scripts/convert-to-shared.sh`.

**Rationale:** Per-repo state — branches, SESSION-LOG entries, plan documents — is one thing regardless of which workspace is asking. The standalone working folder gives that state one canonical home. Workspaces opt in lightweight, so multiple programs can coexist without fighting over the auto-memory pointer.

### D2. Read-only on the shared side

`bootstrap.sh --workspace <ws> --reference <shared-wf>` writes to the workspace's `workspace-CONTEXT.md`. It deliberately does **not** modify the shared repo's working folder, auto-memory, or any other file inside the shared-repo state.

The shared repo's `## Referenced by` section is *user-curated* — the section ships in the template and `--shared` seeds it, but listing specific consuming workspaces is the user's call. This matches the kit's stance on memory files (user-owned, never auto-overwritten) and avoids workspace-A's bootstrap silently mutating shared-repo state visible to workspace-B.

**Rationale:** Asymmetric coupling is intentional. Workspaces opt into a shared repo; the shared repo doesn't auto-track its consumers (the human curates the list when it's useful). The alternative — auto-appending to the shared repo's `## Referenced by` on every `--reference` invocation — risks the shared repo accumulating references from forgotten or abandoned workspaces with no auto-cleanup.

### D3. Migration helper repoints auto-memory with a documented carve-out

`scripts/convert-to-shared.sh` modifies `~/.claude/projects/<sanitized-repo-path>/memory/reference_ai_working_folder.md` to point at the new standalone path. That file is otherwise treated as never-overwrite (see `scripts/sync-memory.sh`'s reserved-files list).

The migration justifies the write with four guards:

1. `.bak.<timestamp>` backup before any modification.
2. Always-on plan preview, made non-destructive via `--dry-run`.
3. Confirmation prompt before applying, skippable with `--yes` for scripted runs.
4. Defensive precondition checks — the script refuses to proceed if the repo isn't currently a per-repo subfolder under a workspace, or if the target standalone path already exists.

**Rationale:** A one-time, user-initiated, well-guarded write to a normally-untouched file is preferable to telling adopters to hand-edit memory or to recreate working folders from scratch.

### D4. `/session-start` surfaces the shared-repo context

When `CONTEXT.md` carries a `## Referenced by` section, the `/session-start` slash command adds a line to its grounding summary naming the consuming workspaces. Non-shared repos (no `## Referenced by` section) see nothing — the surfacing is silent when not applicable.

**Rationale:** A shared repo's session needs cross-program context that a workspace-scoped session doesn't. Surfacing the consumers up front lets the user state which initiative they're working in, which shapes which `workspace-CONTEXT.md` to reach for if work spans multiple workspaces.

## Alternatives considered and rejected

### A1. True multi-home — each workspace owns its own per-repo state

Each consuming workspace would get its own `<workspace>/<repo>/CONTEXT.md` and `SESSION-LOG.md` for the same repo. **Rejected.**

The repo's underlying state (branches, history, recent commits, ongoing work) is one thing regardless of which workspace is asking. Per-workspace copies would drift over time — workspace-A's `SESSION-LOG.md` would record one set of commits, workspace-B's would record a different overlapping set, and reconciliation would be a constant tax. Auto-memory's per-repo pointer can only hold one location anyway, so one of the copies would always be the "real" one — multi-home would just hide which.

### A2. Symlinks under each workspace pointing at a canonical location

Each consuming workspace would have a `<workspace>/<repo>/` symlink resolving to a canonical `~/Documents/Claude/Projects/<repo>/` directory. **Rejected.**

Symlinks are tooling-fragile. Some shells, editors, and file-management tools resolve symlinks transparently; others don't. The kit's bats tests, `find`, and Claude Code itself all behave differently under symlinks. More importantly, the visual structure ("this repo lives under this workspace") would lie to the user — the canonical path would surface in tool output unpredictably. The reference-in-workspace-CONTEXT pattern keeps the relationship explicit and inspectable.

### A3. Primary workspace + cross-workspace references

The shared repo would live as a per-repo subfolder under one "primary" workspace; other workspaces would reference back via `workspace-CONTEXT.md`. **Rejected.**

This was the manual workaround pre-#199 (documented in SETUP.md v0.39.1). It works, but elevates one workspace as more-equal-than-the-others without a principled reason. Promoting one consumer to "primary" is often arbitrary — the program that bootstrapped the workspace first isn't necessarily the most important consumer, and the choice has to be re-litigated when programs come and go.

Making the shared repo's working folder standalone (no workspace owns it) treats all consuming workspaces symmetrically.

### A4. Auto-detection of "this repo is shared"

Bootstrap could detect a repo is shared automatically — e.g. by checking whether the auto-memory pointer is already set when re-bootstrapping. **Rejected.**

Explicit opt-in (`--shared`, `--reference`, `convert-to-shared.sh`) keeps the kit's "no magic" stance intact. Auto-detection would surface false positives (a repo re-bootstrapped after a `rm -rf` of the working folder looks like a "shared" repo by this heuristic). The flags are cheap to type and unambiguous.

## Consequences

### Positive

- **First-class pattern for infra/platform adopters** — flux/k8s, Helm, shared Terraform modules, observability configs all fit cleanly now without manual workarounds.
- **One canonical per-repo state**, regardless of how many workspaces reference the repo. No drift, no reconciliation tax.
- **Migration path** for existing setups via `convert-to-shared.sh` — adopters who hit the shared-repo problem mid-program can promote without rebuilding.
- **`/session-start` cross-program awareness** when working in a shared repo — the user knows up front which programs depend on this repo.

### Negative

- **Manual curation of `## Referenced by`** on the shared side. The shared repo's listing of consuming workspaces is user-edited; bootstrap doesn't auto-append back. Some adopters may forget to update it when wiring new references. Acceptable tradeoff for the asymmetric-coupling design (D2).
- **Two new bootstrap flags + one new helper script** add surface area to the kit's CLI. Mitigated by both being opt-in / unused by default and the flags being orthogonal to existing ones.
- **Tickets stay workspace-scoped, not shared-repo-scoped.** Tickets that touch the shared repo as part of a workspace's initiative live in the workspace's `tickets/`, per ADR-0001 / ADR-0002. The shared repo's own `tickets/` is for shared-repo-only work, which is rare. Some adopters may find this surprising; documented in SETUP.md.

### Neutral

- **Backward-compatible.** Existing per-repo + workspace setups continue to work unchanged. The new flags are opt-in; the new template sections are conditionally seeded.
- **Stability contract.** `--shared`, `--reference`, the new template sections, and the `convert-to-shared.sh` CLI are part of the kit's stable surface per STABILITY.md as of v1.3.0.

## Related

- ADR-0001 — multi-repo + ticket-driven folder model (the original 1-repo-1-workspace assumption this ADR extends).
- ADR-0002 — multi-initiative workspace tracking (the orthogonal extension: many initiatives per workspace).
- [#199](https://github.com/IamMrCupp/claude-project-kit/issues/199) — anchor issue.
- [#134](https://github.com/IamMrCupp/claude-project-kit/issues/134) — sibling concern (ticket archival in long-running workspaces with shared-repo cross-traffic).
