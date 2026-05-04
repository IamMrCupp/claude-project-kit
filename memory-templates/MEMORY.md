# Memory Index

Starter index. Every file in this folder is a **starting point** — copy them into the project's real memory folder, then:

- Edit each file to match your actual rules and tooling (several assume GitHub + `gh` CLI — adapt for GitLab / Jenkins / etc. if needed)
- Prune entries that don't apply
- Add new ones as rules come up during real work

Do not treat these as canonical without reading them first — they encode one opinionated way of working.

- [User role and background](user_role.md) — who you're collaborating with, how to calibrate explanations
- [AI working folder location](reference_ai_working_folder.md) — read CONTEXT.md + SESSION-LOG.md at {{WORKING_FOLDER}}/ before work
- [Commit format](feedback_commit_format.md) — Conventional Commits, single line, signed off
- [Merge strategy](feedback_merge_strategy.md) — always merge commits; never squash or rebase
- [Push branches by default](feedback_push_branches.md) — `git push -u origin <branch>` after commit without asking
- [Watch CI in background](feedback_watch_ci_in_background.md) — spawn `gh run watch` in background after push
- [Don't push after merge](feedback_no_push_after_merge.md) — once a PR merges, the branch is closed; branch off new `main` for follow-up work
- [Use the repo's branch-name convention](feedback_branch_naming.md) — rename auto-generated worktree branches to `<type>/<slug>` before pushing
- [Prefer automated tests over manual smoke](feedback_automated_tests_preferred.md) — default to bats / expect / integration runners; don't ship manual procedures as steady state
- [Tracker authority decides the default](feedback_no_tracker_creation.md) — issue-first when you own the tracker; read/reference only for externally-owned trackers
- [Don't manually tag when release automation is configured](feedback_release_per_pr.md) — release-please etc. handle tagging; do nothing release-wise after a normal PR merge
- [Keep planning docs in sync](feedback_docs_in_sync.md) — update plan / checklist / implementation as work lands
- [Current project context](project_current.md) — what's being built, why, timeline
