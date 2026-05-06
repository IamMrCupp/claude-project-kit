#!/usr/bin/env bats
# Regression check — every kit-coupled slash command and the session-summarizer
# agent must include a "Precheck — is this a kit project?" block instructing
# Claude to bail with a friendly message when invoked outside a kit working
# folder. Closes #82's "graceful degradation" requirement.

load 'helpers'

# Slash commands that read/write kit files (everything except code-reviewer
# is kit-coupled).
KIT_COUPLED_COMMANDS=(
  templates/.claude/commands/session-start.md
  templates/.claude/commands/session-end.md
  templates/.claude/commands/session-handoff.md
  templates/.claude/commands/session-verify.md
  templates/.claude/commands/refresh-context.md
  templates/.claude/commands/close-phase.md
  templates/.claude/commands/pull-ticket.md
  templates/.claude/commands/run-acceptance.md
  templates/.claude/commands/plan.md
  templates/.claude/commands/research.md
)

# Kit-coupled agents (code-reviewer is universal — no kit dependency).
KIT_COUPLED_AGENTS=(
  templates/.claude/agents/session-summarizer.md
)

@test "every kit-coupled slash command includes a Precheck block" {
  for cmd in "${KIT_COUPLED_COMMANDS[@]}"; do
    f="$KIT_ROOT/$cmd"
    [ -f "$f" ]
    if ! grep -q "^## Precheck — is this a kit project?$" "$f"; then
      echo "missing Precheck block: $cmd"
      return 1
    fi
  done
}

@test "every kit-coupled command Precheck mentions reference_ai_working_folder.md" {
  for cmd in "${KIT_COUPLED_COMMANDS[@]}"; do
    f="$KIT_ROOT/$cmd"
    if ! grep -q 'reference_ai_working_folder\.md' "$f"; then
      echo "missing reference_ai_working_folder.md probe in: $cmd"
      return 1
    fi
  done
}

@test "every kit-coupled command Precheck has a friendly bail message" {
  for cmd in "${KIT_COUPLED_COMMANDS[@]}"; do
    f="$KIT_ROOT/$cmd"
    if ! grep -q 'No kit working folder found for this project' "$f"; then
      echo "missing bail message in: $cmd"
      return 1
    fi
  done
}

# Regression guard for #187 / #190 — the precheck must instruct the model to
# resolve the auto-memory pointer path via Bash ($HOME + $PWD-derived key)
# and then Read the resolved absolute path. Earlier wordings either:
#   - "Look up `reference_ai_working_folder.md` in this project's auto-memory"
#     was ambiguous — models read it as "check the session reminder", which
#     only contains MEMORY.md, and bailed on properly bootstrapped projects.
#   - "Use the `Read` tool to load `~/.claude/projects/...`" — the Read tool
#     does not expand `~/`, so passing the literal `~/...` string fails with
#     "file not found" and the precheck bails the same way.
@test "every kit-coupled command Precheck resolves absolute path via Bash before Read" {
  for cmd in "${KIT_COUPLED_COMMANDS[@]}"; do
    f="$KIT_ROOT/$cmd"
    # Must include the $HOME-based echo command for path resolution.
    if ! grep -q 'echo "\$HOME/\.claude/projects/' "$f"; then
      echo "missing \$HOME-based path resolution Bash command in: $cmd"
      return 1
    fi
    # Must explicitly direct the model to NOT pass ~/ to Read.
    if ! grep -q 'do not pass `~/` to Read' "$f"; then
      echo "missing 'do not pass ~/ to Read' guidance in: $cmd"
      return 1
    fi
    # Old ambiguous wording must be gone.
    if grep -q "Look up \`reference_ai_working_folder\.md\` in this project's auto-memory" "$f"; then
      echo "regression — original ambiguous wording still present in: $cmd"
      return 1
    fi
    # Old tilde-passing wording must also be gone.
    if grep -q 'Use the `Read` tool to load `~/\.claude/projects/' "$f"; then
      echo "regression — tilde-path wording still present in: $cmd"
      return 1
    fi
  done
}

@test "kit-coupled agents include a Precheck block" {
  for agent in "${KIT_COUPLED_AGENTS[@]}"; do
    f="$KIT_ROOT/$agent"
    [ -f "$f" ]
    if ! grep -q "^## Precheck — is this a kit project?$" "$f"; then
      echo "missing Precheck block: $agent"
      return 1
    fi
  done
}

@test "kit-coupled agents Precheck resolves absolute path via Bash before Read" {
  for agent in "${KIT_COUPLED_AGENTS[@]}"; do
    f="$KIT_ROOT/$agent"
    if ! grep -q 'echo "\$HOME/\.claude/projects/' "$f"; then
      echo "missing \$HOME-based path resolution Bash command in: $agent"
      return 1
    fi
    if grep -q 'Use the `Read` tool to load `~/\.claude/projects/' "$f"; then
      echo "regression — tilde-path wording still present in: $agent"
      return 1
    fi
  done
}

# Regression guard for #210 — precheck must walk up from worktree to parent
# repo before sanitizing. Sanitizing $PWD directly produces a key that
# includes the worktree subdir name, but bootstrap only ever seeded auto-
# memory at the parent repo's path. Claude Code's runtime walks up; the
# precheck must too. Use `git rev-parse --git-common-dir` (returns the
# parent repo's .git for both regular and worktree sessions) → `dirname`
# → sanitize. Falls back to $PWD outside a git repo.
@test "every kit-coupled command Precheck is worktree-aware (uses git rev-parse)" {
  for cmd in "${KIT_COUPLED_COMMANDS[@]}"; do
    f="$KIT_ROOT/$cmd"
    if ! grep -q 'git rev-parse --path-format=absolute --git-common-dir' "$f"; then
      echo "missing worktree-aware git rev-parse in: $cmd"
      return 1
    fi
    # Must sanitize REPO_ROOT (worktree-resolved), not raw $PWD.
    if ! grep -q 'echo "\$REPO_ROOT" | sed' "$f"; then
      echo "must sanitize \$REPO_ROOT (not raw \$PWD): $cmd"
      return 1
    fi
    # The old raw-PWD sanitization must be gone.
    if grep -q 'echo "\$PWD" | sed' "$f"; then
      echo "regression — old raw-\$PWD sanitization still present in: $cmd"
      return 1
    fi
  done
}

@test "every kit-coupled agent Precheck is worktree-aware (uses git rev-parse)" {
  for agent in "${KIT_COUPLED_AGENTS[@]}"; do
    f="$KIT_ROOT/$agent"
    if ! grep -q 'git rev-parse --path-format=absolute --git-common-dir' "$f"; then
      echo "missing worktree-aware git rev-parse in: $agent"
      return 1
    fi
    if ! grep -q 'echo "\$REPO_ROOT" | sed' "$f"; then
      echo "must sanitize \$REPO_ROOT (not raw \$PWD): $agent"
      return 1
    fi
    if grep -q 'echo "\$PWD" | sed' "$f"; then
      echo "regression — old raw-\$PWD sanitization still present in: $agent"
      return 1
    fi
  done
}

@test "code-reviewer agent does NOT include the kit Precheck (universal agent)" {
  f="$KIT_ROOT/templates/.claude/agents/code-reviewer.md"
  [ -f "$f" ]
  ! grep -q "Precheck — is this a kit project" "$f"
}
