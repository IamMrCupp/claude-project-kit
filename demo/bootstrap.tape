# demo/bootstrap.tape — claude-project-kit bootstrap walkthrough
#
# Render with:  vhs demo/bootstrap.tape   (run from the kit checkout root)
# Outputs:      demo/bootstrap.gif
#
# Tracks issue #87, Phase 1.

Output demo/bootstrap.gif

Set Shell "bash"
Set FontSize 18
Set Width 1200
Set Height 900
Set TypingSpeed 50ms

# ---- Hidden setup -----------------------------------------------------------
# Capture the kit checkout root, scrub any prior demo state, and spin up a
# throwaway target repo at /tmp/widget-tracker. PS1 is normalised so the
# demo doesn't show the maintainer's daily-driver prompt.
Hide
Type "export KIT=$(pwd) && rm -rf /tmp/widget-tracker $HOME/Documents/Claude/Projects/widget-tracker $HOME/.claude/projects/-tmp-widget-tracker"
Enter
Sleep 200ms
Type "mkdir -p /tmp/widget-tracker && cd /tmp/widget-tracker && git init -q && touch README.md && git add . && git -c user.email=demo@local -c user.name=demo commit -qm 'init' && git remote add origin git@github.com:demo/widget-tracker.git"
Enter
Sleep 200ms
Type "PS1='$ ' && clear"
Enter
Show
# -----------------------------------------------------------------------------

# Show we're sitting in a clean target repo with nothing Claude-related yet.
Type "pwd && ls -A"
Enter
Sleep 1500ms

# Run the bootstrap script.
Type "$KIT/bootstrap.sh"
Enter
Sleep 2500ms

# Working folder path — accept the suggested default.
Enter
Sleep 800ms

# Project name — accept default ("widget-tracker").
Enter
Sleep 800ms

# Seed auto-memory — yes.
Type "y"
Enter
Sleep 800ms

# Issue tracker — accept the github default.
Enter
Sleep 800ms

# CI / automation tool.
Type "github-actions"
Enter
Sleep 800ms

# Confirm the plan.
Type "y"
Enter
Sleep 6000ms

# What got created in the working folder:
Type "ls -1 ~/Documents/Claude/Projects/widget-tracker/"
Enter
Sleep 3000ms

# What got seeded in auto-memory:
Type "ls -1 ~/.claude/projects/-tmp-widget-tracker/memory/"
Enter
Sleep 4000ms

# ---- Hidden cleanup ---------------------------------------------------------
# Nuke everything the demo created so re-rendering stays reproducible and
# the maintainer's real Claude state isn't polluted.
Hide
Type "rm -rf /tmp/widget-tracker $HOME/Documents/Claude/Projects/widget-tracker $HOME/.claude/projects/-tmp-widget-tracker"
Enter
Show
