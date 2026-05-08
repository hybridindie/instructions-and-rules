#!/usr/bin/env bash
# check-primitive-drift.sh
#
# Compares .claude/rules/ files against their .github/instructions/ mirrors.
# Strips YAML frontmatter from both before comparing — frontmatter intentionally
# differs (Claude uses `paths:`, Copilot uses `applyTo:`) but body content MUST
# be identical.
#
# Dual-purpose:
#   SessionStart — runs all pair checks unconditionally.
#   PostToolUse(Write|Edit) — only runs if TOOL_INPUT_FILE_PATH is in a
#     .claude/rules/ or .github/instructions/ directory; silently exits otherwise.
#
# Exits 0 always (warning only, never blocks).

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

yellow() { printf '\033[0;33m%s\033[0m\n' "$*"; }
green()  { printf '\033[0;32m%s\033[0m\n' "$*"; }

# ---------------------------------------------------------------------------
# PostToolUse guard: skip unless a rule or instruction file was just edited.
# ---------------------------------------------------------------------------
file="${TOOL_INPUT_FILE_PATH:-${TOOL_INPUT_file_path:-}}"
if [ -n "$file" ]; then
  case "$file" in
    */.claude/rules/*|*/.github/instructions/*) ;;
    *) exit 0 ;;
  esac
fi

# ---------------------------------------------------------------------------
# Single source of truth for the frontmatter-stripping awk program.
# Used both by strip_frontmatter() (the actual diff) and the printed
# "Quick diff" command shown to the user — keeps them in lockstep.
# ---------------------------------------------------------------------------
STRIP_FM_AWK='NR==1 && /^---/ { in_fm=1; next } in_fm && /^---/ { in_fm=0; next } in_fm { next } { print }'

strip_frontmatter() {
  awk "$STRIP_FM_AWK" "$1"
}

drifted=0

check_pair() {
  local claude_file="$1" copilot_file="$2"
  [ -f "$claude_file" ] || return 0
  [ -f "$copilot_file" ] || return 0
  if ! diff -q \
      <(strip_frontmatter "$claude_file") \
      <(strip_frontmatter "$copilot_file") \
      >/dev/null 2>&1; then
    yellow "PRIMITIVE-DRIFT: body content differs between:"
    yellow "  Claude:  $claude_file"
    yellow "  Copilot: $copilot_file"
    yellow "  Fix: update both files to match. Quick diff:"
    yellow "    diff <(awk '${STRIP_FM_AWK}' $claude_file) \\"
    yellow "         <(awk '${STRIP_FM_AWK}' $copilot_file)"
    drifted=$((drifted + 1))
  fi
}

# ---------------------------------------------------------------------------
# Mirror pairs — .claude/rules/ <-> .github/instructions/
# workflow.md has no Copilot mirror; it is intentionally excluded.
# ---------------------------------------------------------------------------
check_pair ".claude/rules/cicd.md"                    ".github/instructions/cicd.instructions.md"
check_pair ".claude/rules/enforcement.md"             ".github/instructions/enforcement.instructions.md"
check_pair ".claude/rules/backend/api-design.md"      ".github/instructions/backend-api-design.instructions.md"
check_pair ".claude/rules/backend/architecture.md"    ".github/instructions/backend-architecture.instructions.md"
check_pair ".claude/rules/backend/async-patterns.md"  ".github/instructions/backend-async-patterns.instructions.md"
check_pair ".claude/rules/backend/error-handling.md"  ".github/instructions/backend-error-handling.instructions.md"
check_pair ".claude/rules/backend/security.md"        ".github/instructions/backend-security.instructions.md"
check_pair ".claude/rules/backend/testing.md"         ".github/instructions/backend-testing.instructions.md"
check_pair ".claude/rules/database/infrastructure.md" ".github/instructions/database-infrastructure.instructions.md"
check_pair ".claude/rules/database/sql-standards.md"  ".github/instructions/database-sql-standards.instructions.md"
check_pair ".claude/rules/frontend/conventions.md"    ".github/instructions/frontend-conventions.instructions.md"

if [ "$drifted" -eq 0 ]; then
  green "PRIMITIVE-DRIFT: all rule/instruction mirrors are in sync."
fi

exit 0
