---
paths:
  - "backend/**/*.py"
---

# Testing: TDD Mandate (Article III)

Code is only written after failing tests are defined. Add regression tests for any bug found.

## Tiered Coverage Requirements

| Component Type | Minimum |
|----------------|---------|
| Security-critical (auth, OAuth, encryption, tokens) | 90%+ |
| Revenue-critical (payments, conversions, subscriptions) | 85%+ |
| Business logic (platform sync, content, analytics) | 70%+ |
| AI/ML services (recommendations, insights) | 50%+ |
| Utilities & helpers | 50%+ |
| Security tests (CSRF, XSS, injection, rate limiting) | Dedicated suite required |

Aggregate: 70% across `backend/src/libs/`, 60% across `app/`.

## MUST

- Write failing contract test before implementing public API shape
- Achieve minimum coverage per tier for EACH library under `backend/src/libs/<service>`
- Include contract, integration, and E2E tests before merge
- Regression test for each defect before the fix commit
- Branch coverage for error paths - every exception path tested
- Security/revenue-critical components MUST NOT merge below tier minimums

## Test Authoring Order

Contract -> Integration -> E2E -> Unit

| Layer | Purpose | Directory |
|-------|---------|-----------|
| Contract | Schema/interface expectations | `tests/contract/` |
| Integration | Real DB/cache/infra | `tests/integration/` |
| E2E | Full user flows via HTTPX | `tests/e2e/` |
| Unit | Isolated logic branches | `tests/unit/` |

## Suite Health (BLOCKING — no exceptions)

The test suite is a binary signal. Either it is green and trusted, or it is
a liar. A partially-green suite is worse than no suite at all because it
normalises broken state. These rules exist to keep the signal trustworthy.

- **Zero failing or erroring tests may be checked in**, ever. Running the
  full suite (`uv run pytest tests/`) on a clean checkout of the merged
  branch MUST exit zero. "Pre-existing failure" is not a defence — fix or
  delete.
- **Zero unconditional skips may be checked in**. Specifically forbidden:
  - `@pytest.mark.skip(reason=...)` — always an anti-pattern. Delete the
    test if its premise is invalid; fix it if the code drifted; rewrite it
    against the current architecture. An always-skipped test looks like
    coverage while providing none.
  - `@pytest.mark.xfail` — if the test is expected to fail, fix the code
    or delete the test. No dormant failures.
  - A bare `pytest.skip("not implemented")` or `pytest.skip("needs setup")`
    at the top of a test body is just an unconditional skip in disguise.
- **Conditional skips are permitted only when genuinely environmental.** Use
  `@pytest.mark.skipif(<bool_expr>, reason=...)` gated on a real precondition
  (e.g. `settings.supabase_url is None`). Runtime `pytest.skip(...)` inside
  a test body is permitted only inside an explicit `if <env-precondition>:`
  guard. Every conditional skip MUST fail closed in a properly-configured
  environment — it skips *only* when the dependency is genuinely absent.
- **Test drift is a bug, not a placeholder.** When you change a route,
  component, store, schema, service, or contract, the co-owning tests MUST
  be updated in the same commit. Leaving a broken test behind is checked-in
  debt that compounds. If the test is no longer meaningful (the feature
  moved or was deleted), delete the test.
- **Determinism is mandatory.** Any test that depends on wall-clock time,
  randomness, or external I/O must inject a deterministic provider
  (`Clock`, `RandomProvider`, `FakeRandomProvider`, `respx`, etc.). A
  passing-95%-of-the-time test is a failing test with extra steps. Past
  bugs: `mock_send_email` 5% random failure (#901-series), hardcoded
  `token_expires_at` that rotted when wall clock advanced, `asyncio.sleep`
  in tests (#332).
- **Fixtures must match the domain they mock.** When a Pydantic model or
  Zod schema grows a new required field, every test fixture that constructs
  it must be updated. Silent Pydantic field drops (`extra="ignore"`) make
  this class of drift invisible — check fixtures whenever you touch a
  model.
- **Mock shapes must match real library shapes.** `httpx.Response.json()`
  is sync — mocking it with `AsyncMock` yields coroutines and breaks the
  real code path. Prefer `respx` over hand-rolled httpx patches. Prefer
  `MagicMock` for any library object where methods aren't truly async.
- **Assert on the canonical error envelope.** API errors land as
  `{"error": {"code": ..., "message": ..., "context": {...}}}` per
  Article IV (`.claude/rules/backend/error-handling.md`). Tests asserting
  on the legacy `{"detail": ...}` shape pass alone if a fallback handler
  still emits it under specific conditions, then fail under cross-tier
  loads when the canonical handler runs. Use
  `assert "error" in body and body["error"]["code"] == "<code>"` —
  never `assert "detail" in error_data` against this platform's API.
  (Surfaced in #949 via `tests/e2e/test_user_authentication_journey.py`.)
- **Cross-tier-safe fixture cleanup.** A conftest's `autouse=True` fixture
  that runs `.delete().neq(...)` (or `truncate_all_tables(...)`) on
  tables shared across test tiers — `users`, `creator_profiles`,
  `agencies`, `creators` — is a cross-tier time bomb. Even with the
  integration tier pinned to a single xdist worker (#946), the truncate
  races with contract / e2e tests on parallel workers and wipes their
  seed data. Allowed shapes:
  1. **Drop `autouse=True`.** Per-test `uuid.uuid4()` IDs make the
     table-wide truncate redundant; tests can opt in to the fixture
     when they truly need empty tables.
  2. **Gate the truncate on `_foreign_tier_present(request.session)`.**
     Skip when foreign tiers are in the run; full reset is safe in
     integration-only sessions.
  3. **Truncate only tier-private tables** (e.g., `brand_guard_verdicts`,
     `brand_guard_metric_snapshots`) that no other tier reads or writes.
  The `tests/integration/campaign_manager/{conftest.py,brand_guard/conftest.py}`
  fixtures from #949 are the reference. (Tracked: `check-test-hygiene.sh`
  has a `cross-tier truncate` warning category that flags new instances.)
- **Tests must be hermetic against process-global singletons.** Module-level
  caches like `get_prompt_loader()`, `get_async_supabase()`, MLflow client
  factories — all live for the lifetime of the worker process. A test that
  relies on a SPECIFIC cache state (cold cache → fallback path; warm cache →
  fetched value) must explicitly patch the singleton (`@patch("...get_prompt_loader")`)
  or reset it via the test-helper (`_reset_prompt_loader()`). Tests that
  read the global state without patching pass alone and fail when an
  earlier test populates the cache. (Surfaced in #949 via
  `tests/unit/test_viva_comfy_prompt_node.py::test_initial_generation_uses_identity_lock_instruction`.)

## ANTI-PATTERNS

- Retrofitting tests post-implementation
- Excessive mocking hiding integration risk
- Ignoring uncovered error path branches
- Trivial assertions that don't validate behavior
- `asyncio.sleep()` in tests — use deterministic waits or condition polling (#332)
- Mock/stub classes defined inside production source files (#337)
- Tests that assert on infrastructure that was never built (CSRF token
  middleware for a header-auth API, for example) — delete the test; its
  premise is wrong, not its coverage.
- `assert "detail" in error_data` against this platform's API — the API
  uses `{"error": {"code": ..., "message": ...}}` per Article IV. Annotate
  with `# hygiene: envelope-ok` only if the response is genuinely from a
  third-party (Stripe / Supabase / OAuth provider) (#949).
- `autouse=True` conftest fixtures that truncate cross-tier-shared tables
  (`users`, `creator_profiles`, `agencies`, `creators`) — they race with
  other tiers' workers under `pytest -n auto tests/`. Drop autouse, gate
  on `_foreign_tier_present(request.session)`, or scope to tier-private
  tables (#949).
- Tests that read process-global singletons (`get_prompt_loader()`,
  cached supabase clients, MLflow factories) without explicitly patching
  them — the test's pass/fail depends on whether earlier tests warmed
  the cache. Patch the singleton or use the test-helper reset (#949).
