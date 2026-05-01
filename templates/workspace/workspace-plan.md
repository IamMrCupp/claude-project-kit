# Workspace Plan — {{WORKSPACE_NAME}}

The persistent plan for this workspace. Tracks initiatives over time — current, planned, completed. Per-repo phase plans live in each repo's `plan.md`; this file sits one level up and chronicles the program-level arc.

**Update cadence:**
- When a new initiative kicks off — add it under "Active initiative" and move the prior one (if any) to "Completed initiatives".
- When scope of the active initiative changes meaningfully — edit in place, note the date.
- When new initiatives appear on the horizon — add to "Planned / on deck" with whatever certainty you have.

This file is the workspace counterpart to a per-repo `plan.md`. Keep it scannable; deeper detail belongs in per-repo planning docs or per-ticket scratchpads.

---

## Active initiative

### {{Initiative name}} — {{kicking off | active | wrapping up}}

**Started:** {{YYYY-MM-DD}}
**Target completion:** {{YYYY-MM-DD or "open-ended"}}
**Initiative key:** {{epic / OKR / codename}}
**Repos primarily touched:** {{<repo-a>, <repo-b>}}

**Goal:** {{one paragraph — what done looks like}}

**Scope (what's in):**
- {{…}}
- {{…}}

**Out of scope (deliberate):**
- {{…}}

**Open questions / risks:**
- {{…}}

**Cross-references:**
- Per-repo plan sections: {{<repo-a>/plan.md#section, <repo-b>/plan.md#section}}
- Tracker epic / parent: {{key + link if applicable}}

---

## Planned / on deck

Initiatives the workspace expects to take on but isn't actively working yet. Order = rough priority. Move to "Active initiative" when work starts.

- **{{Initiative name}}** — {{one-paragraph scope; trigger that starts it}}
- **{{Initiative name}}** — {{…}}

---

## Completed initiatives

Chronicle of what this workspace has shipped, most recent first. Each entry is one paragraph max plus cross-references — anything more detailed lives in per-repo `SESSION-LOG.md` entries and archived ticket scratchpads.

### {{YYYY-MM-DD}} — {{Initiative name}}

**Outcome:** {{one or two sentences — what shipped, the impact}}

**Key cross-references:**
- {{archived tickets, key PRs, ADRs spawned}}

---

## Notes

- The workspace itself is long-running; initiatives come and go. If the workspace's purpose drifts substantially, consider whether you actually want a *new* workspace rather than retrofitting this one.
- For converting a single-repo working folder into a workspace, see [SETUP.md §Upgrading a single-repo working folder to a workspace](https://github.com/IamMrCupp/claude-project-kit/blob/main/SETUP.md#upgrading-a-single-repo-working-folder-to-a-workspace) in the kit.
