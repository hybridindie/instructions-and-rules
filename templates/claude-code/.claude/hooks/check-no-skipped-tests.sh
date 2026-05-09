#!/bin/bash
set -euo pipefail

# Check for forbidden skip/xfail patterns in the test suite.
# Exits non-zero if any unconditional skip is found.

ERRORS=0

echo "=== Checking Backend (pytest) ==="
# Forbidden: @pytest.mark.skip, @pytest.mark.xfail, pytest.skip() at top level
if grep -rn 'pytest\.mark\.skip\b' {{BACKEND_PATH}}/tests/ 2>/dev/null | grep -v 'skipif' ; then
  echo "ERROR: Unconditional pytest.skip found in backend tests"
  ERRORS=$((ERRORS + 1))
fi
if grep -rn 'pytest\.mark\.xfail' {{BACKEND_PATH}}/tests/ 2>/dev/null ; then
  echo "ERROR: xfail found in backend tests"
  ERRORS=$((ERRORS + 1))
fi

echo "=== Checking Frontend (Vitest) ==="
# Forbidden: it.skip, test.skip, describe.skip, .todo, xit, xdescribe
PATTERNS='it\.skip|test\.skip|describe\.skip|\.todo\(|xit\(|xdescribe\('
if grep -rnE "$PATTERNS" {{FRONTEND_PATH}}/src/ {{FRONTEND_PATH}}/tests/ 2>/dev/null ; then
  echo "ERROR: Unconditional skip/todo found in frontend tests"
  ERRORS=$((ERRORS + 1))
fi

if [[ $ERRORS -gt 0 ]]; then
  echo "FAIL: $ERRORS skip/xfail violation(s) found."
  exit 1
fi

echo "PASS: No forbidden skip patterns found."
