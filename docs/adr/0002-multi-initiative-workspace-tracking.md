# ADR 0002: Multi-initiative workspace tracking

- **Status:** Accepted
- **Date:** 2026-05-03
- **Anchor issue:** [#133](https://github.com/IamMrCupp/claude-project-kit/issues/133)
- **Implementation:** [#138](https://github.com/IamMrCupp/claude-project-kit/pull/138) (scaffold), [PR A #175](https://github.com/IamMrCupp/claude-project-kit/pull/175) (templates + bootstrap + session-start + docs), [PR B #177](https://github.com/IamMrCupp/claude-project-kit/pull/177) (multi-initiative exemplar).

## Context

ADR-0001 established the workspace folder model: a workspace groups multiple repos under one `workspace-CONTEXT.md` plus a shared `tickets/` directory. The original framing assumed a workspace existed for **one initiative** — a coherent piece of work spanning multiple repos that ends when the work ships (e.g. "ship LX-1234 across envs + modules").

Real-world dogfooding surfaced a different shape (#133): for infra/platform/program work, the natural unit isn't the initiative — it's the **program**. The same repo set, stakeholders, and delivery pipeline persist across many initiatives over months or years. Treating each initiative as a fresh workspace forces context-switching for what is effectively the same program of work, fragments cross-cutting tickets and SESSION-LOG entries across short-lived workspaces, and loses the institutional memory of "what this workspace has shipped."

Multiple in-flight workspaces confirmed this need: an infrastructure program hosting Terraform + Helm + observability work, a company-product workspace, a personal project workspace. Each fits the "one persistent workspace, many initiatives over time" pattern.

This ADR records the design decisions for **how a workspace tracks multiple initiatives over time** — the file shape, the lifecycle, and the rename-on-archival pattern.

## Decisions

### D1. Layered file structure — pointer / roster / active-phase

A long-running workspace uses three workspace-scope files, each mirroring a per-repo file:

| Workspace file | Per-repo counterpart | Role |
|---|---|---|
| `workspace-CONTEXT.md` | `CONTEXT.md` | Workspace overview + **Current Initiative** pointer + **Past initiatives** chronicle |
| `workspace-plan.md` | `plan.md` | Initiative roster: Active / Planned / Completed |
| `workspace-phase-N-checklist.md` | `phase-N-checklist.md` | Phase tracking for the **active initiative**'s current phase |

`workspace-CONTEXT.md` answers "what is the workspace and what's it doing right now?" `workspace-plan.md` answers "what initiatives has this workspace done and what's coming?" `workspace-phase-N-checklist.md` answers "what cross-repo work is in flight right now?"

The split keeps each file scannable: the long-lived roster doesn't get cluttered with active-phase detail, and the active-phase checklist doesn't get cluttered with completed-initiative history.

**Rationale:** Mirroring the per-repo pattern means adopters learn one shape and apply it at two scopes (per-repo, workspace). It also keeps the kit's `external artifacts that survive sessions` philosophy intact at workspace scope — workspace docs are durable across sessions just like per-repo docs.

### D2. Long-running workspace pattern — one workspace, many initiatives

A workspace represents a **program** of work, not a single initiative. The same workspace persists across initiatives; the active initiative changes over time. Single-initiative workspaces (the original ADR-0001 framing) remain a valid use case — they're just one pattern within the broader model.

**Indicators that one workspace, many initiatives is right:**

- Same repo set across initiatives.
- Same stakeholders / on-call rotation / review cycles.
- Same delivery pipeline (Atlantis, CI/CD, etc.).
- Initiatives are sequenced (one wraps before the next starts), not parallel.

**Indicators that a separate workspace is right:**

- Different repos, different stakeholders, or different delivery pipeline.
- Different program of work entirely (e.g. personal vs. work projects).
- Truly parallel initiatives that don't share day-to-day context.

When in doubt, start with one workspace; splitting later is cheaper than retrofitting two unrelated programs into one.

**Rationale:** The repo set + stakeholder set is what makes a workspace coherent. As long as those are stable, the workspace persists. Initiatives are chapters within that book.

### D3. Rename-on-archival, not folder hierarchy

When an active initiative wraps, its phase checklist is **renamed** from `workspace-phase-N-checklist.md` → `<initiative-slug>-phase-N-checklist.md`. Files stay in the same directory; the prefix tells you what they are.

The archived checklist sits alongside the workspace's other files at the workspace root, with the unprefixed name freed up for the next initiative's first phase.

**Alternative considered:** Move archived checklists into an `archive/` subfolder. Documented as a valid alternative in `SETUP.md` — keeps the root scannable for workspaces with many archived initiatives, at the cost of one more directory level. Either pattern is acceptable; the kit doesn't enforce one. The exemplar in `examples/acme-platform/` uses the rename-only form for clarity.

**Rationale:** Most workspaces will have ≤10 archived initiatives over their lifetime. Renaming keeps everything one `ls` away. The folder option scales further but adds friction for the common case.

### D4. Cross-repo items in workspace phase checklist

Items in `workspace-phase-N-checklist.md` are **cross-repo by default** — each item records branches and PRs across **multiple repos** under one shared tracker key. This is the workspace-scope counterpart to per-repo items, which track a single PR in a single repo.

Format:
```
### A.1 {{Task title}}

- **Tracker:** ACME-1234
- **Repos:**
  - **terraform-modules** — branch `feat/ACME-1234-slug` → PR #312
  - **terraform-envs** — branch `feat/ACME-1234-bump-pin` → PR #198
- **Status:** [ ] merged
```

**Alternative considered:** Workspace phase checklist as a thin pointer to per-repo checklists ("see `terraform-modules/phase-2-checklist.md` items B.3–B.5"). Rejected — the cross-repo arc is itself the unit of work for the initiative; pointing-only buries the cross-repo coordination.

**Rationale:** Multi-repo work shares a tracker key + a logical "this is the same change" identity across PRs. The workspace checklist is the right home for tracking that identity. Per-repo checklists still exist for repo-internal phases unrelated to the active initiative (e.g. an internal refactor in `terraform-modules` that has nothing to do with the current workspace initiative).

### D5. Per-repo and workspace phase checklists are independent

A repo subfolder can have its own `phase-N-checklist.md` for repo-internal phases (refactors, internal cleanups) while the workspace runs a separate phase numbering for the active initiative. The two dimensions don't have to align.

**Rationale:** A repo's lifecycle (its own phase progression) is decoupled from which workspace initiative happens to be active. Forcing alignment would conflate two independent things.

## Alternatives rejected

- **One mega workspace file** with sections for active, planned, completed initiatives + active phase items + ticket roster. Rejected because the file grows unwieldy past ~500 lines and conflates long-lived roster (workspace-plan) with short-lived active-phase detail (workspace-phase-N-checklist).
- **Initiatives-as-folders** (`<initiative-slug>/plan.md`, `<initiative-slug>/phase-N-checklist.md`). Rejected because most workspaces have ≤10 initiatives; folder-per-initiative adds friction for navigation and duplicates the per-repo pattern unnecessarily. The rename-on-archival pattern (D3) gives the same effect without the directory sprawl.
- **One workspace per initiative** (the original ADR-0001 framing as the only pattern). Rejected as the *only* pattern — see D2 indicators. ADR-0001's single-initiative shape is now one valid use case, not the only one.
- **Auto-archive on session-end / close-phase** — the kit could detect that an initiative wrapped and rename the checklist automatically. Deferred. Manual rename is one shell command and avoids edge cases (mis-detection, partial renames, race with `/close-phase`'s own writes). Revisit if the rename step becomes a recurring source of friction.

## Consequences

### Positive

- **Adopters learn one shape, apply at two scopes.** Per-repo CONTEXT.md → plan.md → phase-N-checklist.md mirrors workspace-CONTEXT.md → workspace-plan.md → workspace-phase-N-checklist.md. Conceptual reuse cuts onboarding time.
- **Long-running programs stay legible over time.** A workspace with five completed initiatives still has a scannable `workspace-plan.md` — each initiative's outcome is one paragraph in "Completed initiatives", and per-initiative phase detail lives in archived checklists that are easy to find by filename.
- **Cross-repo work has a clear home.** D4's item format makes it obvious what work spans repos and what doesn't. The shared tracker key ties per-repo PRs back to the workspace-level item.
- **Forward-compatible with single-initiative use.** The single-initiative pattern from ADR-0001 still works — `workspace-plan.md` just has one entry that never moves to "Completed". No migration cost for existing workspaces.
- **Per-repo lifecycles stay independent.** D5 lets repos progress through their own phase work without forcing alignment with the workspace's initiative cadence.

### Negative / Costs

- **More files at workspace root** than before. A long-running workspace will have `workspace-CONTEXT.md`, `workspace-plan.md`, `workspace-phase-N-checklist.md`, plus archived `<initiative-slug>-phase-N-checklist.md` files for each completed initiative. The `archive/` subfolder alternative (D3) is available for workspaces that prefer that shape.
- **Small mental load for the rename-on-archival ritual.** SETUP.md documents it; the workspace-phase-N-checklist template's Phase exit block reminds the user. Still, it's a manual step.
- **Minor duplication for single-initiative workspaces.** If a workspace truly only ever has one initiative, `workspace-plan.md` and `workspace-phase-N-checklist.md` overlap somewhat with `workspace-CONTEXT.md`. Acceptable cost — the structure scales as soon as a second initiative arrives.
- **Tickets folder ages indefinitely** without an explicit archival mechanic for cross-initiative tickets (separate concern, tracked in [#134](https://github.com/IamMrCupp/claude-project-kit/issues/134)).

### Neutral

- Extends but doesn't change the folder model from ADR-0001. Workspaces still nest per-repo subfolders; tickets still live at workspace root with `archive/`; tracker integration is unchanged.
- Doesn't change `bootstrap.sh`'s surface beyond copying one additional template file (workspace-phase-N-checklist.md) when `--workspace` creates a new workspace. Per [PR A](https://github.com/IamMrCupp/claude-project-kit/pull/175).

## References

- Anchor issue: [#133](https://github.com/IamMrCupp/claude-project-kit/issues/133) — workspace mode for long-running multi-initiative programs
- Predecessor ADR: [`0001-multi-repo-folder-model.md`](0001-multi-repo-folder-model.md) — the original workspace folder model
- Implementation PRs:
  - [#138](https://github.com/IamMrCupp/claude-project-kit/pull/138) — scaffold (`Current Initiative` section in workspace-CONTEXT, `workspace-plan.md`)
  - [#175](https://github.com/IamMrCupp/claude-project-kit/pull/175) — `workspace-phase-N-checklist.md` template + bootstrap + session-start + docs
  - [#177](https://github.com/IamMrCupp/claude-project-kit/pull/177) — multi-initiative exemplar in `examples/acme-platform/`
- Related: [#134](https://github.com/IamMrCupp/claude-project-kit/issues/134) — ticket archival helper for `tickets/archive/` (separate concern, accumulates as workspaces age)
- Docs:
  - [`SETUP.md` § Long-running workspace layout](../../SETUP.md#single-initiative-vs-long-running-workspaces)
  - [`PROMPTS.md` Prompt 11](../../PROMPTS.md#11-starting-a-session-in-a-long-running-multi-initiative-workspace)
  - [`templates/workspace/workspace-phase-N-checklist.md`](../../templates/workspace/workspace-phase-N-checklist.md)
  - Worked example: [`examples/acme-platform/`](../../examples/acme-platform/)
