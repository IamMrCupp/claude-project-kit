# Phase {{N}} Checklist — {{Phase Name}}

**Goal:** {{one sentence}}
**Status:** {{⏳ In progress / ✅ Complete}}
**Exit criteria:** {{what must be true before this phase is considered done — typically an acceptance test pass}}

---

## How to use this doc

- One item ≈ one branch ≈ one PR.
- Organize items into sections (A, B, C, …) with checkpoints between major chunks. Helps you pause and re-orient.
- Each item records branch name, commit message(s), and PR number once merged.
- Reference `implementation.md` specs by number (`see §1.4`) rather than duplicating.
- Tick items ✅ the moment the PR merges — not at end of phase.

---

## Section A — {{Section name}}

### A.1 {{Task title}}

- **Spec:** `implementation.md` §{{X.Y}}
- **Branch:** `{{type/name}}`
- **Commits:**
  - `{{type(scope): message}}`
- **PR:** #{{N}} — {{link}}
- **Status:** [ ] merged

---

### A.2 {{Task title}}

…

---

**Checkpoint A:** {{Brief summary — what's working after A is done. Anything to validate before moving to B?}}

---

## Section B — {{Section name}}

### B.1 {{Task title}}

…

---

## Acceptance testing

Before marking this phase ✅ complete, run the manual test sequence and record results in `acceptance-test-results.md`. List the tests here so the checklist itself signals when testing starts:

- [ ] Test 1 — {{what to verify}}
- [ ] Test 2 — {{…}}

---

## Phase exit

- [ ] All items in all sections ticked
- [ ] Acceptance tests pass (see `acceptance-test-results.md`)
- [ ] `plan.md` status line updated to reflect phase complete
- [ ] `CONTEXT.md` updated — current phase, known issues, architectural decisions that landed
- [ ] Session entry appended to `SESSION-LOG.md` describing phase completion
