# Memory Index

Starter index. Every file in this folder is a **starting point** — copy them into the project's real memory folder, then:

- Edit each file to match your actual rules and tooling (several assume GitHub + `gh` CLI — adapt for GitLab / Jenkins / etc. if needed)
- Prune entries that don't apply
- Add new ones as rules come up during real work

Do not treat these as canonical without reading them first — they encode one opinionated way of working.

- [User role and background](user_role.md) — who you're collaborating with, how to calibrate explanations
- [AI working folder location](reference_ai_working_folder.md) — read CONTEXT.md + SESSION-LOG.md at session start
- [Commit format](feedback_commit_format.md) — Conventional Commits, single line, signed off
- [Merge strategy](feedback_merge_strategy.md) — always merge commits; never squash or rebase
- [Push branches by default](feedback_push_branches.md) — `git push -u origin <branch>` after commit without asking
- [PR test plans](feedback_pr_test_plans.md) — detailed numbered manual-test steps with expected logs
- [Check off PR tests on pass](feedback_pr_check_off_on_pass.md) — edit PR body with evidence + ✅ after testing
- [Watch CI in background](feedback_watch_ci_in_background.md) — spawn `gh run watch` in background after push
- [Keep planning docs in sync](feedback_docs_in_sync.md) — update plan / checklist / implementation as work lands
- [Current project context](project_current.md) — what's being built, why, timeline
