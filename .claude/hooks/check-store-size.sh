#!/usr/bin/env bash
# PostToolUse: Warn when a Zustand store file exceeds the 300-line constitutional limit.
# Split into sub-stores with immer middleware per .claude/rules/frontend/conventions.md.

file="${TOOL_INPUT_FILE_PATH:-${TOOL_INPUT_file_path:-}}"

case "$file" in
  */frontend/src/stores/*.ts) ;;
  *) exit 0 ;;
esac

[ -f "$file" ] || exit 0

lines=$(wc -l < "$file" 2>/dev/null || echo 0)

if [ "$lines" -gt 300 ]; then
    echo "STORE-SIZE: $file is $lines lines — exceeds the 300-line constitutional limit. Split into sub-stores with immer middleware. See analytics.ts for the facade pattern. Ref: .claude/rules/frontend/conventions.md"
fi

exit 0
