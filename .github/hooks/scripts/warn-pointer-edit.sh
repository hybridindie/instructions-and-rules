#!/bin/bash
# Warns when editing harness pointer files instead of .agents/, and when
# editing .agents/doctrine/ (load-bearing, referenced by many skills).
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
CONTEXT=""
case "$CASE" in
  */.opencode/*|*/.claude/*|*/.github/copilot-instructions.md|*/.github/skills/*)
    WARN=1
    CONTEXT="Reminder: editable content lives in .agents/. The file you are editing is a harness pointer. If you are changing canonical content, edit the corresponding file in .agents/ instead."
    ;;
  */.agents/doctrine/*)
    WARN=1
    CONTEXT="Reminder: .agents/doctrine/ files are load-bearing — multiple skills and rubrics reference them by path, so edits here propagate everywhere. Confirm the change is intended for all callers; if a rule needs to diverge per skill, it does not belong in shared doctrine."
    ;;
  */templates/_shared/doctrine/*)
    WARN=1
    CONTEXT="Reminder: templates/_shared/doctrine/ files are load-bearing — multiple articles and agents reference them by path, and they render into target projects at .claude/rules/doctrine/. Edits here propagate everywhere. Confirm the change is intended for all callers; if a rule needs to diverge per article, it does not belong in shared doctrine."
    ;;
esac

if [ "$WARN" -eq 1 ]; then
  echo "$CONTEXT" >&2
fi
exit 0