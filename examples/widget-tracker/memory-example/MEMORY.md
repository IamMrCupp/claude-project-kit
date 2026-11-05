# Memory Index

> **About this snapshot:** Only the four files that vary per project are reproduced in this directory (`MEMORY.md`, `reference_ai_working_folder.md`, `reference_issue_tracker.md`, `project_current.md`). The remaining entries below are referenced by file name in code spans — they ship as-is from `memory-templates/` with no per-project edits, so a real bootstrapped project's memory directory contains them unchanged. In a real `MEMORY.md` every entry is a clickable link.

## Per-project (in this snapshot)

- [AI working folder location](reference_ai_working_folder.md) — read CONTEXT.md + SESSION-LOG.md at session start
- [Issue tracker — GitHub Issues](reference_issue_tracker.md) — tickets live on `exampleco/widget-tracker`
- [Current project context](project_current.md) — what's being built, why, timeline

## Ships as-is from `memory-templates/`

- `user_role.md` — who you're collaborating with, how to calibrate explanations
- `feedback_commit_format.md` — `git commit -s -m "type(scope): subject"`, single line, no `Co-Authored-By` trailer
- `feedback_no_ai_coauthor.md` — commits attributed to the human committer only
- `feedback_merge_strategy.md` — always merge commits; never squash or rebase
- `feedback_push_branches.md` — `git push -u origin <branch>` after commit without asking
- `feedback_watch_ci_in_background.md` — spawn `gh run watch` in background after push
- `feedback_no_push_after_merge.md` — once a PR merges the branch is closed; branch off new `main` for follow-up work
- `feedback_no_work_on_main.md` — propose a `<type>/<slug>` branch before editing tracked files
- `feedback_branch_naming.md` — rename auto-generated worktree branches to `<type>/<slug>` before pushing
- `feedback_branch_base.md` — `git checkout main && git pull` before `checkout -b`; never stack on an open PR's branch
- `feedback_automated_tests_preferred.md` — default to bats / expect / integration runners over manual smoke procedures
- `feedback_no_tracker_creation.md` — issue-first when you own the tracker; read/reference only when you don't
- `feedback_release_per_pr.md` — release automation handles tagging; nothing release-wise by hand after a merge
- `feedback_docs_in_sync.md` — update plan / checklist / implementation as work lands
- `feedback_chips_use_the_kit.md` — spawned task chips open with `/session-start`, the memory rules, issue-first, `/session-end`
