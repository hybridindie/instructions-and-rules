#!/usr/bin/env bash
# PostToolUse: Warn when a backend service file uses bare datetime.now() without Clock injection.
# Article II requires all time dependencies to be injectable.

file="${TOOL_INPUT_FILE_PATH:-${TOOL_INPUT_file_path:-}}"

case "$file" in
  */backend/src/libs/*.py|*/backend/app/*.py) ;;
  *) exit 0 ;;
esac

[ -f "$file" ] || exit 0

if grep -qE 'datetime\.now\(' "$file" 2>/dev/null; then
    count=$(grep -cE 'datetime\.now\(' "$file" 2>/dev/null || echo 0)
    if grep -qE '(self\._clock|: Clock|clock: Clock|FakeClock)' "$file" 2>/dev/null; then
        echo "CLOCK-INJECTION: $file has $count bare datetime.now() call(s) alongside Clock injection — ensure all time reads go through self._clock.now(). Run /clock-injection-audit for a full scan."
    else
        echo "CLOCK-INJECTION: $file has $count bare datetime.now() call(s) with no Clock injection (Article II / Article V). Inject \`clock: Clock | None = None\` and replace with self._clock.now(). Run /clock-injection-audit for a full scan."
    fi
fi

exit 0
