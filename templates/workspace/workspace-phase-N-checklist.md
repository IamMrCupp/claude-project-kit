# Workspace Phase {{N}} Checklist — {{Phase Name}}

**Initiative:** {{Initiative name from `workspace-plan.md` "Active initiative"}}
**Goal:** {{one sentence — what done looks like for this phase of this initiative}}
**Status:** {{⏳ In progress / ✅ Complete}}
**Exit criteria:** {{what must be true before this phase is considered done — typically an acceptance test pass across the touched repos}}
**Repos touched:** {{<repo-a>, <repo-b>}}

---

## How to use this doc

This is the workspace counterpart to a per-repo `phase-N-checklist.md`. It tracks one phase of the **active initiative** at the workspace level — the cross-repo arc, not the internals of any one repo.

- One item ≈ one branch ≈ one PR. Items often span repos within the workspace — record the branch + PR for each repo touched.
- For ticket-driven work, items typically reference a tracker key (e.g. ACME-1234) shared across the per-repo PRs.
- Organize items into sections (A, B, C, …) with checkpoints between major chunks.
- Tick items ✅ the moment the LAST per-repo PR for that item merges — not at end of phase.
- Per-repo phases (each repo's `plan.md` / `phase-N-checklist.md`) drift independently from this workspace phase. Use this checklist for the cross-repo initiative arc; use per-repo checklists for repo-internal phases.

---

## Section A — {{Section name}}

### A.1 {{Task title}}

- **Tracker:** {{KEY-NNN if applicable}}
- **Repos:**
  - **{{repo-a}}** — branch `{{type/KEY-NNN-slug}}` → PR #{{N}}
  - **{{repo-b}}** — branch `{{type/KEY-NNN-slug}}` → PR #{{N}}
- **Status:** [ ] merged

---

### A.2 {{Task title}}

…

---

**Checkpoint A:** {{What's working across repos after A is done. Cross-repo validation steps if any.}}

---

## Section B — {{Section name}}

…

---

## Acceptance testing

> **Required by convention.** Every phase MUST exit with a non-empty `acceptance-test-results.md`. See `CONVENTIONS.md` → "Acceptance tests at phase boundaries" for the rule and the one allowed escape hatch. Removing this section is a convention violation, not a customization — `/close-phase` will refuse to close if it's missing.

For workspace phases, acceptance tests typically span repos. List them here:

- [ ] Test 1 — {{cross-repo verification — e.g. "deploy the new module from <repo-a>, run the integration suite from <repo-b>"}}
- [ ] Test 2 — {{…}}

---

## Phase exit

- [ ] All items in all sections ticked (across every repo touched)
- [ ] Acceptance tests pass (see `acceptance-test-results.md`) — OR document the skip on a single line below this block: `Acceptance tests intentionally skipped — rationale: {{one sentence}}`
- [ ] `workspace-plan.md` updated — initiative phase status, any scope drift recorded
- [ ] `workspace-CONTEXT.md` updated — current initiative status, known issues, architectural decisions
- [ ] Session entry appended to `workspace-SESSION-LOG.md` describing phase completion
- [ ] If this phase completes the **active initiative**: move it from "Active initiative" to "Completed initiatives" in `workspace-plan.md` and archive this checklist (rename to `<initiative-slug>-phase-{{N}}-checklist.md`, or move all the initiative's phase checklists to an `archive/` subfolder). The next initiative starts with a fresh `workspace-phase-N-checklist.md` (renumbering from 1).
