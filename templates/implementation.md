# Implementation — {{PROJECT_NAME}}

Detailed implementation specs per task, across all phases. Numbered items — other documents reference these numbers (e.g. "see §1.8" or "§A.1").

**When to update:** when a task's approach materially changes (not for every minor tweak). This doc is the detail layer; `plan.md` is the summary layer; `phase-N-checklist.md` is the tracking layer.

---

## §0 — Phase 0 tasks

### §0.1 {{Task title}}

**Intent:** {{one-line what & why}}

**Approach:**
- {{Concrete steps}}

**Files touched:**
- `{{path/to/file}}` — {{what changes}}

**Verification:**
- {{How do we know this landed correctly}}

**References:**
- {{Link to research.md section, external doc, prior art}}

---

### §0.2 {{Next task}}

…

---

## §1 — Phase 1 tasks

### §1.1 {{…}}

…

---

## Post-landing notes

When a task ships, add a short "Landed" block under its heading with:
- Branch name
- PR number
- Date
- Anything that changed from the original spec during implementation (and why)

Example:
> **Landed:** `feat/foo-bar` → PR #7, merged 2026-04-18.
> During review we dropped the `--enable-baz` flag (unnecessary — default already covered it).
