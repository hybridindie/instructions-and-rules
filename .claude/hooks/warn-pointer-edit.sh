#!/bin/bash
# Warns (not blocks) when editing harness pointer files instead of .agents/.
# Editable content should live in .agents/. Pointer files in .opencode/,
# .claude/, and .github/ should stay thin.
#
# Input arrives on stdin as JSON with tool_input.file_path.
# Exit 0 with no output = no decision; normal flow continues.
# To surface a system reminder to Claude, print JSON with hookSpecificOutput.
INPUT=$(cat)
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""')

# Skip if no file path (e.g. Write to a new file may still have one)
[ -z "$FILE" ] && exit 0

# Check if the file is in a harness pointer directory
CASE=$(echo "$FILE" | tr 'A-Z' 'a-z')
WARN=0
case "$CASE" in
  */.opencode/*|*/.claude/*|*/.github/copilot-instructions.md|*/.github/skills/*)
    WARN=1
    ;;
esac

if [ "$WARN" -eq 1 ]; then
  jq -n '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      additionalContext: "Reminder: editable content lives in .agents/. The file you are editing is a harness pointer. If you are changing canonical content, edit the corresponding file in .agents/ instead. If you are intentionally updating the pointer, proceed."
    }
  }'
fi
exit 0