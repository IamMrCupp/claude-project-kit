---
name: PRs must include detailed test plans
description: PRs that touch runtime code need a detailed manual test plan in the body — numbered steps, expected log lines, pass/fail criteria. "CI passes" is not enough.
type: feedback
---

Every PR that touches runtime / user-facing behavior gets a detailed manual test plan in the PR body under a `**Test plan**` section.

**Why:** CI catches regressions in what CI already knows to check. Real bugs show up in careful manual exercise — timing, state transitions, error paths, logs that nothing asserts on. A detailed test plan tells future-you (or a reviewer) exactly what to exercise, what evidence to collect, and when to call it verified. Skipping it means "probably works" ships as "works".

**How to apply:**
- For PRs touching runtime code, include in the body:
  - **Setup:** build command, service starts, test data loaded
  - **Steps:** one action per step, copy-pasteable
  - **Expected:** exact log lines / state transitions / timing thresholds
  - **Pass / fail criteria:** concrete, measurable ("stop completes in <200 ms", "exactly one `Disconnected` line in log")
- For pure-CI / docs / workflow PRs: short plan is fine but still explicit ("no runtime change; verification is CI alone")
- When a PR fixes an issue from a prior acceptance-test run, reference the test by number (`acceptance-test-results.md` Test 4)
- Write the plan *before* testing — it's also your plan for yourself, not just reviewer documentation
