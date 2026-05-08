#!/usr/bin/env bash
# check-no-skipped-tests.sh
#
# Enforces the "Suite Health" rule from .claude/rules/backend/testing.md
# and .claude/rules/frontend/conventions.md:
#
#   Zero unconditional skips may be checked in.
#
# Scans backend pytest files and frontend Vitest specs for the set of
# patterns that always indicate an unconditional skip (or an expected
# failure that is really a dormant bug). Exits non-zero on any match and
# prints the offending file:line for each violation.
#
# Patterns that ARE allowed and therefore not flagged:
#   - @pytest.mark.skipif(<bool>, reason=...)           (env-gated)
#   - pytest.skip(...) inside an `if <precondition>:` guard (env-gated)
#   - Playwright runtime test.skip(...) inside an if() branch
#
# These legitimate patterns are allowed by narrowing the scan targets:
#   backend: only flag @pytest.mark.skip and @pytest.mark.xfail decorators
#   frontend: only flag skip/todo on the unit-test path; Playwright specs
#             under tests/e2e/** are exempt.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

red()   { printf '\033[0;31m%s\033[0m\n' "$*"; }
green() { printf '\033[0;32m%s\033[0m\n' "$*"; }
yellow() { printf '\033[0;33m%s\033[0m\n' "$*"; }

violations=0
report() {
  red "FAIL: $1"
  shift
  for line in "$@"; do
    printf '  %s\n' "$line"
  done
  violations=$((violations + 1))
}

# Pick a grep implementation that supports -n/-r/-l. ripgrep preferred.
if command -v rg >/dev/null 2>&1; then
  SEARCH_BACKEND='rg --line-number --no-heading'
  SEARCH_FRONTEND='rg --line-number --no-heading'
else
  SEARCH_BACKEND='grep -rn --include=*.py'
  SEARCH_FRONTEND='grep -rn'
fi

# ---------------------------------------------------------------------------
# Backend (pytest)
# ---------------------------------------------------------------------------
#
# @pytest.mark.skip        → unconditional decorator (forbidden)
# @pytest.mark.xfail       → dormant failure (forbidden)
#
# @pytest.mark.skipif(...) is allowed and not matched by the patterns below
# (word boundary on `skip\b`).

if [ -d backend/tests ]; then
  backend_matches=$(
    $SEARCH_BACKEND -e '@pytest\.mark\.skip\b' backend/tests 2>/dev/null | \
      grep -v '@pytest\.mark\.skipif' || true
  )
  if [ -n "$backend_matches" ]; then
    report 'backend: @pytest.mark.skip decorators are forbidden (use skipif, or delete the test)' $backend_matches
  fi

  backend_xfail=$(
    $SEARCH_BACKEND -e '@pytest\.mark\.xfail' backend/tests 2>/dev/null || true
  )
  if [ -n "$backend_xfail" ]; then
    report 'backend: @pytest.mark.xfail is forbidden (fix the code or delete the test)' $backend_xfail
  fi
fi

# ---------------------------------------------------------------------------
# Frontend (Vitest — unit/integration specs only)
# ---------------------------------------------------------------------------
#
# Playwright specs in tests/e2e/ are exempt: they need runtime test.skip()
# inside conditional branches for device-aware tests.

if [ -d frontend ]; then
  # Collect candidate Vitest files, excluding Playwright directories.
  vitest_files=$(
    find frontend \
      \( -path 'frontend/node_modules' -o -path 'frontend/tests/e2e' -o -path 'frontend/dist' -o -path 'frontend/build' \) -prune \
      -o -type f \( -name '*.test.ts' -o -name '*.test.tsx' -o -name '*.spec.ts' -o -name '*.spec.tsx' \) -print
  )

  if [ -n "$vitest_files" ]; then
    # Patterns: it.skip, test.skip, describe.skip, .todo, xit, xdescribe
    skip_matches=$(
      # shellcheck disable=SC2086
      grep -n -E '\b(it|test|describe)\.(skip|todo)\b|\b(xit|xdescribe)\b' $vitest_files 2>/dev/null || true
    )
    if [ -n "$skip_matches" ]; then
      report 'frontend: Vitest skip/todo/xit/xdescribe are forbidden (delete obsolete tests, rewrite drifted ones)' $skip_matches
    fi
  fi
fi

# ---------------------------------------------------------------------------
# Result
# ---------------------------------------------------------------------------

if [ $violations -gt 0 ]; then
  printf '\n'
  red "check-no-skipped-tests: $violations violation category/ies found."
  yellow 'See .claude/rules/backend/testing.md and .claude/rules/frontend/conventions.md'
  yellow 'for the full rule text and the legitimate alternatives (skipif, etc.).'
  exit 1
fi

green 'check-no-skipped-tests: no forbidden skip/xfail patterns found.'
exit 0
