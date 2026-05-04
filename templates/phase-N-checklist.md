# Phase {{N}} Checklist — {{Phase Name}}

**Goal:** {{one sentence}}
**Status:** {{⏳ In progress / ✅ Complete}}
**Exit criteria:** {{what must be true before this phase is considered done — typically an acceptance test pass}}

---

## How to use this doc

- One item ≈ one branch ≈ one PR.
- Organize items into sections (A, B, C, …) with checkpoints between major chunks. Helps you pause and re-orient.
- Each item records issue number (when applicable), branch name, commit message(s), and PR number once merged.
- Reference `implementation.md` specs by number (`see §1.4`) rather than duplicating.
- Tick items ✅ the moment the PR merges — not at end of phase.
- **Issue-first when you own the tracker:** when the tracker is yours (e.g. GitHub Issues on your own repo), open an issue *before* starting trackable work and record `#N` in the `Issue:` field below. PRs use `Closes #N` so the issue auto-closes on merge. See `CONVENTIONS.md` → *Ticket-driven workflows* → *Issue-first when you own the tracker* for the full rule. For externally-owned trackers (work JIRA, upstream OSS), leave `Issue:` blank or remove the field — read-only is the default there.

---

## Section A — {{Section name}}

### A.1 {{Task title}}

- **Spec:** `implementation.md` §{{X.Y}}
- **Issue:** #{{N}} — {{leave blank if tracker is externally-owned or no issue applies}}
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

> **Required by convention.** Every phase MUST exit with a non-empty `acceptance-test-results.md`. See `CONVENTIONS.md` → "Acceptance tests at phase boundaries" for the rule and the one allowed escape hatch. Removing this section is a convention violation, not a customization — `/close-phase` will refuse to close if it's missing.

Before marking this phase ✅ complete, run the test sequence and record results in `acceptance-test-results.md` (Goal / Setup / Steps / Expected / Actual / Result per test). List the tests here so the checklist itself signals when testing starts:

- [ ] Test 1 — {{what to verify}}
- [ ] Test 2 — {{…}}

---

## Phase exit

- [ ] All items in all sections ticked
- [ ] Acceptance tests pass (see `acceptance-test-results.md`) — OR document the skip on a single line below this block: `Acceptance tests intentionally skipped — rationale: {{one sentence}}`
- [ ] `plan.md` status line updated to reflect phase complete
- [ ] `CONTEXT.md` updated — current phase, known issues, architectural decisions that landed
- [ ] Session entry appended to `SESSION-LOG.md` describing phase completion
