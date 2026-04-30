# demo/second-session.tape — claude-project-kit steady-state usage demo
#
# Render with:  vhs demo/second-session.tape   (run from the kit checkout root)
# Outputs:      demo/second-session.gif
#
# Tracks issue #87, Phase 2.
#
# Setup assumption: ~/Code/recipe-card-maker is already bootstrapped with the
# kit. This tape does NOT bootstrap — it expects:
#   - ~/Documents/Claude/Projects/recipe-card-maker/ populated with CONTEXT.md,
#     SESSION-LOG.md, plan.md, etc.
#   - ~/.claude/projects/-Users-aaroncupp-Code-recipe-card-maker/memory/ with
#     reference_ai_working_folder.md pointing at the working folder above.
#
# The demo shows the steady-state daily-use prompt: one line, Claude reads
# the persistent context via auto-memory and returns a grounding summary.

Output demo/second-session.gif

Set Shell "bash"
Set FontSize 18
Set Width 1200
Set Height 900
Set TypingSpeed 40ms

# ---- Hidden setup -----------------------------------------------------------
# Unset CLAUDECODE so `claude` launches cleanly (the binary refuses to run
# nested inside another Claude Code session, which matters when this tape is
# rendered from a Claude Code agent terminal). No-op when rendering locally.
Hide
Type "unset CLAUDECODE && PS1='$ ' && cd ~/Code/recipe-card-maker && clear"
Enter
Show
# -----------------------------------------------------------------------------

# Show what's in the working folder — establishes the docs Claude has access to.
Type "ls -1 ~/Documents/Claude/Projects/recipe-card-maker/"
Enter
Sleep 3000ms

# Open Claude Code. --add-dir pre-approves the working folder so Claude
# doesn't hit a permission prompt mid-render when reading CONTEXT.md /
# SESSION-LOG.md (those live outside the repo's cwd).
Type "claude --add-dir ~/Documents/Claude/Projects/recipe-card-maker/"
Enter
Sleep 5000ms

# The standard daily-use prompt. Auto-memory points Claude at the working
# folder so one line fully grounds the session.
Type "Load context and give me a 3-bullet summary of where we are."
Enter
Sleep 30000ms

# ---- Hidden cleanup ---------------------------------------------------------
Hide
Ctrl+C
Sleep 500ms
Ctrl+C
Show
