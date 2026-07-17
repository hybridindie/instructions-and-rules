#!/bin/bash
# Logs when instruction files (CLAUDE.md, rules) are loaded into context.
# Input arrives on stdin as JSON with a file_path field.
INPUT=$(cat)
FILE=$(echo "$INPUT" | jq -r '.file_path // "unknown"')
REASON=$(echo "$INPUT" | jq -r '.load_reason // "unknown"')
LOG="${CLAUDE_PROJECT_DIR:-.}/.claude/hooks/instructions-loaded.log"
echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) reason=${REASON} file=${FILE}" >> "$LOG"
exit 0