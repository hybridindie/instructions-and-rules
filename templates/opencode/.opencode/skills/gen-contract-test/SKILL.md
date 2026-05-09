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

Scaffold a contract test that follows the project's TDD mandate (Article III).

## Steps

### 1. Identify the target

- **Backend**: Search `{{BACKEND_PATH}}/src/libs/` and `{{BACKEND_PATH}}/app/`.
- **Frontend**: Search `{{FRONTEND_PATH}}/src/services/` and `{{FRONTEND_PATH}}/src/contracts/`.

### 2. Scaffold

Backend: `{{BACKEND_PATH}}/tests/contract/test_{target}_contract.py`
Frontend: `{{FRONTEND_PATH}}/tests/contract/{target}-contract.test.ts`

### 3. Rules

- Include tests for: success schema, validation errors, auth requirements.
- Never add skips, xfails, or todos.
- Use existing fixtures (backend `client` from conftest.py).
- Assert on Article IV error envelope: `{"error": {"code": ..., "message": ...}}`.

### 4. Verify RED phase

Run the test to confirm it fails before implementation.
