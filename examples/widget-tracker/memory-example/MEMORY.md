# Memory Index

> **About this snapshot:** Only the four files that vary per project are reproduced in this directory (`MEMORY.md`, `reference_ai_working_folder.md`, `reference_issue_tracker.md`, `project_current.md`). The remaining entries below are referenced by file name in code spans — they ship as-is from `memory-templates/` with no per-project edits, so a real bootstrapped project's memory directory contains them unchanged. In a real `MEMORY.md` every entry is a clickable link.

## Per-project (in this snapshot)

- [AI working folder location](reference_ai_working_folder.md) — read CONTEXT.md + SESSION-LOG.md at session start
- [Issue tracker — GitHub Issues](reference_issue_tracker.md) — tickets live on `exampleco/widget-tracker`
- [Current project context](project_current.md) — what's being built, why, timeline

## Ships as-is from `memory-templates/`

- `user_role.md` — who you're collaborating with, how to calibrate explanations
- `feedback_commit_format.md` — Conventional Commits, single line, signed off
- `feedback_merge_strategy.md` — always merge commits; never squash or rebase
- `feedback_push_branches.md` — `git push -u origin <branch>` after commit without asking
- `feedback_pr_test_plans.md` — detailed numbered manual-test steps with expected logs
- `feedback_pr_check_off_on_pass.md` — edit PR body with evidence + ✅ after testing
- `feedback_watch_ci_in_background.md` — spawn `gh run watch` in background after push
- `feedback_docs_in_sync.md` — update plan / checklist / implementation as work lands
- `feedback_no_ai_coauthor.md` — commits attributed to the human committer only
