---
description: "Flask Testing: Flask test client, pytest fixtures, and coverage tiers"
applyTo: "{{BACKEND_PATH}}/tests/**/*.py, {{BACKEND_PATH}}/src/libs/**/*.py"
---

# Testing: TDD Mandate (Article III — Flask Variant)

## Test Runner

- `pytest` with `pytest-flask` for the Flask test client.
- Use the application factory in tests: `app = create_app(testing=True)`.
- Fixtures provide the test client: `client = app.test_client()`.

## Test Types

| Layer | What | Where | Example |
|-------|------|-------|---------|
| Contract | API boundary, response envelope, status codes | `tests/contract/` | `client.get("/api/v1/items")` asserts 200 + envelope |
| Unit | Service functions, pure logic | `tests/unit/` | `get_items(db)` with mock db |
| Integration | Service + DB, real queries | `tests/integration/` | `get_items(real_db)` against test schema |
| E2E | Full request → response through all layers | `tests/e2e/` | `client.post("/api/v1/items", json={...})` |

## Flask Test Client Patterns

```python
import pytest
from myapp import create_app

@pytest.fixture
def app():
    return create_app(testing=True)

@pytest.fixture
def client(app):
    return app.test_client()

def test_get_items_returns_envelope(client):
    resp = client.get("/api/v1/items")
    assert resp.status_code == 200
    data = resp.get_json()
    assert "data" in data
    assert isinstance(data["data"], list)
```

## Skip/xfail rules

Same as Article III: zero `@pytest.mark.skip`, zero `xfail`, zero failing
tests. `@pytest.mark.skipif(<env_precondition>)` is the only permitted skip.
Applies `.agents/` doctrine: `test-discipline-rules.md`.

## Determinism

- Use `freezegun` (`freeze_time`) for time-dependent tests, not wall-clock.
- Mock external HTTP calls with `responses` or `httpx_mock`, not real network.
- Database tests use a transaction-rollback fixture — never share state
  between tests.

## Coverage Tiers

Same as Article III (security-critical 90%, business 70%, AI/ML 50%).