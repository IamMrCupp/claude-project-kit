# Changelog

All notable changes to `claude-project-kit`. Format loosely follows [Keep a Changelog](https://keepachangelog.com/). Tagged releases are published on [GitHub Releases](https://github.com/IamMrCupp/claude-project-kit/releases); entries below include version tags where applicable.

See [Upgrading an existing project](SETUP.md#upgrading-an-existing-project) for the general migration pattern. Each entry below has a **For existing adopters** section with specifics for that release.

---

## [0.28.0](https://github.com/IamMrCupp/claude-project-kit/compare/v0.27.0...v0.28.0) (2026-05-01)


### Features

* **commands:** graceful degradation when invoked outside a kit working folder ([f69173a](https://github.com/IamMrCupp/claude-project-kit/commit/f69173a822de25a22fcc71d30ecf6aa52978bbfc))
* **commands:** graceful degradation when invoked outside a kit working folder ([e6404ec](https://github.com/IamMrCupp/claude-project-kit/commit/e6404eccc3e851b9aabf0074509b2c6d664c1de0))

## [0.27.0](https://github.com/IamMrCupp/claude-project-kit/compare/v0.26.0...v0.27.0) (2026-05-01)


### Features

* **scripts:** add rename-workspace.sh helper ([910e611](https://github.com/IamMrCupp/claude-project-kit/commit/910e611a87726fd3a6a76610eedd087bea1ab95d))

## [0.26.0](https://github.com/IamMrCupp/claude-project-kit/compare/v0.25.0...v0.26.0) (2026-05-01)


### Features

* **workspace:** scaffold multi-initiative shape (current initiative + workspace-plan.md) ([de4ac4a](https://github.com/IamMrCupp/claude-project-kit/commit/de4ac4ae12a788a35c4ce280508549e3c9ac4389))
* **workspace:** scaffold multi-initiative shape (current initiative + workspace-plan.md) ([48567f2](https://github.com/IamMrCupp/claude-project-kit/commit/48567f249a889eca76e5bd89c57227ef325bed9e))

## [0.25.0](https://github.com/IamMrCupp/claude-project-kit/compare/v0.24.0...v0.25.0) (2026-05-01)


### Features

* include Next session prompt in SESSION-LOG entries on close ([e4678b7](https://github.com/IamMrCupp/claude-project-kit/commit/e4678b768e602c4d7c21fbbc0489e7d4a5acf1e3))
* include Next session prompt in SESSION-LOG entries on close ([02435d7](https://github.com/IamMrCupp/claude-project-kit/commit/02435d74c027fa5a6bdb2ffa4eb564d5034e6478))

## [0.24.0](https://github.com/IamMrCupp/claude-project-kit/compare/v0.23.0...v0.24.0) (2026-05-01)


### Features

* **scripts:** add install-commands.sh for global/per-project slash command + agent install ([e1efaa3](https://github.com/IamMrCupp/claude-project-kit/commit/e1efaa32e422421517a28fb716234633e5d48140))
* **scripts:** add install-commands.sh for global/per-project slash command + agent install ([3a89829](https://github.com/IamMrCupp/claude-project-kit/commit/3a898295c7b4b693e810ef65196b182e61de6d99))

## [0.23.0](https://github.com/IamMrCupp/claude-project-kit/compare/v0.22.0...v0.23.0) (2026-05-01)


### Features

* **bootstrap:** opt-in --trust-working-folder-root flag and interactive prompt ([45f7867](https://github.com/IamMrCupp/claude-project-kit/commit/45f78679b227f14b178fe208c3ef0dc53c360c25))
* **bootstrap:** opt-in --trust-working-folder-root flag and interactive prompt ([cd6dc4d](https://github.com/IamMrCupp/claude-project-kit/commit/cd6dc4d7b09f47250c1e7370fceab1a67f176460))


### Tests

* **interactive:** add expect for new trust-root prompt in 5 .exp tests ([c82bb8a](https://github.com/IamMrCupp/claude-project-kit/commit/c82bb8ac08603903d6ae916b618eb943b769e34e))

## [0.22.0](https://github.com/IamMrCupp/claude-project-kit/compare/v0.21.1...v0.22.0) (2026-05-01)


### Features

* durable bootstrap session via SESSION-LOG entry + /session-handoff ([9e36b16](https://github.com/IamMrCupp/claude-project-kit/commit/9e36b16bbc1ab788907a9f912bdcd381c6120670))
* durable bootstrap session via SESSION-LOG entry + /session-handoff ([118a289](https://github.com/IamMrCupp/claude-project-kit/commit/118a28937fe7e81492a0651901d5727211fa0693))

## [0.21.1](https://github.com/IamMrCupp/claude-project-kit/compare/v0.21.0...v0.21.1) (2026-05-01)


### Documentation

* explain .claude/settings.local.json and recommend gitignore ([e9a5b25](https://github.com/IamMrCupp/claude-project-kit/commit/e9a5b259427b35ba97aaf6ff9b31db0e341f2d9a))

## [0.21.0](https://github.com/IamMrCupp/claude-project-kit/compare/v0.20.3...v0.21.0) (2026-05-01)


### Features

* **scripts:** add sync-memory.sh helper for kit-on-kit memory drift ([00a8923](https://github.com/IamMrCupp/claude-project-kit/commit/00a8923ebd6601ceda018888deb0af7340c18e44))
* **scripts:** add sync-memory.sh helper for kit-on-kit memory drift ([9110d82](https://github.com/IamMrCupp/claude-project-kit/commit/9110d8266efff0f0482eff5dbeaf1f33a0de668a))

## [0.20.3](https://github.com/IamMrCupp/claude-project-kit/compare/v0.20.2...v0.20.3) (2026-04-30)


### Bug Fixes

* **bootstrap:** surface per-repo bootstrap requirement in workspace mode ([d3b6431](https://github.com/IamMrCupp/claude-project-kit/commit/d3b6431e285d44d848212630a37b83a7be00412c))
* **bootstrap:** surface per-repo bootstrap requirement in workspace mode ([fa5cf8a](https://github.com/IamMrCupp/claude-project-kit/commit/fa5cf8a785bba05f21883cabc0b1d4e5ba7b9a36))

## [0.20.2](https://github.com/IamMrCupp/claude-project-kit/compare/v0.20.1...v0.20.2) (2026-04-30)


### Documentation

* clarify additionalDirectories setup is per-machine ([71b25e5](https://github.com/IamMrCupp/claude-project-kit/commit/71b25e511bd96f73b2400d916b68c1cd307a367e))
* clarify additionalDirectories setup is per-machine ([20c6959](https://github.com/IamMrCupp/claude-project-kit/commit/20c6959b4e687768281567305e43283138874910))

## [0.20.1](https://github.com/IamMrCupp/claude-project-kit/compare/v0.20.0...v0.20.1) (2026-04-30)


### Documentation

* document one-time additionalDirectories setup for working folder ([c568536](https://github.com/IamMrCupp/claude-project-kit/commit/c5685362b67631ad2e083456149f0ad540a46aae))
* document one-time additionalDirectories setup for working folder ([329346f](https://github.com/IamMrCupp/claude-project-kit/commit/329346f78fde89b42f885bf2a3829ba9d66d9c10))

## [0.20.0](https://github.com/IamMrCupp/claude-project-kit/compare/v0.19.2...v0.20.0) (2026-04-30)


### Features

* dogfood the kit's slash commands and agents in .claude/ with sync test ([fed3268](https://github.com/IamMrCupp/claude-project-kit/commit/fed3268fca9bbe986b4e345d432a3571455c6479))
* dogfood the kit's slash commands and agents in .claude/ with sync test ([ace5b53](https://github.com/IamMrCupp/claude-project-kit/commit/ace5b537ffe5feea6eccaacb231301ebc688568a))

## [0.19.2](https://github.com/IamMrCupp/claude-project-kit/compare/v0.19.1...v0.19.2) (2026-04-30)


### Documentation

* **examples:** add acme-platform multi-repo workspace exemplar (Phase 4 §G) ([8810cd8](https://github.com/IamMrCupp/claude-project-kit/commit/8810cd8ed584cf56fcc35a7513373ad8c0e4596f))
* **examples:** add acme-platform multi-repo workspace exemplar (Phase 4 G.1) ([3c56d91](https://github.com/IamMrCupp/claude-project-kit/commit/3c56d915aa10dd0187060bb9763e35f93e2b6ec3))
* reference acme-platform exemplar from README/SETUP/FEATURES (Phase 4 G.2) ([4437f92](https://github.com/IamMrCupp/claude-project-kit/commit/4437f9276c169f21444f92ca5f15c04d17945366))

## [0.19.1](https://github.com/IamMrCupp/claude-project-kit/compare/v0.19.0...v0.19.1) (2026-04-30)


### Documentation

* **features:** add workspace mode, per-ticket scratchpads, and tracker config sections (Phase 4 F.5) ([99c9f66](https://github.com/IamMrCupp/claude-project-kit/commit/99c9f666dc4d339076b16b02ba2ec18d0bbcb9ae))
* **readme:** surface workspace mode and /pull-ticket in features list (Phase 4 F.1) ([45b7c34](https://github.com/IamMrCupp/claude-project-kit/commit/45b7c345b556b7b71c157374d40ce0b0916ef299))
* **setup:** document pull-ticket flow, prune stale --workspace caveats (Phase 4 F.2) ([9bd4402](https://github.com/IamMrCupp/claude-project-kit/commit/9bd44023faeeb8c05a1ee8df6dfc1a59a9762925))
* surface Phase 4 features (workspace, tickets, /pull-ticket) in README/SETUP/FEATURES ([bfea4a8](https://github.com/IamMrCupp/claude-project-kit/commit/bfea4a8b511f06ef55dcb7622bbeb73bf6fa874c))

## [0.19.0](https://github.com/IamMrCupp/claude-project-kit/compare/v0.18.0...v0.19.0) (2026-04-30)


### Features

* **pull-ticket:** /pull-ticket command + helper script + Prompt 6 (Phase 4 §E + C.5) ([ef069d7](https://github.com/IamMrCupp/claude-project-kit/commit/ef069d77ad845df1b587bc3690d88aff3d068dc4))
* **pull-ticket:** add /pull-ticket slash command for ticket scratchpads (Phase 4 E.1-E.3, C.5) ([2b902e5](https://github.com/IamMrCupp/claude-project-kit/commit/2b902e5d7c66067db6227731cb29983e932792f0))
* **pull-ticket:** add pull-ticket.sh helper script with bats coverage ([247f7a1](https://github.com/IamMrCupp/claude-project-kit/commit/247f7a1cf31e84748cf6b2b2424882f1f1099805))


### Documentation

* **prompts:** add Prompt 6 for pulling tracker tickets ([3319ff7](https://github.com/IamMrCupp/claude-project-kit/commit/3319ff76ad90ab4f81a35fb84d9b8a9c584dd407))

## [0.18.0](https://github.com/IamMrCupp/claude-project-kit/compare/v0.17.0...v0.18.0) (2026-04-30)


### Features

* **seed-prompt:** handle tracker config, workspace mode, and Terraform signals (Phase 4 C.4) ([4819eb0](https://github.com/IamMrCupp/claude-project-kit/commit/4819eb0be06afd3ba5c70d26ae5e45cf172c4577))
* **seed-prompt:** tracker config + workspace + Terraform signals (Phase 4 §C.4) ([9decc72](https://github.com/IamMrCupp/claude-project-kit/commit/9decc7285bd4716d39182f9d95bbfc33d8ad7494))

## [0.17.0](https://github.com/IamMrCupp/claude-project-kit/compare/v0.16.3...v0.17.0) (2026-04-30)


### Features

* **bootstrap:** assert kit never creates tracker resources (Phase 4 D.2) ([fe6f8c8](https://github.com/IamMrCupp/claude-project-kit/commit/fe6f8c86ab9d9f55d97e3c0da9075eff72205190))
* **bootstrap:** fill tracker config and detect Terraform sibling repos (Phase 4 D.1, D.3, D.5) ([fe76d04](https://github.com/IamMrCupp/claude-project-kit/commit/fe76d04be6bd80c72aea5ea95ebcff661e91380b))
* **bootstrap:** tracker config + Terraform detection (Phase 4 §D) ([374ebc4](https://github.com/IamMrCupp/claude-project-kit/commit/374ebc4857f86d6bf76e67c75c643896de358662))

## [0.16.3](https://github.com/IamMrCupp/claude-project-kit/compare/v0.16.2...v0.16.3) (2026-04-30)


### Documentation

* **demo:** add VHS second-session walkthrough — daily-use demo ([1030296](https://github.com/IamMrCupp/claude-project-kit/commit/1030296c087c5f0bbeb2a6c77a38e74cc9fd4166))
* **demo:** add VHS second-session walkthrough source ([#87](https://github.com/IamMrCupp/claude-project-kit/issues/87)) ([b4d9e4f](https://github.com/IamMrCupp/claude-project-kit/commit/b4d9e4f67652ea57a8f81093224d968149da4cce))
* **readme:** embed second-session demo GIF ([#87](https://github.com/IamMrCupp/claude-project-kit/issues/87)) ([5dc5f0a](https://github.com/IamMrCupp/claude-project-kit/commit/5dc5f0a7134865aba0060c604f7ada2e7fe354f5))

## [0.16.2](https://github.com/IamMrCupp/claude-project-kit/compare/v0.16.1...v0.16.2) (2026-04-29)


### Documentation

* **demo:** add VHS bootstrap walkthrough source ([23a81fe](https://github.com/IamMrCupp/claude-project-kit/commit/23a81fe7243e664afc1225c46159a90e477de370))
* **demo:** add VHS bootstrap walkthrough source ([#87](https://github.com/IamMrCupp/claude-project-kit/issues/87)) ([ceeb051](https://github.com/IamMrCupp/claude-project-kit/commit/ceeb05130a45e64c5c4a6b49b27f53dd78cc7af7))
* **readme:** embed bootstrap demo GIF ([#87](https://github.com/IamMrCupp/claude-project-kit/issues/87)) ([54083f2](https://github.com/IamMrCupp/claude-project-kit/commit/54083f226031cdb29209f583088ed1374a6759f5))

## [0.16.1](https://github.com/IamMrCupp/claude-project-kit/compare/v0.16.0...v0.16.1) (2026-04-29)


### Documentation

* surface the auto-memory short-form session-start prompt ([c11130a](https://github.com/IamMrCupp/claude-project-kit/commit/c11130aecb7bb8b274a699356256429dca48d60f))

## [0.16.0](https://github.com/IamMrCupp/claude-project-kit/compare/v0.15.0...v0.16.0) (2026-04-28)


### Features

* **memory-templates:** add four behavioral feedback starters ([d7f8d11](https://github.com/IamMrCupp/claude-project-kit/commit/d7f8d1150204ed15019599e2e7273b8cbc53f261))
* **memory-templates:** promote four behavioral feedback starters ([f42975b](https://github.com/IamMrCupp/claude-project-kit/commit/f42975b9bea16c3167a27b50c2196ecc64c5be95))

## [0.15.0](https://github.com/IamMrCupp/claude-project-kit/compare/v0.14.0...v0.15.0) (2026-04-28)


### Features

* **memory-templates:** add feedback_no_push_after_merge starter ([dc9a2e9](https://github.com/IamMrCupp/claude-project-kit/commit/dc9a2e96d122f8a8f9976d3faf0a7f12664fc5b6))
* **memory-templates:** add feedback_no_push_after_merge starter ([bf646b8](https://github.com/IamMrCupp/claude-project-kit/commit/bf646b8b4461dbea769febe485bc9415c2140ff1))

## [0.14.0](https://github.com/IamMrCupp/claude-project-kit/compare/v0.13.1...v0.14.0) (2026-04-28)


### Features

* **bootstrap:** add --workspace flag for multi-repo initiatives ([#61](https://github.com/IamMrCupp/claude-project-kit/issues/61)) ([24c4463](https://github.com/IamMrCupp/claude-project-kit/commit/24c44636465f3a39b8f4a2f90c9441eea47b14af))
* **bootstrap:** add --workspace flag for multi-repo initiatives ([#61](https://github.com/IamMrCupp/claude-project-kit/issues/61)) ([b6c7fb6](https://github.com/IamMrCupp/claude-project-kit/commit/b6c7fb66c4baff4b0fdb6b021e2b6ae2fc2f2780))


### Documentation

* **setup:** document --workspace flag and workspace migration ([55a263d](https://github.com/IamMrCupp/claude-project-kit/commit/55a263d91b3779419141988b076de13d44062d04))


### Tests

* **bootstrap:** cover --workspace flag mechanics ([ba075f7](https://github.com/IamMrCupp/claude-project-kit/commit/ba075f7a49a35cb3e63a1514ffc2656a6b72c28b))

## [0.13.1](https://github.com/IamMrCupp/claude-project-kit/compare/v0.13.0...v0.13.1) (2026-04-28)


### Documentation

* **conventions:** reframe CI principle as 'PR not done until green' ([dfd2d9d](https://github.com/IamMrCupp/claude-project-kit/commit/dfd2d9d525c15f5c8e69f60a015c34299a5eb10f))

## [0.13.0](https://github.com/IamMrCupp/claude-project-kit/compare/v0.12.1...v0.13.0) (2026-04-28)


### Features

* **templates:** add workspace + ticket templates (Phase 4 §C.1–C.3, [#61](https://github.com/IamMrCupp/claude-project-kit/issues/61)) ([2a15e84](https://github.com/IamMrCupp/claude-project-kit/commit/2a15e84db7f746eace3f99c42365adaa9a872ab3))


### Bug Fixes

* **link-check:** ignore {{PLACEHOLDER}} URLs and demote source-only link to code-style ([9f3cc11](https://github.com/IamMrCupp/claude-project-kit/commit/9f3cc11b77d89421419c255e02a728d38682d5e5))

## [0.12.1](https://github.com/IamMrCupp/claude-project-kit/compare/v0.12.0...v0.12.1) (2026-04-28)


### Documentation

* **adr:** add ADR-0001 multi-repo + ticket-driven folder model ([#61](https://github.com/IamMrCupp/claude-project-kit/issues/61)) ([7be788c](https://github.com/IamMrCupp/claude-project-kit/commit/7be788c312fbfcac9a1bab107d176cd8e2deb24b))
* **adr:** add ADR-0001 multi-repo + ticket-driven folder model ([#61](https://github.com/IamMrCupp/claude-project-kit/issues/61)) ([0147bca](https://github.com/IamMrCupp/claude-project-kit/commit/0147bca4db0de1443358b1dd86c94807a51be967))
* **adr:** set up docs/adr/ pattern and link from README ([efa94b3](https://github.com/IamMrCupp/claude-project-kit/commit/efa94b3ad6c340ae397a7c234617b15e512f2fa4))
* **conventions:** add ticket-driven workflows section ([#61](https://github.com/IamMrCupp/claude-project-kit/issues/61)) ([9cc941f](https://github.com/IamMrCupp/claude-project-kit/commit/9cc941fc7b0e458bed7a1dfb97226307cca7fd51))
* **conventions:** add ticket-driven workflows section ([#61](https://github.com/IamMrCupp/claude-project-kit/issues/61)) ([4920a33](https://github.com/IamMrCupp/claude-project-kit/commit/4920a33b9eca96ec6b2a1604268c6c7935755a86))

## [0.12.0](https://github.com/IamMrCupp/claude-project-kit/compare/v0.11.1...v0.12.0) (2026-04-28)


### Features

* **commands:** add /session-start and /refresh-context slash command starters ([b323622](https://github.com/IamMrCupp/claude-project-kit/commit/b3236229a6079554093d732935753453d4724685))
* **commands:** add /session-start and /refresh-context slash command starters ([e1ff6ca](https://github.com/IamMrCupp/claude-project-kit/commit/e1ff6ca434f9b5123f64a3705788f4426f0148bd))


### Documentation

* **prompts:** add Prompt 5 for mid-session context refresh ([6b63656](https://github.com/IamMrCupp/claude-project-kit/commit/6b63656bfbd6884beeeb3f3439c44c25ca1dd699))

## [0.11.1](https://github.com/IamMrCupp/claude-project-kit/compare/v0.11.0...v0.11.1) (2026-04-28)


### Documentation

* add Features section to README, FEATURES.md reference, and polish bootstrap.sh -h ([a89e277](https://github.com/IamMrCupp/claude-project-kit/commit/a89e2774f806939976f8619d1ba28821cd9c117a))
* add Features section to README, FEATURES.md reference, and polish bootstrap.sh -h ([8bc1a59](https://github.com/IamMrCupp/claude-project-kit/commit/8bc1a592123d62d7e752b0de393e76963815d24a))

## [0.11.0](https://github.com/IamMrCupp/claude-project-kit/compare/v0.10.1...v0.11.0) (2026-04-25)


### Features

* add .claude/ starter agents and slash commands ([f355f03](https://github.com/IamMrCupp/claude-project-kit/commit/f355f0315f6f70dcf196beed8210a9600b832386))
* **bootstrap:** copy templates/.claude/ to working folder ([7319e9f](https://github.com/IamMrCupp/claude-project-kit/commit/7319e9fe3424c0ad5d3724b71b0155a442d2157f))
* **templates:** add .claude/ starter agents and commands ([b12908e](https://github.com/IamMrCupp/claude-project-kit/commit/b12908ec29a42aaa4848d25621b8431a6aacfdc2))


### Documentation

* document templates/.claude/ in README and SETUP ([4f60028](https://github.com/IamMrCupp/claude-project-kit/commit/4f60028ad85d71c3f717d4e683477d11e9a6f6c3))


### Tests

* **bootstrap:** verify .claude/ copy ([2100fb5](https://github.com/IamMrCupp/claude-project-kit/commit/2100fb52fd15569c671cd6f21d4f243b816c9dd8))

## [0.10.1](https://github.com/IamMrCupp/claude-project-kit/compare/v0.10.0...v0.10.1) (2026-04-25)


### Documentation

* add SECURITY.md with disclosure policy ([6123e40](https://github.com/IamMrCupp/claude-project-kit/commit/6123e40f5dbf802485280496eec307bf315ffadf))
* add SECURITY.md with disclosure policy ([9cc195d](https://github.com/IamMrCupp/claude-project-kit/commit/9cc195d635dfe9fc0ce4b32fe181cac5e1a7f4a2))
* **tests:** document expect suite in tests/README.md ([41942c8](https://github.com/IamMrCupp/claude-project-kit/commit/41942c84e9e7e1bcb1b248f823e13201d24fc195))


### Tests

* interactive-mode coverage with expect-based suite ([9362f59](https://github.com/IamMrCupp/claude-project-kit/commit/9362f593e59c1bdac68638901b799ac2317feba9))
* **interactive:** add expect-based interactive-mode test suite ([ec26823](https://github.com/IamMrCupp/claude-project-kit/commit/ec26823cc46d0947f829c91fbcad8ff6ebc59c65))


### CI

* run expect interactive suite alongside bats ([3d1e4b9](https://github.com/IamMrCupp/claude-project-kit/commit/3d1e4b9953ad855ed214452f4dc510331a0bad2a))

## [0.10.0](https://github.com/IamMrCupp/claude-project-kit/compare/v0.9.1...v0.10.0) (2026-04-25)


### Features

* **bootstrap:** preview actual MEMORY.md index lines in --dry-run ([727cb7f](https://github.com/IamMrCupp/claude-project-kit/commit/727cb7fc145a2a6138d0524a06267b32d06bf1c6))
* **bootstrap:** preview actual MEMORY.md index lines in --dry-run ([a54d618](https://github.com/IamMrCupp/claude-project-kit/commit/a54d6187b11726c8938ed01efe5ac395a1500838))
* **prompts:** add Prompt 4 for resuming mid-PR ([9f2aabe](https://github.com/IamMrCupp/claude-project-kit/commit/9f2aabe7db79ed594a9dca42f64bb8602b3e11f1))
* **prompts:** add Prompt 4 for resuming mid-PR ([592e2a1](https://github.com/IamMrCupp/claude-project-kit/commit/592e2a14043e86ad0b3457b38fc5c4b11d237d6b))


### Bug Fixes

* scope MEMORY.md links to files present in snapshot ([7cae2e3](https://github.com/IamMrCupp/claude-project-kit/commit/7cae2e3cca4d15b4f817159c141fd53cc1d25c05))


### Documentation

* add CONTRIBUTING.md ([0c2a713](https://github.com/IamMrCupp/claude-project-kit/commit/0c2a713e612af3a6b0f79a3a1005e6f5ee91bfdb))
* add issue templates ([a5a2a14](https://github.com/IamMrCupp/claude-project-kit/commit/a5a2a1454dc8ca83d9f5f0e2408b0c7f52a3d09a))
* add pull request template ([878551d](https://github.com/IamMrCupp/claude-project-kit/commit/878551d780c78ffa0058a2c57408d8386a8341a0))
* add widget-tracker memory-example snapshot ([af69fe7](https://github.com/IamMrCupp/claude-project-kit/commit/af69fe7825555d053ea89f9bb5eac60e7f27a264))
* add widget-tracker memory-example snapshot ([215101d](https://github.com/IamMrCupp/claude-project-kit/commit/215101dd91fec444a0564d78c6512978acc6f759))
* contributor onboarding (CONTRIBUTING + PR/issue templates) ([3597003](https://github.com/IamMrCupp/claude-project-kit/commit/3597003936509a988d308a4ddbe8bf8235c9c6f3))
* flag --tracker other / --ci other follow-up in SETUP ([2b5e963](https://github.com/IamMrCupp/claude-project-kit/commit/2b5e96315d8e494dbf6ec8e0da6060f49889048b))
* flag --tracker other / --ci other follow-up in SETUP ([aa09381](https://github.com/IamMrCupp/claude-project-kit/commit/aa0938174ab5df27f8634fd613865c0ae99279f0))
* link memory-example from examples README ([2176734](https://github.com/IamMrCupp/claude-project-kit/commit/2176734bfc6ac6d234907d95df3a2112b0800908))


### Tests

* **bootstrap:** verify --dry-run previews actual index lines ([df4a35c](https://github.com/IamMrCupp/claude-project-kit/commit/df4a35cd43853565783d1b968a0e60cf65cd37a3))

## [0.9.1](https://github.com/IamMrCupp/claude-project-kit/compare/v0.9.0...v0.9.1) (2026-04-24)


### Documentation

* add ko-fi and buymeacoffee funding links ([bc8b7c4](https://github.com/IamMrCupp/claude-project-kit/commit/bc8b7c41989d790b65d04b9669b77ba138471432))
* add ko-fi and buymeacoffee funding links ([be15028](https://github.com/IamMrCupp/claude-project-kit/commit/be15028d250bad6498b81c31cf35257ece8944b4))

## [0.9.0](https://github.com/IamMrCupp/claude-project-kit/compare/v0.8.0...v0.9.0) (2026-04-24)


### Features

* **ci:** automate releases with release-please ([244f976](https://github.com/IamMrCupp/claude-project-kit/commit/244f97640163031b4f4429bf78ce04025f29daef))
* **ci:** automate releases with release-please ([64f0b1a](https://github.com/IamMrCupp/claude-project-kit/commit/64f0b1a72b42cd49dc49c6ea77aaddc7747d0658))

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
