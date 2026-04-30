# Examples

Filled-in reference copies of what a project's working folder looks like partway through real work. These are **read-me-for-reference**, not copy-me-and-fill.

## Why this exists

The kit's `templates/` directory ships skeleton files with `{{PLACEHOLDER}}` markers meant to be copied into your project's working folder and filled in (see [SETUP.md](../SETUP.md)). That shows you the shape, but not the *substance* — the hard question is always "what does a plausible, populated `CONTEXT.md` actually read like?"

This folder answers that. Each subfolder is a fictional project at a realistic mid-phase state — not a perfect exemplar, just an honest snapshot.

## What's here

- `widget-tracker/` — a made-up small Go CLI. Mid-Phase 1: Phase 0 shipped, Phase 1 partially complete. Demonstrates populated `CONTEXT.md`, a multi-phase `plan.md`, a `phase-1-checklist.md` with mixed ✅ / ⏳ / [ ] states, and a `SESSION-LOG.md` with a few chronological entries. **Single-repo working folder.**
- `widget-tracker/memory-example/` — a snapshot of what auto-memory looks like for the same project mid-Phase 1. Shows the four files that change per project (`MEMORY.md` index, `reference_ai_working_folder.md`, `reference_issue_tracker.md`, `project_current.md`) with placeholders resolved. The other memory files in `memory-templates/` (the `feedback_*.md` rules and `user_role.md`) ship as-is — no per-project edits needed — and aren't reproduced here.
- `acme-platform/` — a fictional **multi-repo workspace** for an AWS Terraform initiative. Two repos (`terraform-modules`, `terraform-envs`) under one workspace, JIRA-driven via the `ACME` project. Demonstrates `workspace-CONTEXT.md` (cross-repo overview + shared tracker config), per-repo `CONTEXT.md` + `SESSION-LOG.md`, an active per-ticket scratchpad ([ACME-1234](acme-platform/tickets/ACME-1234-fix-lb-routing.md)) showing branches/PRs across both repos, and an archived ticket ([ACME-1100](acme-platform/tickets/archive/ACME-1100-add-vpc-module.md)) showing the lifecycle when a ticket closes. Phase docs (`plan.md`, phase checklists) are intentionally omitted here — see `widget-tracker/` for those.

## How to use

- Read. Don't copy.
- Compare against the matching file in `templates/` — the example shows what's concrete, the template shows where to put your own content.
- Use as a reference when you're halfway through filling your own working folder and you're unsure how formal or verbose to be.

## Conventions for this folder

If you add a new example here:
- Keep the project fictional. Don't seed examples from real work unless the real project is fully public already.
- Show a realistic state, not a perfect one. A checklist where every item is ✅ isn't instructive — mixed states are.
- Skip files that don't add value. Not every example needs all seven template files.
- Update this `README.md` to mention the new example.
