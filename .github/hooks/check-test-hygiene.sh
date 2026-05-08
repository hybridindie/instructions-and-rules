#!/usr/bin/env bash
# check-test-hygiene.sh
#
# Scans test files for four recurring latent-bug patterns. Each one has
# bitten the suite at least once and slipped past `check-no-skipped-tests.sh`:
#
# 1. Wall-clock rot: hardcoded ISO date strings in test bodies that imply
#    "recent" or "current". They pass today and break tomorrow. Examples:
#      - tier.test.ts pinned grace_expires_at: '2026-04-01T00:00:00Z'
#      - analytics.test.ts used '2026-02-17T00:00:00Z' as "recent"
#    Dynamic dates (`Date.now() - N * day`, `vi.useFakeTimers()`,
#    `freezegun`, injected `Clock` providers) are the fix.
#
# 1b. Legacy `{"detail": ...}` error-envelope assertions: the platform's
#     API has used the DomainError envelope `{"error": {"code": ..., "message": ...}}`
#     for some time (.claude/rules/backend/error-handling.md, Article IV).
#     Tests pinned to the legacy `"detail"` shape pass alone if a fallback
#     handler still emits it under specific conditions, and fail under
#     cross-tier loads when the canonical handler runs. Surfaced #949.
#
# 1c. Cross-tier-unsafe table-wide truncate in autouse conftest fixtures:
#     `tests/integration/campaign_manager/conftest.py` had clean_campaign_manager
#     running `delete().neq(...)` on `users` / `creator_profiles` / `agencies`
#     after every test. Even with the integration tier pinned to a single
#     xdist worker (#946), the autouse truncate races with contract / e2e
#     tests on parallel workers. Fixed in #949 by gating the truncate on a
#     `_foreign_tier_present(session)` check.
#
# 2. AsyncMock on sync httpx response methods: `httpx.Response.json()` is
#    synchronous. AsyncMock turns it into a coroutine, which the real code
#    path can't await, producing silent failures. Example:
#      - test_complete_oauth_flow rewritten to use respx + httpx.Response
#        directly instead of AsyncMock().
#
# None of these patterns has a 100% false-positive-free regex — this script
# produces WARNINGS, not blocking errors. The intent is to surface them in
# PR review so humans can evaluate. Blocking enforcement belongs on the
# skip/failure gate, not here.
#
# Exit codes:
#   0 — no warnings (or all warnings are grandfathered / in fixtures)
#   2 — warnings found (informational; CI should report but not fail)
#
# Use --strict to turn warnings into blocking errors (CI mode).

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

STRICT=0
for arg in "$@"; do
  case "$arg" in
    --strict) STRICT=1 ;;
    -h|--help)
      sed -n '2,30p' "$0"
      exit 0
      ;;
  esac
done

red()    { printf '\033[0;31m%s\033[0m\n' "$*"; }
yellow() { printf '\033[0;33m%s\033[0m\n' "$*"; }
green()  { printf '\033[0;32m%s\033[0m\n' "$*"; }

warnings=0

warn_header_printed=0
print_warn_header() {
  if [ "$warn_header_printed" -eq 0 ]; then
    yellow "=== test-hygiene WARNINGS (non-blocking — see comment in script) ==="
    warn_header_printed=1
  fi
}

# ---------------------------------------------------------------------------
# 1. Wall-clock rot in test files
# ---------------------------------------------------------------------------
#
# Pattern: quoted ISO date (YYYY-MM-DD or YYYY-MM-DDTHH:...) inside a test
# file. We exclude files under snapshot/, fixtures/, and __fixtures__/ where
# pinned dates are the whole point.

wall_clock_hits=""
if [ -d backend/tests ] || [ -d frontend ]; then
  # Collect test files
  py_tests=$(
    find backend/tests -type f -name '*.py' 2>/dev/null || true
  )
  ts_tests=$(
    find frontend -type f \
      \( -path 'frontend/node_modules' -o -path 'frontend/tests/e2e' -o -path 'frontend/dist' \) -prune \
      -o -type f \( -name '*.test.ts' -o -name '*.test.tsx' -o -name '*.spec.ts' -o -name '*.spec.tsx' \) -print \
      2>/dev/null || true
  )

  # grep the pattern; drop lines under fixtures/, __fixtures__/, snapshot/.
  # shellcheck disable=SC2086
  all_hits=$(
    grep -nE "['\"]20[0-9][0-9]-[01][0-9]-[0-3][0-9]" $py_tests $ts_tests 2>/dev/null \
      | grep -vE '/fixtures/|/__fixtures__/|/snapshot/|/__snapshots__/' \
      | grep -vE 'expires_at|created_at.*fixture|#\s*fixture|//\s*fixture|evaluated_at' \
      || true
  )

  if [ -n "$all_hits" ]; then
    # Filter further: ignore lines that already look dynamic
    # (`Date.now()`, `new Date(`, `datetime.now(`, `timedelta`).
    wall_clock_hits=$(
      echo "$all_hits" | grep -vE 'Date\.now\(|new Date\(|datetime\.now\(|timedelta\(|fromisoformat|toISOString\(|\.now\(UTC\)' || true
    )
  fi
fi

if [ -n "$wall_clock_hits" ]; then
  print_warn_header
  yellow "[wall-clock rot] hardcoded ISO date in test file body:"
  yellow "  Fix: use dynamic dates (\`Date.now() - N * 86400000\`, \`datetime.now(UTC) - timedelta(days=N)\`)"
  yellow "       or \`vi.useFakeTimers()\` / \`freezegun\` / inject a \`Clock\` provider."
  yellow "  Note: error-message round-trips and fixtures are false positives — use judgement."
  # Cap display at 50 lines without triggering SIGPIPE under pipefail.
  total=$(printf '%s\n' "$wall_clock_hits" | grep -c . || true)
  display=$(printf '%s\n' "$wall_clock_hits" | awk 'NR<=50')
  printf '%s\n' "$display" | while IFS= read -r line; do
    [ -n "$line" ] && printf '    %s\n' "$line"
  done
  if [ "$total" -gt 50 ]; then
    yellow "  ... and $((total - 50)) more."
  fi
  warnings=$((warnings + 1))
fi

# ---------------------------------------------------------------------------
# 1b. Legacy `{"detail": ...}` error envelope assertions
# ---------------------------------------------------------------------------
#
# Pattern: a Python test asserts `"detail" in error_data` after a 4xx/5xx
# API response. The platform's API has used the DomainError envelope
# `{"error": {"code": ..., "message": ...}}` for some time
# (.claude/rules/backend/error-handling.md, Article IV). Tests pinned to
# the legacy `"detail"` shape may pass alone if a fallback handler still
# emits it under specific conditions, but they fail under cross-tier
# loads when the canonical handler runs and produces the modern envelope.
# Real example: tests/e2e/test_user_authentication_journey.py — both
# duplicate-email and bad-credentials tests asserted on `"detail"` and
# silently failed once the auth route's handler produced `"error"` 100%
# of the time. (#949)

legacy_envelope_hits=""
if [ -d backend/tests ]; then
  legacy_envelope_hits=$(
    grep -rnE 'assert\s+"detail"\s+in\s+\w+' backend/tests --include='*.py' 2>/dev/null \
      | grep -vE '#\s*hygiene:\s*envelope-ok' \
      || true
  )
fi

if [ -n "$legacy_envelope_hits" ]; then
  print_warn_header
  yellow "[legacy envelope] \`assert \"detail\" in error_data\` — API uses \`{\"error\": {...}}\`:"
  yellow "  See .claude/rules/backend/error-handling.md (Article IV). Fix:"
  yellow "    assert \"error\" in body"
  yellow "    assert body[\"error\"].get(\"code\") == \"<error_code>\""
  yellow "  Add \`# hygiene: envelope-ok\` if the test really is checking a legacy"
  yellow "  fallback path or a third-party API that returns \`{\"detail\": ...}\`."
  total=$(printf '%s\n' "$legacy_envelope_hits" | grep -c . || true)
  display=$(printf '%s\n' "$legacy_envelope_hits" | awk 'NR<=30')
  printf '%s\n' "$display" | while IFS= read -r line; do
    [ -n "$line" ] && printf '    %s\n' "$line"
  done
  if [ "$total" -gt 30 ]; then
    yellow "  ... and $((total - 30)) more."
  fi
  warnings=$((warnings + 1))
fi

# ---------------------------------------------------------------------------
# 1c. Cross-tier-unsafe table-wide truncate in conftests
# ---------------------------------------------------------------------------
#
# Pattern: a conftest.py defines an `autouse=True` fixture that calls
# `.delete().neq(...)` (or `truncate_all_tables`) on tables shared with
# other test tiers — typically `users` / `creator_profiles` / `agencies`.
# Even with the integration tier pinned to a single xdist worker (see
# tests/integration/conftest.py + #946), the autouse truncate races with
# contract / e2e tests on parallel workers, wiping their seed data and
# producing `RECORD_NOT_FOUND` flakes.
#
# Real examples (#949):
#   - tests/integration/conftest.py — clean_db (now opt-in)
#   - tests/integration/campaign_manager/conftest.py — clean_campaign_manager
#   - tests/integration/campaign_manager/brand_guard/conftest.py — clean_brand_guard_data
#
# Safe pattern: drop autouse, OR gate the truncate behind a
# `_foreign_tier_present(session)` check, OR only truncate tables exclusive
# to this tier.

cross_tier_truncate_hits=""
if [ -d backend/tests ]; then
  conftests=$(
    find backend/tests -type f -name 'conftest.py' 2>/dev/null || true
  )
  for f in $conftests; do
    # File must have BOTH a fixture decorator with autouse=True AND a
    # `.delete().neq(...)` (or truncate_all_tables call) AND mention at
    # least one cross-tier-shared table by name. The `@` anchor on the
    # autouse pattern keeps docstring/comment mentions of `autouse=True`
    # from triggering false positives — only real decorator lines count.
    if grep -qE '^\s*@.*autouse\s*=\s*True' "$f" \
       && grep -qE '\.delete\(\)\.neq\(|truncate_all_tables\(' "$f" \
       && grep -qE '"(users|creator_profiles|creators|agencies)"' "$f"; then
      # Whitelist files that already gate on _foreign_tier_present —
      # those are the post-#949 safe shape and shouldn't re-trigger the
      # warning every run.
      if grep -q '_foreign_tier_present' "$f"; then
        continue
      fi
      hit=$(grep -nE '^\s*@.*autouse\s*=\s*True' "$f" | head -1)
      cross_tier_truncate_hits="${cross_tier_truncate_hits}${f}:${hit}
"
    fi
  done
fi

if [ -n "$cross_tier_truncate_hits" ]; then
  print_warn_header
  yellow "[cross-tier truncate] autouse fixture wipes shared tables:"
  yellow "  Conftest defines an autouse fixture that calls \`.delete().neq(...)\` on"
  yellow "  tables (users / creator_profiles / agencies / creators) shared with other"
  yellow "  test tiers. Under \`pytest -n auto tests/\` this races with contract / e2e"
  yellow "  workers and wipes seed data they're using (#949)."
  yellow "  Fixes (in order of preference):"
  yellow "    - Drop the table-wide truncate; per-test UUIDs make it redundant."
  yellow "    - Gate the truncate behind a \`_foreign_tier_present(request.session)\` check."
  yellow "    - Truncate only tables exclusive to this tier (no cross-tier sharing)."
  printf '%s' "$cross_tier_truncate_hits" | while IFS= read -r line; do
    [ -n "$line" ] && printf '    %s\n' "$line"
  done
  warnings=$((warnings + 1))
fi

# ---------------------------------------------------------------------------
# 2. AsyncMock on sync httpx.Response methods
# ---------------------------------------------------------------------------
#
# Pattern: a Python test uses `AsyncMock()` and then calls `.json`, `.text`,
# `.content`, or `.status_code` on it. `httpx.Response`'s `.json()` and
# `.text` are sync — AsyncMock produces coroutines that the real code
# path cannot await. Preferred fixes:
#   - Use `MagicMock()` for the response.
#   - Better: use `respx` to mock at the transport layer.

async_mock_hits=""
if [ -d backend/tests ]; then
  # Find tests that import AsyncMock AND reference a .json / .text call on
  # a variable that's been assigned `AsyncMock()`. This is imprecise — we
  # flag any test file where both patterns appear.
  candidates=$(
    grep -rln 'AsyncMock' backend/tests --include='*.py' 2>/dev/null || true
  )

  for f in $candidates; do
    # Look inside the file for the smell: an `AsyncMock()` assignment to a
    # variable whose name contains `response`, followed anywhere in the
    # same function by `<name>.json.return_value` or similar.
    if grep -qE '\b[a-zA-Z_]*response[a-zA-Z_]*\s*=\s*AsyncMock\(\)' "$f" \
       && grep -qE '\b[a-zA-Z_]*response[a-zA-Z_]*\.(json|text|content)\b' "$f"; then
      hits=$(grep -nE '\b[a-zA-Z_]*response[a-zA-Z_]*\s*=\s*AsyncMock\(\)' "$f")
      async_mock_hits="${async_mock_hits}${hits}
"
    fi
  done
fi

if [ -n "$async_mock_hits" ]; then
  print_warn_header
  yellow "[async-mock drift] \`response = AsyncMock()\` + sync method call:"
  yellow "  \`httpx.Response.json()\` and \`.text\` are SYNC. AsyncMock yields coroutines that"
  yellow "  the real code path never awaits, causing silent failures. Fix:"
  yellow "    - Replace with \`MagicMock()\` for the response object, OR"
  yellow "    - Use \`respx\` to mock at the transport layer (preferred)."
  printf '%s' "$async_mock_hits" | while IFS= read -r line; do
    [ -n "$line" ] && printf '    %s\n' "$line"
  done
  warnings=$((warnings + 1))
fi

# ---------------------------------------------------------------------------
# Result
# ---------------------------------------------------------------------------

if [ $warnings -gt 0 ]; then
  printf '\n'
  if [ "$STRICT" -eq 1 ]; then
    red "check-test-hygiene (STRICT): $warnings category/ies of warnings — exiting 1."
    exit 1
  fi
  yellow "check-test-hygiene: $warnings warning category/ies. Non-blocking — exit 2 is informational."
  exit 2
fi

green "check-test-hygiene: no wall-clock / legacy-envelope / cross-tier-truncate / AsyncMock patterns detected."
exit 0
