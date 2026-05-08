#!/usr/bin/env bash
# PostToolUse(Bash) — runs after every Bash command. When the command is
# `gh pr create`, emits a reminder telling Claude to schedule a follow-up
# review of the PR's comments via the /schedule skill (per
# .claude/rules/workflow.md Step 6).
#
# Override (silently exit 0):
#   - Env var:    INFLUENCERSYNC_SKIP_AUTO_REVIEW=1 gh pr create ...
#   - Title flag: gh pr create --title "[no-review] ..."
#
# The hook only nudges; only Claude can invoke /schedule. The reminder
# carries enough context that the skill call is one step away.

set -u

cmd="${TOOL_INPUT_command:-}"

# Match `gh pr create` anywhere in the command line. Also accept `gh  pr  create`
# with multiple spaces between tokens.
case "$cmd" in
  *"gh pr create"*|*"gh  pr  create"*) ;;
  *) exit 0 ;;
esac

# Override 1 — explicit env var bypass.
if [ "${INFLUENCERSYNC_SKIP_AUTO_REVIEW:-0}" = "1" ]; then
  exit 0
fi

# Override 2 — `[no-review]` token in the command (typically inside --title).
case "$cmd" in
  *"[no-review]"*) exit 0 ;;
esac

cat <<'EOF'
PR-AUTO-REVIEW: A `gh pr create` just ran. Per .claude/rules/workflow.md
Step 6, every PR review comment must be addressed (code change OR written
reply). Schedule a follow-up review now using the /schedule skill so you
do not forget.

Suggested cadence:
  - +30 min — catches Copilot bot review and CI-triggered feedback
  - +6 h    — catches human reviewers in different time zones

The scheduled routine should:
  1. Fetch comments via `gh api repos/<owner>/<repo>/pulls/<N>/comments`
  2. For each comment, either land a code change OR open a follow-up
     issue and reply with the link (workflow.md Step 6)
  3. Reply to every comment so silence never reads as agreement

Override: set INFLUENCERSYNC_SKIP_AUTO_REVIEW=1 or include [no-review] in
the PR title for low-risk / experimental PRs.
EOF

exit 0
