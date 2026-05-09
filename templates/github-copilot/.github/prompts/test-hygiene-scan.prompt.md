---
description: "Triage hardcoded dates, AsyncMock misuse, cross-tier truncates, and envelope assertion bugs in the test suite"
---

# Test Hygiene Scanner

Scan the test suite for common hygiene violations that cause flaky or misleading tests.

## Categories to Scan

### 1. Hardcoded Dates
Search for ISO date strings that will rot as wall-clock advances:
- `2026-` in test files
- `Date.parse("...")` with fixed dates
- `grace_expires_at` pinned to past/future dates

### 2. AsyncMock Misuse
Search for `AsyncMock` wrapping sync methods:
- `httpx.Response.json()` mocked with `AsyncMock`
- Magic methods (`__getitem__`, `__enter__`) mocked with `AsyncMock`

### 3. Cross-Tier Table Truncates
Search for `autouse=True` conftest fixtures that truncate shared tables:
- `.delete().neq(...)` on `users`, `creator_profiles`, `agencies`, `creators`
- `truncate_all_tables(...)` without tier gating

### 4. Envelope Assertion Bugs
Search for `assert "detail" in error_data` against the project's API:
- The project uses `{"error": {"code": ..., "message": ...}}` per Article IV.
- `assert "detail" in error_data` is a bug unless the response is from a third-party.

### 5. Process-Global Singleton Leaks
Search for tests reading module-level caches without patching:
- `get_prompt_loader()`, `get_async_supabase()`, MLflow factories

## Output

For each category, report:
- File:line citation
- Severity: WARNING (may cause flakes) or ERROR (definitely wrong)
- Suggested fix

Example:
```
## Test Hygiene Report

### Hardcoded Dates
- WARNING `frontend/src/stores/analytics.test.ts:42` — `Date.parse("2026-02-17")` used for "recent" window. Use `Date.now() - offset` or `vi.useFakeTimers()`.

### AsyncMock Misuse
- ERROR `backend/tests/unit/test_email_service.py:88` — `AsyncMock` wrapping `httpx.Response.json()` (sync method). Use `MagicMock` instead.

### Cross-Tier Truncates
- ERROR `backend/tests/integration/conftest.py:15` — `autouse=True` fixture truncates `users` table. Drop autouse or gate on `_foreign_tier_present`.

### Envelope Assertions
- ERROR `backend/tests/e2e/test_user_journey.py:203` — `assert "detail" in error_data` against this API. Use `assert "error" in body` per Article IV.

### Singleton Leaks
- WARNING `backend/tests/unit/test_viva_node.py:55` — reads `get_prompt_loader()` without patching. Patch with `@patch("...get_prompt_loader")`.
```

## Rules

- Only report test files (`tests/**`, `**/*.test.ts`, `**/*.test.py`).
- Do not report production code.
- If a category is clean, say so: "No hardcoded dates found."
