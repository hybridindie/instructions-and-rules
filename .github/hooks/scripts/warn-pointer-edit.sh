#!/bin/bash
# Warns when editing harness pointer files instead of .agents/.
# Editable content should live in .agents/. Pointer files in .opencode/,
# .claude/, and .github/ should stay thin.
#
# Input arrives on stdin as JSON with tool_input.file_path.
# Exit 0 with no output = no decision; normal flow continues.
# To surface a warning, print a message to stderr.

INPUT=$(cat)
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""')

[ -z "$FILE" ] && exit 0

CASE=$(echo "$FILE" | tr 'A-Z' 'a-z')
WARN=0
case "$CASE" in
  */.opencode/*|*/.claude/*|*/.github/copilot-instructions.md|*/.github/skills/*)
    WARN=1
    ;;
esac

if [ "$WARN" -eq 1 ]; then
  echo "Reminder: editable content lives in .agents/. The file you are editing is a harness pointer. If you are changing canonical content, edit the corresponding file in .agents/ instead." >&2
fi
exit 0