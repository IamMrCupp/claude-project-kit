# Acceptance Test Results — Phase {{N}}

**Phase:** {{Phase name}}
**Tester:** {{name}}
**Test date(s):** {{YYYY-MM-DD [to YYYY-MM-DD]}}
**Build under test:** {{commit hash / tag / PR number}}

**Overall status:** {{⏳ In progress / ✅ PASS / ❌ FAIL — see blockers below}}

---

## How to use this doc

- One test per section. Number them (Test 1, Test 2, …) so PRs and follow-up work can reference them.
- Every test has: **Goal**, **Setup**, **Steps**, **Expected**, **Actual**, **Result**.
- When a test fails, file a bug (or PR), link it under **Actual**, then re-run and update.
- At phase boundaries, either archive the previous phase's results (rename to `acceptance-test-results-phase-N.md`) or overwrite. Archive if you want traceable history; overwrite to keep the folder tidy. Pick one per project and stick with it.

---

## Test 1 — {{Short name}}

**Goal:** {{what are we verifying, in one sentence}}

**Setup:**
- {{Commands, state prerequisites, test data}}

**Steps:**
1. {{Concrete action}}
2. {{…}}

**Expected:**
- {{Log lines, state transitions, performance thresholds}}

**Actual:**
- {{Observations, log snippets, screenshots if applicable}}

**Result:** ⏳ Pending / ✅ PASS / ❌ FAIL — {{if fail: what next}}

---

## Test 2 — {{…}}

…

---

## Summary

| Test | Result | Notes |
|---|---|---|
| 1. {{name}} | {{✅ / ❌ / ⏳}} | {{one-line}} |
| 2. {{name}} | | |

**Blockers before exiting phase:**
- {{…or "none"}}
