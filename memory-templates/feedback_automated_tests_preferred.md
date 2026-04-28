---
name: Prefer automated tests over documented manual smoke procedures
description: When closing a test-coverage gap, default to automation (bats, expect, integration runners) over documented manual smoke-test procedures — humans skip or rationalize manual checks.
type: feedback
---

When evaluating how to close a test-coverage gap, default to automated test infrastructure (e.g. `bats`, `expect`, integration runners, contract tests) over documented manual smoke-test procedures — even when the surface is small or stable, and even when the automation requires a new tool dependency.

**Why:** humans skip manual test plans or rationalize "it probably still works" when they're tired or in a hurry. A documented script in a README becomes ceremonial within a few iterations; an automated test runs every time and can't be lied about. The setup cost of automation pays back the first time it catches a regression a manual procedure would have missed.

**How to apply:**
- When given options like "automation vs. manual procedure vs. accept the gap," default to automation unless there's a concrete reason it's infeasible (physical hardware, paid third-party API, irreducibly visual UI without snapshot tooling).
- Adding a new dependency (`expect`, an integration framework, a snapshot library) is acceptable. CI install time is cheap relative to the cost of an undetected regression.
- A documented manual smoke procedure is only acceptable as a temporary stopgap with an issue tracking the automation work — never as the steady state.
- If proposing manual coverage in a design discussion, expect pushback and have the automation alternative ready.
