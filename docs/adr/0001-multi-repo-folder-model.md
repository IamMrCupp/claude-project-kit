# ADR 0001: Multi-repo + ticket-driven folder model

- **Status:** Accepted
- **Date:** 2026-04-27
- **Anchor issue:** [#61](https://github.com/IamMrCupp/claude-project-kit/issues/61)
- **Phase:** Phase 4 — Multi-repo + ticket-driven workflows

## Context

The kit's original folder model assumes a 1:1 mapping between **target repository** and **AI working folder**, with one chronological `SESSION-LOG.md` per working folder. That assumption breaks down in three real-world scenarios surfaced in [#61](https://github.com/IamMrCupp/claude-project-kit/issues/61):

1. **Multi-repo initiatives.** A single piece of work can span multiple repos — e.g. Terraform environment definitions in one repo and versioned modules in another. There's no clean place for cross-repo "why this initiative exists" context, so it ends up duplicated (and going stale) in each repo's working folder.
2. **Ticket-driven, long-running repos.** When a repo is the home for many tickets over time, one growing `SESSION-LOG.md` buries per-ticket context and doesn't survive well across branches.
3. **Tracker as source of truth.** When the team uses an external tracker (JIRA, GitHub Issues), the ticket already has the summary, AC, and history. The kit shouldn't ask the user to copy that into the working folder — it should pull it.

This ADR records the six folder-model and integration decisions made in the Phase 4 design pass on 2026-04-27. They are the contract that the rest of Phase 4's PRs build against.

## Decisions

### D1. Workspace FS layout — nested

A workspace folder lives at `~/<projects-root>/<initiative>/`:

```
~/<projects-root>/<initiative>/
├── workspace-CONTEXT.md      ← cross-repo goals, links to all related repos
├── tickets/                  ← per-ticket scratchpads (see D2)
│   ├── <KEY>-<slug>.md
│   └── archive/
├── <repo-a>/                 ← per-repo subfolder (today's working-folder shape)
│   ├── CONTEXT.md
│   ├── SESSION-LOG.md
│   ├── plan.md
│   └── ...
└── <repo-b>/
    ├── CONTEXT.md
    └── ...
```

**Rationale:** the explicit hierarchy makes "this initiative spans these repos" obvious to a future-you opening the folder cold. Each repo subfolder is structurally identical to today's single-repo working folder, so all existing templates / conventions / commands apply at the per-repo level without modification. The workspace layer is purely additive.

**Alternatives rejected:**
- *Flat with prefix* (`<initiative>-<repo-a>/`, `<initiative>-<repo-b>/` as siblings, plus a separate `<initiative>/` for shared docs) — minimal change to bootstrap, but the cross-repo workspace folder is its own thing the user has to remember to update; the relationship between siblings is implicit in naming, not structural.
- *Single workspace, no per-repo subdivision* — one CONTEXT, one SESSION-LOG, repos as sections. Loses per-repo session granularity, which was one of #61's motivations.

### D2. Tickets — workspace root, `<KEY>-<slug>.md`, archive on close

Tickets live at `<initiative>/tickets/<KEY>-<slug>.md`, e.g. `tickets/ACME-1234-fix-lb-routing.md`.

- **Location:** workspace root (not per-repo). One ticket lives in one place even when the work spans multiple repos — avoids duplication and "which `tickets/ACME-1234.md` is current?" confusion.
- **Naming:** `<KEY>-<short-slug>.md`. The key is canonical and stable; the slug is for skim-readability when listing the directory. Either form alone wins on one axis and loses on the other; combining gets both.
- **Lifecycle:** when the upstream tracker ticket closes, the file moves to `<initiative>/tickets/archive/`. Keeps the active list scannable; preserves history for grepping.

**Alternatives rejected:**
- *Per-repo tickets* (`<initiative>/<repo-a>/tickets/<KEY>.md`) — fine for repo-local work, but a single tracker key spanning two repos produces duplicate ticket files. Workspace-root resolves this cleanly.
- *Both* (workspace + per-repo with cross-links) — adds decision overhead per ticket; not worth it until a real signal surfaces.

### D3. Tracker integration — slash command + helper script + Prompt 6

For v1, ship three surfaces:

1. **Slash command** (`/pull-ticket <KEY>`) — Claude-native, in `templates/.claude/commands/`. Discoverable, idiomatic for in-Claude workflows.
2. **Helper script** (`pull-ticket.sh <KEY>`) — top-level script. Works outside Claude — useful for terminal-driven workflows where the user wants to seed a scratchpad before opening Claude.
3. **Prose prompt** (Prompt 6 in `PROMPTS.md`) — the source of truth that the slash command and script both reference. Matches the kit's existing discipline (Prompt 1 ↔ `/session-start`, Prompt 3 ↔ `/session-end`, Prompt 5 ↔ `/refresh-context`).

All three lean on already-installed JIRA MCP / GitHub Issues MCP — the kit does **not** ship its own tracker client. **Read/reference only** — never writes to the tracker, never creates tracker projects / labels / workflows / sprint scaffolding (those are owned by PMs and the business).

**Alternatives rejected:**
- *Prompt-only for v1* — leanest, but loses the Claude-native UX and the terminal-driven path.

### D4. Bootstrap surface — `bootstrap.sh --workspace` flag

Extend the existing `bootstrap.sh` with a `--workspace` flag rather than shipping a separate `bootstrap-workspace.sh` or auto-detecting from the path argument.

- Without `--workspace`, today's single-repo behavior is unchanged.
- With `--workspace`, bootstrap creates the workspace folder (containing `workspace-CONTEXT.md` and `tickets/`) and a per-repo subfolder for the current repo.
- Subsequent `bootstrap.sh --workspace <existing-workspace> ...` invocations add another repo subfolder to the existing workspace.

**Alternatives rejected:**
- *Separate `bootstrap-workspace.sh`* — duplicates substantial code; two scripts to maintain.
- *Auto-detect from the path argument* — too magical; a path that happens to have a `workspace-CONTEXT.md` in it triggering different behavior is the kind of surprise the kit's "no surprises" posture rules out.

### D5. Single-repo → workspace upgrade — documented manual steps

Existing single-repo working folders **never need to migrate**. Both shapes coexist forever. For users who *want* to bring a single-repo folder into a workspace, the upgrade is documented as a handful of `mv` commands plus a `CONTEXT.md` edit, in a new section of `SETUP.md` (escalating to a dedicated `MIGRATION.md` only if it grows long).

No migration helper script — that overlaps with [#36](https://github.com/IamMrCupp/claude-project-kit/issues/36) (upgrade-helper-script), which stays parked until it earns a separate signal.

**Alternatives rejected:**
- *Migration helper script bundled with this phase* — overlaps with #36; would force premature design on the broader upgrade-helper question.
- *No migration docs at all* — leaves users who try the upgrade themselves to trip over decisions like "where does my SESSION-LOG go now."

### D6. Terraform-shape detection — Terraform + Terragrunt for v1

Bootstrap detects "Terraform-shaped" repos and proactively prompts about a sibling envs/modules repo when any of the following triggers fire:

- `*.tf` files
- `*.tfvars` files
- `.terraform.lock.hcl`
- `terraform/` or `modules/` directories
- `terragrunt.hcl`

**Alternatives deferred (for v1):**
- *Pulumi* (`Pulumi.yaml` / `Pulumi.<stack>.yaml`) — same envs ↔ modules pattern conceptually; deferred until a real Pulumi target repo surfaces.
- *CDK* (`cdk.json`) — typically monorepo; sibling-repo prompt rarely fires. Deferred.

These are promotion candidates if a signal surfaces.

## Consequences

### Positive

- Multi-repo initiatives have a structural home that survives the session.
- Ticket-driven work has a per-ticket scratchpad anchored to the tracker key — no more burying context in the chronological log.
- The kit stays tracker-agnostic at runtime (any tracker with an MCP works) while still capturing project metadata at bootstrap.
- The single-repo → workspace decision is "additive only," so existing adopters lose nothing.

### Negative / Costs

- Three tracker-integration surfaces (slash command + script + prompt) is more maintenance than prompt-only would have been. Acceptable cost for the UX flexibility — and the prompt is the source of truth, so the surfaces stay in sync if updates flow through it.
- A new top-level `tickets/` directory adds visual noise for users who don't use ticket-driven workflows. Mitigated by the workspace shape being opt-in (`--workspace` flag).
- Bootstrap surface grows — `--workspace` is one flag, but the help block, conditional branches, and bats coverage all scale with it.

### Neutral

- The kit gains its first ADR. Future architectural decisions can follow this format. Numbering is sequential (`0001`, `0002`, ...); placement is `docs/adr/`. See [`docs/adr/README.md`](README.md) for the pattern.

## References

- Anchor issue: [#61](https://github.com/IamMrCupp/claude-project-kit/issues/61)
- Related parked work: [#36](https://github.com/IamMrCupp/claude-project-kit/issues/36) (upgrade-helper-script)
- Existing slash-command discipline: `/session-start` ↔ Prompt 1, `/session-end` ↔ Prompt 3, `/refresh-context` ↔ Prompt 5
