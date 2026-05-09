#!/bin/bash
set -euo pipefail

# Check that .claude/rules/ and .github/instructions/ mirrors have identical body content.

MIRRORS=(
  ".claude/rules/cicd.md:.github/instructions/cicd.instructions.md"
  ".claude/rules/enforcement.md:.github/instructions/enforcement.instructions.md"
  ".claude/rules/backend/api-design.md:.github/instructions/backend-api-design.instructions.md"
  ".claude/rules/backend/architecture.md:.github/instructions/backend-architecture.instructions.md"
  ".claude/rules/backend/async-patterns.md:.github/instructions/backend-async-patterns.instructions.md"
  ".claude/rules/backend/error-handling.md:.github/instructions/backend-error-handling.instructions.md"
  ".claude/rules/backend/security.md:.github/instructions/backend-security.instructions.md"
  ".claude/rules/backend/testing.md:.github/instructions/backend-testing.instructions.md"
  ".claude/rules/database/infrastructure.md:.github/instructions/database-infrastructure.instructions.md"
  ".claude/rules/database/sql-standards.md:.github/instructions/database-sql-standards.instructions.md"
  ".claude/rules/frontend/conventions.md:.github/instructions/frontend-conventions.instructions.md"
)

DRIFT=0

for pair in "${MIRRORS[@]}"; do
  IFS=':' read -r claude_file copilot_file <<< "$pair"
  if [[ ! -f "$claude_file" || ! -f "$copilot_file" ]]; then
    echo "SKIP: Missing file(s) for pair $pair"
    continue
  fi

  # Extract body (everything after the second --- frontmatter delimiter)
  claude_body=$(awk '/^---$/{if (++count == 2) nextfile} count >= 2' "$claude_file")
  copilot_body=$(awk '/^---$/{if (++count == 2) nextfile} count >= 2' "$copilot_file")

  if [[ "$claude_body" != "$copilot_body" ]]; then
    echo "DRIFT: $claude_file <-> $copilot_file"
    DRIFT=$((DRIFT + 1))
  fi
done

if [[ $DRIFT -gt 0 ]]; then
  echo "FAIL: $DRIFT mirror pair(s) have drifted."
  exit 1
fi

echo "PASS: All mirrors in sync."
