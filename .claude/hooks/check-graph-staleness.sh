#!/usr/bin/env bash
# PreToolUse(Bash) — soft warning when `git push` is about to ship
# graph-relevant code changes without a corresponding `graphify-out/`
# rebuild. Per .claude/rules/workflow.md and CLAUDE.md, the knowledge
# graphs at frontend/src/graphify-out/ and backend/src/graphify-out/
# are authoritative for structural recommendations only when they're
# current. The hook only nudges; it does not block (exit 0 always).
#
# Override (silently exit 0):
#   - Any unpushed commit message contains [no-graph-rebuild]

set -u

cmd="${TOOL_INPUT_command:-}"

# Only act on `git push`. Match prefix and any leading `cd … && git push`.
case "$cmd" in
  *"git push"*) ;;
  *) exit 0 ;;
esac

# Determine the diff range to inspect: unpushed commits ahead of upstream.
# If no upstream tracked, fall back to ahead-of-main.
range=$(git -C "$(pwd)" rev-parse --abbrev-ref --symbolic-full-name "@{u}" 2>/dev/null)
if [ -n "$range" ]; then
  diff_range="${range}..HEAD"
else
  # No upstream — fall back to main..HEAD (and exit silently if main doesn't exist either)
  if git -C "$(pwd)" rev-parse --verify main >/dev/null 2>&1; then
    diff_range="main..HEAD"
  else
    exit 0
  fi
fi

# If diff range is empty (nothing to push), silent.
if ! git -C "$(pwd)" diff --name-only "$diff_range" >/dev/null 2>&1; then
  exit 0
fi
unpushed_count=$(git -C "$(pwd)" rev-list --count "$diff_range" 2>/dev/null || echo 0)
if [ "${unpushed_count:-0}" = "0" ]; then
  exit 0
fi

changed=$(git -C "$(pwd)" diff --name-only "$diff_range" 2>/dev/null)
if [ -z "$changed" ]; then
  exit 0
fi

# Override — any commit message in the range contains [no-graph-rebuild].
commit_msgs=$(git -C "$(pwd)" log --format=%B "$diff_range" 2>/dev/null)
case "$commit_msgs" in
  *"[no-graph-rebuild]"*) exit 0 ;;
esac

# Graph-relevant path patterns (frontend + backend).
graph_relevant=$(echo "$changed" | grep -E '^(frontend/src/(services|stores|contracts|hooks|types/contracts)/|backend/src/libs/|backend/app/)' || true)

if [ -z "$graph_relevant" ]; then
  exit 0
fi

# Did the corresponding graphify-out/ get touched in the same range?
graph_artifacts=$(echo "$changed" | grep -E '^(frontend/src/graphify-out/|backend/src/graphify-out/)' || true)

if [ -n "$graph_artifacts" ]; then
  exit 0
fi

# Emit soft warning. exit 0 — hook does not block.
cat <<EOF
GRAPH-STALENESS: This push includes graph-relevant changes but no
graphify-out/ rebuild is in the diff. Consider running
\`/graphify frontend/src --update\` (or backend/src) so the knowledge
graph stays in sync with main. Reference: .claude/rules/workflow.md.

Files that triggered this warning:
$(echo "$graph_relevant" | sed 's/^/  - /')

Override: include [no-graph-rebuild] in any unpushed commit message
for trivial refactors or intentional skips.
EOF

exit 0
