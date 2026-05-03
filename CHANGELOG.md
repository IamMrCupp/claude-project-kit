# Changelog

All notable changes to `claude-project-kit`. Format loosely follows [Keep a Changelog](https://keepachangelog.com/). Tagged releases are published on [GitHub Releases](https://github.com/IamMrCupp/claude-project-kit/releases); entries below include version tags where applicable.

See [Upgrading an existing project](SETUP.md#upgrading-an-existing-project) for the general migration pattern. Each entry below has a **For existing adopters** section with specifics for that release.

---

## [0.34.0](https://github.com/IamMrCupp/claude-project-kit/compare/v0.33.0...v0.34.0) (2026-05-03)


### Features

* **scripts:** upgrade.sh — one-command kit + project upgrade orchestrator ([e9a4546](https://github.com/IamMrCupp/claude-project-kit/commit/e9a45468c1fc13897163f5563d60edb77413e9c2))
* **scripts:** upgrade.sh orchestrator — one-command kit + project upgrade ([#169](https://github.com/IamMrCupp/claude-project-kit/issues/169)) ([62c2937](https://github.com/IamMrCupp/claude-project-kit/commit/62c2937cafd4621c718a30c10f41784144af642b))


### Documentation

* surface upgrade.sh as the upgrade front-door ([#169](https://github.com/IamMrCupp/claude-project-kit/issues/169)) ([227a78a](https://github.com/IamMrCupp/claude-project-kit/commit/227a78ae342e3e19cd968afe4a3b4bccc6f112e2))


### Tests

* **scripts:** bats coverage for upgrade.sh orchestrator ([#169](https://github.com/IamMrCupp/claude-project-kit/issues/169)) ([8438ad0](https://github.com/IamMrCupp/claude-project-kit/commit/8438ad0ec6806cb7f41fd5a426e4b1978e88395f))

## [0.33.0](https://github.com/IamMrCupp/claude-project-kit/compare/v0.32.0...v0.33.0) (2026-05-03)


### Features

* **commands:** /research + /plan slash commands (Boris Tane-inspired) ([1792255](https://github.com/IamMrCupp/claude-project-kit/commit/179225530e93ede9d89dbd91c9e03b13b5bde818))
* **commands:** add /research + /plan slash commands ([#166](https://github.com/IamMrCupp/claude-project-kit/issues/166)) ([b9ed16b](https://github.com/IamMrCupp/claude-project-kit/commit/b9ed16bc9e47c918ca97dcaa14013cc07921ec11))


### Documentation

* bump slash-command counts to 9 + future-proof count regex ([#166](https://github.com/IamMrCupp/claude-project-kit/issues/166)) ([7c04530](https://github.com/IamMrCupp/claude-project-kit/commit/7c045303db84a399f31289722c9849be8c2e6f53))
* **prompts:** add Prompt 9 (research) + Prompt 10 (plan) ([#166](https://github.com/IamMrCupp/claude-project-kit/issues/166)) ([9791023](https://github.com/IamMrCupp/claude-project-kit/commit/9791023edc850f862fcab46caf3ab93ff7dc6a63))

## [0.32.0](https://github.com/IamMrCupp/claude-project-kit/compare/v0.31.0...v0.32.0) (2026-05-03)


### Features

* **scripts:** $PWD-inferred paths for sync-memory / sync-templates / rename-workspace ([2411a5d](https://github.com/IamMrCupp/claude-project-kit/commit/2411a5d0a1d200d44eb85257763faaf1753144a3))
* **scripts:** add lib/infer.sh shared inference helpers ([#163](https://github.com/IamMrCupp/claude-project-kit/issues/163)) ([3e43ab3](https://github.com/IamMrCupp/claude-project-kit/commit/3e43ab3370c83083d126703ef58abf75b1373b63))
* **scripts:** rename-workspace.sh infers OLD from $PWD when omitted ([#163](https://github.com/IamMrCupp/claude-project-kit/issues/163)) ([e918f41](https://github.com/IamMrCupp/claude-project-kit/commit/e918f41df23812e6a22fdbe50a3f365c9205910f))
* **scripts:** sync-memory.sh infers memory-dir from $PWD when omitted ([#163](https://github.com/IamMrCupp/claude-project-kit/issues/163)) ([911821a](https://github.com/IamMrCupp/claude-project-kit/commit/911821ad4abff95558250ad80671d9a0cf2cdd64))
* **scripts:** sync-templates.sh infers target from $PWD when omitted ([#163](https://github.com/IamMrCupp/claude-project-kit/issues/163)) ([e400e66](https://github.com/IamMrCupp/claude-project-kit/commit/e400e66bf783bd3a5d8a70ff3df1f1cf69bff585))


### Documentation

* surface $PWD-inferred upgrade flow in SETUP + FEATURES ([#163](https://github.com/IamMrCupp/claude-project-kit/issues/163)) ([2f5d9b1](https://github.com/IamMrCupp/claude-project-kit/commit/2f5d9b17b2b833ddaa9ed58a9d90c8a907ac3c89))


### Tests

* **scripts:** bats coverage for $PWD-inference modes ([#163](https://github.com/IamMrCupp/claude-project-kit/issues/163)) ([b95110a](https://github.com/IamMrCupp/claude-project-kit/commit/b95110a3d3d933602da32163a93bf5efb07fdf08))

## [0.31.0](https://github.com/IamMrCupp/claude-project-kit/compare/v0.30.0...v0.31.0) (2026-05-02)


### Features

* /run-acceptance + PR-body writeback as kit conventions ([b4b345e](https://github.com/IamMrCupp/claude-project-kit/commit/b4b345ec2d9b29a49f2458eed3125a683c9c2536))
* **commands:** /close-phase offers /run-acceptance when ATs pending ([da7299d](https://github.com/IamMrCupp/claude-project-kit/commit/da7299d94a752225e1b7450aa94eb3166c9c2a23))
* **commands:** /run-acceptance attempts automatable ATs and proposes writebacks ([52288cb](https://github.com/IamMrCupp/claude-project-kit/commit/52288cbbcc52a1338423d9fb8e466e29a30bb9c8))


### Documentation

* **conventions:** add acceptance-test execution + PR-body writeback rules ([61f9743](https://github.com/IamMrCupp/claude-project-kit/commit/61f9743c7a1669f4e34037320815be36a0e61500))
* **prompts:** add Prompt 8 mirroring /run-acceptance ([e59ab53](https://github.com/IamMrCupp/claude-project-kit/commit/e59ab534fff614fab4df4cfb57fed41fe65b01d5))
* surface AT execution + writeback in FEATURES.md and SETUP.md ([d0895a9](https://github.com/IamMrCupp/claude-project-kit/commit/d0895a9b10ca98042ba92afe29670009853b4d7d))


### Tests

* bats coverage for /run-acceptance + writeback conventions ([d7fcbac](https://github.com/IamMrCupp/claude-project-kit/commit/d7fcbacd3780181c673f7425bb5c3b4e35bd5769))

## [0.30.0](https://github.com/IamMrCupp/claude-project-kit/compare/v0.29.3...v0.30.0) (2026-05-02)


### Features

* **commands:** /close-phase refuses without acceptance results ([bd6bcb2](https://github.com/IamMrCupp/claude-project-kit/commit/bd6bcb2a823ad1f2e69cd3463bc9adc0650ad88f))
* enforce acceptance tests as a mandatory phase exit criterion ([800b9b5](https://github.com/IamMrCupp/claude-project-kit/commit/800b9b53a30faf1e42561a2508fe13dac26e14dd))


### Documentation

* **conventions:** require acceptance tests at every phase exit ([aa5ecf5](https://github.com/IamMrCupp/claude-project-kit/commit/aa5ecf5e9429c42d4acf9152630777a8ff08e94a))
* surface acceptance-tests rule in FEATURES.md and SETUP.md ([1530d9b](https://github.com/IamMrCupp/claude-project-kit/commit/1530d9bfce6030bfe1e15733969da7d279042df0))
* **templates:** reinforce acceptance-tests section in phase-N-checklist ([07fb6f0](https://github.com/IamMrCupp/claude-project-kit/commit/07fb6f0b90eb00062a8a76dc2420e0f59f3cde2a))


### Tests

* bats coverage for phase-exit acceptance enforcement ([8a0f25f](https://github.com/IamMrCupp/claude-project-kit/commit/8a0f25f27a057c32b5a42603fdb30f6a8c385772))

## [0.29.3](https://github.com/IamMrCupp/claude-project-kit/compare/v0.29.2...v0.29.3) (2026-05-02)


### Refactors

* **examples:** use clearly-fictional tracker key across docs and examples
* **examples:** use clearly-fictional tracker key in multi-repo example

## [0.29.2](https://github.com/IamMrCupp/claude-project-kit/compare/v0.29.1...v0.29.2) (2026-05-02)


### Documentation

* genericize multi-initiative workspace examples
* genericize multi-initiative workspace examples

## [0.29.1](https://github.com/IamMrCupp/claude-project-kit/compare/v0.29.0...v0.29.1) (2026-05-01)


### Documentation

* **readme:** catch up on v0.21-v0.29 helpers + /session-handoff
* **readme:** catch up on v0.21-v0.29 helpers + /session-handoff

## [0.29.0](https://github.com/IamMrCupp/claude-project-kit/compare/v0.28.0...v0.29.0) (2026-05-01)


### Features

* **scripts:** add sync-templates.sh for working-folder + workspace template upgrades
* **scripts:** add sync-templates.sh for working-folder + workspace template upgrades

## [0.28.0](https://github.com/IamMrCupp/claude-project-kit/compare/v0.27.0...v0.28.0) (2026-05-01)


### Features

* **commands:** graceful degradation when invoked outside a kit working folder
* **commands:** graceful degradation when invoked outside a kit working folder

## [0.27.0](https://github.com/IamMrCupp/claude-project-kit/compare/v0.26.0...v0.27.0) (2026-05-01)


### Features

* **scripts:** add rename-workspace.sh helper

## [0.26.0](https://github.com/IamMrCupp/claude-project-kit/compare/v0.25.0...v0.26.0) (2026-05-01)


### Features

* **workspace:** scaffold multi-initiative shape (current initiative + workspace-plan.md)
* **workspace:** scaffold multi-initiative shape (current initiative + workspace-plan.md)

## [0.25.0](https://github.com/IamMrCupp/claude-project-kit/compare/v0.24.0...v0.25.0) (2026-05-01)


### Features

* include Next session prompt in SESSION-LOG entries on close
* include Next session prompt in SESSION-LOG entries on close

## [0.24.0](https://github.com/IamMrCupp/claude-project-kit/compare/v0.23.0...v0.24.0) (2026-05-01)


### Features

* **scripts:** add install-commands.sh for global/per-project slash command + agent install
* **scripts:** add install-commands.sh for global/per-project slash command + agent install

## [0.23.0](https://github.com/IamMrCupp/claude-project-kit/compare/v0.22.0...v0.23.0) (2026-05-01)


### Features

* **bootstrap:** opt-in --trust-working-folder-root flag and interactive prompt
* **bootstrap:** opt-in --trust-working-folder-root flag and interactive prompt


### Tests

* **interactive:** add expect for new trust-root prompt in 5 .exp tests

## [0.22.0](https://github.com/IamMrCupp/claude-project-kit/compare/v0.21.1...v0.22.0) (2026-05-01)


### Features

* durable bootstrap session via SESSION-LOG entry + /session-handoff
* durable bootstrap session via SESSION-LOG entry + /session-handoff

## [0.21.1](https://github.com/IamMrCupp/claude-project-kit/compare/v0.21.0...v0.21.1) (2026-05-01)


### Documentation

* explain .claude/settings.local.json and recommend gitignore

## [0.21.0](https://github.com/IamMrCupp/claude-project-kit/compare/v0.20.3...v0.21.0) (2026-05-01)


### Features

* **scripts:** add sync-memory.sh helper for kit-on-kit memory drift
* **scripts:** add sync-memory.sh helper for kit-on-kit memory drift

## [0.20.3](https://github.com/IamMrCupp/claude-project-kit/compare/v0.20.2...v0.20.3) (2026-04-30)


### Bug Fixes

* **bootstrap:** surface per-repo bootstrap requirement in workspace mode
* **bootstrap:** surface per-repo bootstrap requirement in workspace mode

## [0.20.2](https://github.com/IamMrCupp/claude-project-kit/compare/v0.20.1...v0.20.2) (2026-04-30)


### Documentation

* clarify additionalDirectories setup is per-machine
* clarify additionalDirectories setup is per-machine

## [0.20.1](https://github.com/IamMrCupp/claude-project-kit/compare/v0.20.0...v0.20.1) (2026-04-30)


### Documentation

* document one-time additionalDirectories setup for working folder
* document one-time additionalDirectories setup for working folder

## [0.20.0](https://github.com/IamMrCupp/claude-project-kit/compare/v0.19.2...v0.20.0) (2026-04-30)


### Features

* dogfood the kit's slash commands and agents in .claude/ with sync test
* dogfood the kit's slash commands and agents in .claude/ with sync test

## [0.19.2](https://github.com/IamMrCupp/claude-project-kit/compare/v0.19.1...v0.19.2) (2026-04-30)


### Documentation

* **examples:** add acme-platform multi-repo workspace exemplar (Phase 4 §G)
* **examples:** add acme-platform multi-repo workspace exemplar (Phase 4 G.1)
* reference acme-platform exemplar from README/SETUP/FEATURES (Phase 4 G.2)

## [0.19.1](https://github.com/IamMrCupp/claude-project-kit/compare/v0.19.0...v0.19.1) (2026-04-30)


### Documentation

* **features:** add workspace mode, per-ticket scratchpads, and tracker config sections (Phase 4 F.5)
* **readme:** surface workspace mode and /pull-ticket in features list (Phase 4 F.1)
* **setup:** document pull-ticket flow, prune stale --workspace caveats (Phase 4 F.2)
* surface Phase 4 features (workspace, tickets, /pull-ticket) in README/SETUP/FEATURES

## [0.19.0](https://github.com/IamMrCupp/claude-project-kit/compare/v0.18.0...v0.19.0) (2026-04-30)


### Features

* **pull-ticket:** /pull-ticket command + helper script + Prompt 6 (Phase 4 §E + C.5)
* **pull-ticket:** add /pull-ticket slash command for ticket scratchpads (Phase 4 E.1-E.3, C.5)
* **pull-ticket:** add pull-ticket.sh helper script with bats coverage


### Documentation

* **prompts:** add Prompt 6 for pulling tracker tickets

## [0.18.0](https://github.com/IamMrCupp/claude-project-kit/compare/v0.17.0...v0.18.0) (2026-04-30)


### Features

* **seed-prompt:** handle tracker config, workspace mode, and Terraform signals (Phase 4 C.4)
* **seed-prompt:** tracker config + workspace + Terraform signals (Phase 4 §C.4)

## [0.17.0](https://github.com/IamMrCupp/claude-project-kit/compare/v0.16.3...v0.17.0) (2026-04-30)


### Features

* **bootstrap:** assert kit never creates tracker resources (Phase 4 D.2)
* **bootstrap:** fill tracker config and detect Terraform sibling repos (Phase 4 D.1, D.3, D.5)
* **bootstrap:** tracker config + Terraform detection (Phase 4 §D)

## [0.16.3](https://github.com/IamMrCupp/claude-project-kit/compare/v0.16.2...v0.16.3) (2026-04-30)


### Documentation

* **demo:** add VHS second-session walkthrough — daily-use demo
* **demo:** add VHS second-session walkthrough source ([#87](https://github.com/IamMrCupp/claude-project-kit/issues/87))
* **readme:** embed second-session demo GIF ([#87](https://github.com/IamMrCupp/claude-project-kit/issues/87))

## [0.16.2](https://github.com/IamMrCupp/claude-project-kit/compare/v0.16.1...v0.16.2) (2026-04-29)


### Documentation

* **demo:** add VHS bootstrap walkthrough source
* **demo:** add VHS bootstrap walkthrough source ([#87](https://github.com/IamMrCupp/claude-project-kit/issues/87))
* **readme:** embed bootstrap demo GIF ([#87](https://github.com/IamMrCupp/claude-project-kit/issues/87))

## [0.16.1](https://github.com/IamMrCupp/claude-project-kit/compare/v0.16.0...v0.16.1) (2026-04-29)


### Documentation

* surface the auto-memory short-form session-start prompt

## [0.16.0](https://github.com/IamMrCupp/claude-project-kit/compare/v0.15.0...v0.16.0) (2026-04-28)


### Features

* **memory-templates:** add four behavioral feedback starters
* **memory-templates:** promote four behavioral feedback starters

## [0.15.0](https://github.com/IamMrCupp/claude-project-kit/compare/v0.14.0...v0.15.0) (2026-04-28)


### Features

* **memory-templates:** add feedback_no_push_after_merge starter
* **memory-templates:** add feedback_no_push_after_merge starter

## [0.14.0](https://github.com/IamMrCupp/claude-project-kit/compare/v0.13.1...v0.14.0) (2026-04-28)


### Features

* **bootstrap:** add --workspace flag for multi-repo initiatives ([#61](https://github.com/IamMrCupp/claude-project-kit/issues/61))
* **bootstrap:** add --workspace flag for multi-repo initiatives ([#61](https://github.com/IamMrCupp/claude-project-kit/issues/61))


### Documentation

* **setup:** document --workspace flag and workspace migration


### Tests

* **bootstrap:** cover --workspace flag mechanics

## [0.13.1](https://github.com/IamMrCupp/claude-project-kit/compare/v0.13.0...v0.13.1) (2026-04-28)


### Documentation

* **conventions:** reframe CI principle as 'PR not done until green'

## [0.13.0](https://github.com/IamMrCupp/claude-project-kit/compare/v0.12.1...v0.13.0) (2026-04-28)


### Features

* **templates:** add workspace + ticket templates (Phase 4 §C.1–C.3, [#61](https://github.com/IamMrCupp/claude-project-kit/issues/61))


### Bug Fixes

* **link-check:** ignore {{PLACEHOLDER}} URLs and demote source-only link to code-style

## [0.12.1](https://github.com/IamMrCupp/claude-project-kit/compare/v0.12.0...v0.12.1) (2026-04-28)


### Documentation

* **adr:** add ADR-0001 multi-repo + ticket-driven folder model ([#61](https://github.com/IamMrCupp/claude-project-kit/issues/61))
* **adr:** add ADR-0001 multi-repo + ticket-driven folder model ([#61](https://github.com/IamMrCupp/claude-project-kit/issues/61))
* **adr:** set up docs/adr/ pattern and link from README
* **conventions:** add ticket-driven workflows section ([#61](https://github.com/IamMrCupp/claude-project-kit/issues/61))
* **conventions:** add ticket-driven workflows section ([#61](https://github.com/IamMrCupp/claude-project-kit/issues/61))

## [0.12.0](https://github.com/IamMrCupp/claude-project-kit/compare/v0.11.1...v0.12.0) (2026-04-28)


### Features

* **commands:** add /session-start and /refresh-context slash command starters
* **commands:** add /session-start and /refresh-context slash command starters


### Documentation

* **prompts:** add Prompt 5 for mid-session context refresh

## [0.11.1](https://github.com/IamMrCupp/claude-project-kit/compare/v0.11.0...v0.11.1) (2026-04-28)


### Documentation

* add Features section to README, FEATURES.md reference, and polish bootstrap.sh -h
* add Features section to README, FEATURES.md reference, and polish bootstrap.sh -h

## [0.11.0](https://github.com/IamMrCupp/claude-project-kit/compare/v0.10.1...v0.11.0) (2026-04-25)


### Features

* add .claude/ starter agents and slash commands
* **bootstrap:** copy templates/.claude/ to working folder
* **templates:** add .claude/ starter agents and commands


### Documentation

* document templates/.claude/ in README and SETUP


### Tests

* **bootstrap:** verify .claude/ copy

## [0.10.1](https://github.com/IamMrCupp/claude-project-kit/compare/v0.10.0...v0.10.1) (2026-04-25)


### Documentation

* add SECURITY.md with disclosure policy
* add SECURITY.md with disclosure policy
* **tests:** document expect suite in tests/README.md


### Tests

* interactive-mode coverage with expect-based suite
* **interactive:** add expect-based interactive-mode test suite


### CI

* run expect interactive suite alongside bats

## [0.10.0](https://github.com/IamMrCupp/claude-project-kit/compare/v0.9.1...v0.10.0) (2026-04-25)


### Features

* **bootstrap:** preview actual MEMORY.md index lines in --dry-run
* **bootstrap:** preview actual MEMORY.md index lines in --dry-run
* **prompts:** add Prompt 4 for resuming mid-PR
* **prompts:** add Prompt 4 for resuming mid-PR


### Bug Fixes

* scope MEMORY.md links to files present in snapshot


### Documentation

* add CONTRIBUTING.md
* add issue templates
* add pull request template
* add widget-tracker memory-example snapshot
* add widget-tracker memory-example snapshot
* contributor onboarding (CONTRIBUTING + PR/issue templates)
* flag --tracker other / --ci other follow-up in SETUP
* flag --tracker other / --ci other follow-up in SETUP
* link memory-example from examples README


### Tests

* **bootstrap:** verify --dry-run previews actual index lines

## [0.9.1](https://github.com/IamMrCupp/claude-project-kit/compare/v0.9.0...v0.9.1) (2026-04-24)


### Documentation

* add ko-fi and buymeacoffee funding links
* add ko-fi and buymeacoffee funding links

## [0.9.0](https://github.com/IamMrCupp/claude-project-kit/compare/v0.8.0...v0.9.0) (2026-04-24)


### Features

* **ci:** automate releases with release-please
* **ci:** automate releases with release-please

## 2026-04-24 — Bats test suite for `bootstrap.sh`

**Tag:** [v0.8.0](https://github.com/IamMrCupp/claude-project-kit/releases/tag/v0.8.0)

### Added
- `tests/` — [Bats](https://bats-core.readthedocs.io/) test suite with 61 tests across five files: arg parsing, template + memory seeding, tracker variants, CI variants, `--dry-run` behavior. ([#19](https://github.com/IamMrCupp/claude-project-kit/pull/19))
- `tests/helpers.bash` — sandboxed-setup helpers that override `HOME` and `cwd` per test so auto-memory writes stay isolated. ([#19](https://github.com/IamMrCupp/claude-project-kit/pull/19))
- `tests/README.md` — how to run tests locally, what's covered, how to add new tests. ([#19](https://github.com/IamMrCupp/claude-project-kit/pull/19))
- `.github/workflows/bats.yml` — CI workflow runs the suite on PRs that touch `bootstrap.sh`, `memory-templates/`, `templates/`, or `tests/`. ([#19](https://github.com/IamMrCupp/claude-project-kit/pull/19))

### Fixed
- `bootstrap.sh` — tilde expansion in the `~/path` working-folder argument was broken: bash's tilde expansion in parameter-expansion word context caused `${WORKING_FOLDER#~/}` to try stripping the expanded `$HOME/` prefix (which doesn't match `~/foo`), leaving the literal `~/` in the path. Fix: quote the pattern — `${WORKING_FOLDER#"~/"}`. Caught by the new test suite. ([#19](https://github.com/IamMrCupp/claude-project-kit/pull/19))

### For existing adopters
- No runtime changes apart from the tilde fix (which only improves broken behavior — no scripts should have relied on the buggy output).
- Contributors to the kit itself: run `brew install bats-core` (macOS) or `apt install bats` (Debian/Ubuntu), then `bats tests/` from the kit root.

---

## 2026-04-24 — CI/automation reference memory

**Tag:** [v0.7.0](https://github.com/IamMrCupp/claude-project-kit/releases/tag/v0.7.0)

### Added
- `memory-templates/ci/` — seven reference-memory variants describing how Claude should interact with each CI/automation platform: `github-actions.md`, `gitlab-ci.md`, `jenkins.md`, `circleci.md`, `atlantis.md`, `ansible-cli.md`, `other.md`. Each documents the CLI of record, log-fetching patterns, and conventions specific to that tool (e.g. Atlantis's PR-comment model, Ansible's local operator discipline). ([#18](https://github.com/IamMrCupp/claude-project-kit/pull/18))
- `bootstrap.sh --ci TYPE` — new flag. Seeds `reference_ci.md` into the project's auto-memory from the selected variant and appends an index line to `MEMORY.md`. ([#18](https://github.com/IamMrCupp/claude-project-kit/pull/18))
- Interactive mode now prompts for CI/automation tool after the tracker prompt (default `none`). ([#18](https://github.com/IamMrCupp/claude-project-kit/pull/18))
- `bootstrap.sh --dry-run` output includes the CI reference copy in the plan. ([#18](https://github.com/IamMrCupp/claude-project-kit/pull/18))

### Changed
- This release replaces the originally-planned CI *workflow* starters (ship `test.yml` / `lint.yml` scaffolds). Workflow starters fit too narrow a slice of real CI landscapes (Jenkins, CircleCI, Atlantis, Ansible CLI, etc. all bypassed) and duplicated thin scaffolds adopters already know how to write. Reference-memory variants scale across all of them and teach Claude *how to interact with* the chosen tool instead. ([#18](https://github.com/IamMrCupp/claude-project-kit/pull/18))

### For existing adopters
- No breaking changes. Non-interactive invocations without `--ci` behave identically — no CI reference file is seeded.
- To add CI awareness to an already-bootstrapped project, copy `memory-templates/ci/<TYPE>.md` from the kit into your project's auto-memory folder as `reference_ci.md` and add a line referencing it in your `MEMORY.md`.

---

## 2026-04-23 — End-of-session prompt and `--dry-run`

**Tag:** [v0.6.0](https://github.com/IamMrCupp/claude-project-kit/releases/tag/v0.6.0)

### Added
- `PROMPTS.md` — new **Prompt 3: Wrapping up a session**. Scaffolds the end-of-session hygiene from SETUP.md §7: drafts a `SESSION-LOG.md` entry, suggests `CONTEXT.md` status-line updates, flags checklist items missing PR numbers, and surfaces memory candidates — all in draft form, waiting on confirmation before writing. ([#17](https://github.com/IamMrCupp/claude-project-kit/pull/17))
- `bootstrap.sh --dry-run` — preview every action (paths, placeholder substitutions, tracker memory copy, MEMORY.md index append) and exit without writing anything. Safe to re-run. ([#17](https://github.com/IamMrCupp/claude-project-kit/pull/17))
- `SETUP.md §7` — pointer to Prompt 3 for users who want a scaffolded wrap-up rather than doing the checklist by hand. ([#17](https://github.com/IamMrCupp/claude-project-kit/pull/17))

### For existing adopters
- No breaking changes. `--dry-run` is opt-in; existing invocations behave identically.
- To use Prompt 3, pull the updated `PROMPTS.md` from the kit — the prompt is self-contained and doesn't require any memory or template changes in your project.

---

## 2026-04-23 — More tracker variants

**Tag:** [v0.5.0](https://github.com/IamMrCupp/claude-project-kit/releases/tag/v0.5.0)

### Added
- `memory-templates/trackers/linear.md`, `gitlab.md`, `shortcut.md` — three new reference-memory variants. Complements the existing `github.md` / `jira.md` / `other.md`. ([#16](https://github.com/IamMrCupp/claude-project-kit/pull/16))
- `bootstrap.sh` — `--tracker` now accepts `linear`, `gitlab`, `shortcut` in addition to the existing values. ([#16](https://github.com/IamMrCupp/claude-project-kit/pull/16))
- `bootstrap.sh` — new `--linear-team KEY` flag (analogous to `--jira-project`). Implies `--tracker linear`. Required in non-interactive mode when tracker is Linear. ([#16](https://github.com/IamMrCupp/claude-project-kit/pull/16))
- Interactive mode now lists all seven tracker options and prompts for the team key when Linear is selected. ([#16](https://github.com/IamMrCupp/claude-project-kit/pull/16))

### For existing adopters
- No breaking changes. Existing `--tracker github` / `--tracker jira` invocations behave identically.
- To add tracker awareness to an already-bootstrapped project using one of the new trackers, copy `memory-templates/trackers/<TYPE>.md` from the kit into your project's auto-memory folder as `reference_issue_tracker.md` and fill in placeholders by hand.

---

## 2026-04-23 — Issue tracker awareness

**Tag:** [v0.4.0](https://github.com/IamMrCupp/claude-project-kit/releases/tag/v0.4.0)

### Added
- `bootstrap.sh` — new `--tracker TYPE` (`github` | `jira` | `other` | `none`) and `--jira-project KEY` flags. In interactive mode, bootstrap prompts for tracker type (default: `github`) and, when `jira` is selected, the JIRA project key. Non-interactive invocations without either flag behave as before — no tracker file seeded. ([#15](https://github.com/IamMrCupp/claude-project-kit/pull/15))
- `memory-templates/trackers/` — three reference memory variants (`github.md`, `jira.md`, `other.md`). Bootstrap copies the selected variant into the project's auto-memory as `reference_issue_tracker.md`, substitutes `{{JIRA_PROJECT_KEY}}` when applicable, and appends an index line to `MEMORY.md`. ([#15](https://github.com/IamMrCupp/claude-project-kit/pull/15))

### For existing adopters
- No breaking changes. Non-interactive invocations without the new flags behave identically — no tracker file is seeded, no existing memory file is touched.
- To add tracker awareness to an already-bootstrapped project: copy the appropriate `memory-templates/trackers/<TYPE>.md` from the kit into your project's auto-memory folder as `reference_issue_tracker.md`, fill in `{{JIRA_PROJECT_KEY}}` / `{{PROJECT_NAME}}` / `{{REPO_SLUG}}` by hand, and add a line referencing it in your `MEMORY.md`.

---

## 2026-04-22 — Phase 2: zero manual-fill onboarding

**Tag:** [v0.2.0](https://github.com/IamMrCupp/claude-project-kit/releases/tag/v0.2.0)

### Added
- `templates/SEED-PROMPT.md` — one-shot project bootstrap instruction prompt. Claude deep-reads the target repo, classifies `CONTEXT.md` fields into derivable / `[CLAUDE-INFERRED]` / `[HUMAN-CONFIRM]` buckets, drafts `research.md` from code, summarizes, asks ≤5 targeted questions, and stops for user review. ([#7](https://github.com/IamMrCupp/claude-project-kit/pull/7))
- `bootstrap.sh` — auto-substitutes four memory-template placeholders post-copy: `{{WORKING_FOLDER}}`, `{{REPO_PATH}}`, `{{PROJECT_NAME}}` (default = basename of working folder), `{{REPO_SLUG}}` (opportunistic from `git remote get-url origin`, graceful fallback if no remote). ([#8](https://github.com/IamMrCupp/claude-project-kit/pull/8))
- `bootstrap.sh` — new `--project-name NAME` flag to override the auto-derived project name. ([#8](https://github.com/IamMrCupp/claude-project-kit/pull/8))

### Changed
- `bootstrap.sh` next-steps message leads with the seed-prompt invocation line (working-folder path pre-substituted). ([#7](https://github.com/IamMrCupp/claude-project-kit/pull/7))
- `README.md` + `SETUP.md` — onboarding flow rewritten around the seed-prompt; manual placeholder fill-in demoted to the `Manual alternative` appendix. SETUP.md §4 reframed around memory auto-fill. ([#7](https://github.com/IamMrCupp/claude-project-kit/pull/7), [#8](https://github.com/IamMrCupp/claude-project-kit/pull/8))

### For existing adopters
- **To use the seed-prompt flow:** copy `templates/SEED-PROMPT.md` into your existing working folder:
  ```bash
  cp <kit-dir>/templates/SEED-PROMPT.md <your-working-folder>/
  ```
- **Stale placeholders won't auto-upgrade.** If your `reference_ai_working_folder.md` in auto-memory still has `{{PROJECT_NAME}}` / `{{WORKING_FOLDER}}` / `{{REPO_PATH}}` / `{{REPO_SLUG}}` placeholders from a pre-#8 bootstrap, fill them manually once — future bootstraps on *new* projects will auto-fill them.
- The `--project-name` flag is opt-in and only affects new bootstraps; existing projects' behavior is unchanged.

---

## 2026-04-22 — CONVENTIONS: human-only commit attribution

*Included in [v0.2.0](https://github.com/IamMrCupp/claude-project-kit/releases/tag/v0.2.0).*

### Added
- `CONVENTIONS.md` — explicit rule forbidding AI co-author trailers on commits (complements the existing "single line, signed off, no body" rule). ([#6](https://github.com/IamMrCupp/claude-project-kit/pull/6))
- `memory-templates/feedback_no_ai_coauthor.md` — starter auto-memory file so new projects inherit the rule pre-seeded. ([#6](https://github.com/IamMrCupp/claude-project-kit/pull/6))

### For existing adopters
- Going forward, commit with `git commit -s -m "type(scope): description"` — single line, no HEREDOC body, no `Co-Authored-By` trailer.
- Optionally copy `memory-templates/feedback_no_ai_coauthor.md` into your project's auto-memory to bind the rule at the memory layer.
- **Do not rewrite already-merged history** to remove past trailers — destructive and visible to anyone with a clone.

---

## 2026-04-22 — Phase 1: polish + dogfood fixes

**Tag:** [v0.1.0](https://github.com/IamMrCupp/claude-project-kit/releases/tag/v0.1.0)

### Added
- `bootstrap.sh` — one-command onboarding helper. Creates the working folder, seeds auto-memory, prints next-steps. Flags: `--skip-memory`, `--force`, `-h`/`--help`. ([#2](https://github.com/IamMrCupp/claude-project-kit/pull/2))
- `examples/widget-tracker/` — filled-in reference project (fictional Go CLI, mid-Phase-1 snapshot) with `CONTEXT.md`, `plan.md`, `phase-1-checklist.md`, `SESSION-LOG.md`. ([#3](https://github.com/IamMrCupp/claude-project-kit/pull/3))
- `examples/README.md` — framing doc explaining the "read, don't copy" distinction between `templates/` and `examples/`. ([#3](https://github.com/IamMrCupp/claude-project-kit/pull/3))

### Fixed
- `README.md` memory-templates file list drift — replaced hard-coded `*_example.md` names with pattern-based listing that stays accurate as the starter set grows. ([#1](https://github.com/IamMrCupp/claude-project-kit/pull/1))
- `{{PLATFORM_TARGETS}}` placeholder added to `templates/CONTEXT.md` — was referenced in `SETUP.md` but didn't exist in the template. ([#1](https://github.com/IamMrCupp/claude-project-kit/pull/1))
- `{{REPO_URL}}` listed in `SETUP.md` step 3 fill-in — was in the template but missing from the fill-in instructions. ([#4](https://github.com/IamMrCupp/claude-project-kit/pull/4))
- `SETUP.md` + `README.md` — clarified that the kit works for existing repos, not just greenfield. ([#5](https://github.com/IamMrCupp/claude-project-kit/pull/5))

### For existing adopters
- Copy `bootstrap.sh` from the new kit checkout if you want the scripted flow — your existing manual-setup still works.
- New memory-templates files — copy any that apply into your project's auto-memory.
- Re-read `SETUP.md`: numbering and content shifted (manual alternative is now an appendix; `bootstrap.sh` is the primary flow).

---

## Initial — 2026-04-21 (`13fd99d`)

First commit. Seeded the kit with:

- `README.md`, `SETUP.md`, `CONVENTIONS.md`, `PROMPTS.md`, `LICENSE`
- `templates/` — `CONTEXT.md`, `SESSION-LOG.md`, `plan.md`, `implementation.md`, `phase-N-checklist.md`, `acceptance-test-results.md`, `research.md`
- `memory-templates/` — `MEMORY.md`, `user_role.md`, feedback starters (commit format, docs in sync, merge strategy, PR test plans, PR check-off, push branches, watch CI in background), `project_current.md`, `reference_ai_working_folder.md`
