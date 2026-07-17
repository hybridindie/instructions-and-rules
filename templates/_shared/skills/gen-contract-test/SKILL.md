---
name: gen-contract-test
description: Generate a contract test skeleton for a backend or frontend service following TDD Article III
user-invocable: true
disable-model-invocation: true
arguments:
  - name: target
    description: "Service or module to test (e.g., 'analytics-service', 'auth/login')"
    required: true
  - name: stack
    description: "backend or frontend (default: backend)"
    required: false
---

# Generate Contract Test

Scaffold a contract test that follows the project's TDD mandate (Article III) and existing test patterns.

## Steps

### 1. Identify the target

Based on the `target` argument, locate the service/module:
- **Backend**: Search `{{BACKEND_PATH}}/src/libs/` and `{{BACKEND_PATH}}/app/` for the matching service, router, or module.
- **Frontend**: Search `{{FRONTEND_PATH}}/src/services/` and `{{FRONTEND_PATH}}/src/contracts/` for the matching service interface.

Read the target's source code to understand its public API surface.

### 2. Check for existing tests

Search `{{BACKEND_PATH}}/tests/contract/` or `{{FRONTEND_PATH}}/tests/contract/` for existing tests. Report what's covered and only scaffold uncovered endpoints.

### 3. Scaffold the test file

#### Backend (Python/pytest)

Create `{{BACKEND_PATH}}/tests/contract/test_{target_snake_case}_contract.py`:

```python
"""
Contract test for {Target Description}
Validates externally visible interface/schema boundary.
"""

import pytest
from fastapi import status
from httpx import AsyncClient

pytestmark = pytest.mark.asyncio


class Test{TargetPascalCase}Contract:
    """{Target} contract compliance tests"""

    async def test_{endpoint}_success_response_schema(self, client: AsyncClient):
        """Test successful response returns correct schema"""
        response = await client.{method}("{path}", json={...})
        assert response.status_code == status.HTTP_{EXPECTED}
        data = response.json()
        # Validate field presence and types for the success envelope.
        ...

    async def test_{endpoint}_validation_errors(self, client: AsyncClient):
        """Test input validation returns Article IV error envelope"""
        response = await client.{method}("{path}", json={invalid_input})
        assert response.status_code == status.HTTP_422_UNPROCESSABLE_ENTITY
        data = response.json()
        assert "error" in data
        assert "code" in data["error"]
        assert "message" in data["error"]

    async def test_{endpoint}_unauthorized(self, client: AsyncClient):
        """Test unauthenticated access returns 401"""
        response = await client.{method}("{path}")
        assert response.status_code == status.HTTP_401_UNAUTHORIZED
        data = response.json()
        assert "error" in data or "detail" in data
```

#### Frontend (TypeScript/Vitest)

Create `{{FRONTEND_PATH}}/tests/contract/{target-kebab-case}-contract.test.ts`:

```typescript
/**
 * {Target} Contract Test - Constitutional Compliance
 * Tests {Target} interface compliance.
 *
 * CRITICAL: This test MUST FAIL initially (RED phase of TDD)
 */
import { describe, it, expect, beforeEach } from 'vitest'

describe('{Target} Contract Compliance', () => {
  describe('Service Interface', () => {
    it('should implement required methods', () => { ... })
    it('should return correct response shape', async () => { ... })
  })

  describe('Error Handling Compliance', () => {
    it('should handle invalid input gracefully', async () => { ... })
    it('should handle network errors gracefully', async () => { ... })
  })
})
```

### 4. What to test in contract tests

- Response schema shape — required fields, types, nesting
- Status codes — correct HTTP codes for success, validation errors, auth errors
- Error envelope format — Article IV compliance
- Validation boundaries — missing required fields, invalid formats
- Auth requirements — endpoints that need auth return 401 without it

Do NOT include:
- Internal implementation details
- Database state verification
- Performance assertions
- Mocked behavior tests

### 5. Verify the test fails (RED phase)

After generating, run the test to confirm it fails:
- Backend: `cd {{BACKEND_PATH}} && {{TEST_BACKEND_CMD}} tests/contract/test_{name}_contract.py -v`
- Frontend: `cd {{FRONTEND_PATH}} && {{TEST_FRONTEND_CMD}} tests/contract/test-{name}-contract.test.ts`

Report the failure output. This confirms the RED phase of TDD is working correctly.

## Rules

- One test class/describe block per service or endpoint group.
- Test names describe the contract being validated, not the implementation.
- Always include tests for: success schema, validation errors, and auth requirements.
- **Never add `@pytest.mark.skip` or `@pytest.mark.xfail`.**
- **Never add `it.skip`, `test.skip`, `describe.skip`, `.todo`, `xit`, or `xdescribe`.**
- Follow existing naming: `test_{name}_contract.py` (backend), `{name}-contract.test.ts` (frontend).
