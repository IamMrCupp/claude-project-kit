# PLAN: {{PROJECT_NAME}}
**Repository:** `{{REPO_SLUG}}`
**Last updated:** {{YYYY-MM-DD}}
**Status:** {{one-line status — e.g. "Phase 0 in progress"}}

---

## Overview

{{2–3 paragraphs: what is this project, what does it do, why does it exist, what's the current landscape that makes it worth building.}}

---

## Goals

- {{Goal 1}}
- {{Goal 2}}
- …

## Non-Goals (for now)

- {{What this project explicitly will NOT do}}
- …

---

## Platform / Target Environment

| Platform | Architecture | Priority |
|---|---|---|
| {{e.g. macOS}} | {{e.g. arm64 + x86_64}} | {{P0 / P1 / P2}} |

{{Or for non-native projects: deployment targets, supported browsers, runtime versions, etc.}}

---

## Phases

Break the project into phases. Each phase ships something — either a milestone build, an internal capability, or a release. Keep phases small enough that a single phase fits on one `phase-N-checklist.md` without overwhelming it.

---

### Phase 0 — Setup

**Goal:** Everything needed before writing real feature code. Repo, CI, license, scaffolding, first "hello world" running.

**Tasks** — tracked in `phase-0-checklist.md`:
- [ ] {{Create / configure repo}}
- [ ] {{CI baseline}}
- [ ] {{Build works locally}}
- [ ] {{Linter / formatter / commit-message check}}
- [ ] {{License, README, AI disclosure if applicable}}
- [ ] {{"Hello world" artifact confirms end-to-end pipeline}}

---

### Phase 1 — {{First capability}}

**Goal:** {{What does this phase deliver?}}

**Tasks** — tracked in `phase-1-checklist.md`:
- …

---

### Phase 2 — {{Next capability}}

**Goal:** {{…}}

---

## Open Questions

Track decisions that affect scope or architecture but aren't yet resolved. Promote resolved OQs to the relevant phase / `implementation.md` entry.

| # | Question | Status | Notes |
|---|---|---|---|
| 1 | {{…}} | ⏳ Open | {{…}} |

---

## Risks

- **{{Risk name}}** — {{what it is, how bad, mitigation}}
- …
