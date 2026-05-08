---
paths:
  - "backend/src/libs/**/*.py"
  - "backend/app/**/*.py"
---

# Error Handling & Observability (Article IV)

Structured error handling required. Silent failures forbidden.

## MUST

- Use `DomainError` (or subclass) with stable `code` values for domain failures
- Map unhandled exceptions at API boundary to sanitized error envelope (never raw traceback)
- Emit correlation/request ID per request

## DomainError -> HTTP Status Mapping

| DomainError code | HTTP |
|-----------------|------|
| VALIDATION_ERROR | 422 |
| BAD_REQUEST | 400 |
| AUTHENTICATION_FAILED | 401 |
| AUTHORIZATION_FAILED | 403 |
| RESOURCE_NOT_FOUND | 404 |
| CONFLICT | 409 |
| RATE_LIMITED | 429 |
| DEPENDENCY_UNAVAILABLE | 503 |
| TIMEOUT | 504 |
| INTERNAL_ERROR | 500 |

## Error Envelope

```json
{"error": {"code": "RESOURCE_NOT_FOUND", "message": "...", "details": {}}}
```

## DomainError Propagation (BLOCKING)

DomainError and its subclasses carry structured `code`, `message`, and `details` that the global exception handler middleware converts into the standard error envelope. Intercepting them in route handlers destroys this contract.

MUST:
- Let DomainError subclasses propagate to the middleware — never `except DomainError: raise HTTPException(...)` in route code
- Use canonical `ErrorCode` enum values when raising DomainError subclasses — never ad-hoc strings like `code="weak_password"` (use `ErrorCode.PASSWORD_POLICY_VIOLATION` or the factory `ValidationError.password_policy_violation(...)`)
- Derive error envelope fields (`field`, `context`) from the exception object — never hardcode field names via string matching
- Include `exc_info=True` in `logger.error()` calls for exception paths so stack traces are preserved in production logs

MUST NOT:
- Catch a DomainError to re-raise as `HTTPException` — the middleware already maps `DomainError.code` to the correct HTTP status
- Invent new error codes outside the `ErrorCode` enum — add the code to the enum first, then use it
- Return a 400 when the DomainError maps to 409, 422, or 429 — the mapping table above is the contract

## ANTI-PATTERNS

- Swallowing exceptions silently
- Returning partial responses with implicit errors
- Logging sensitive tokens or user secrets
- Bare `except Exception` catching all errors — catch specific DomainError subclasses (#327)
- Using `ValueError`/`TypeError` for domain errors — use DomainError hierarchy (#327)
- Duplicate error-handling middleware — consolidate in a single exception handler (#324)
- Catching DomainError in a route to convert it to HTTPException — loses structured error codes and breaks the client contract (#888, #867)
- Ad-hoc error code strings instead of ErrorCode enum values — clients can't match on them (#880)
- Missing `exc_info=True` on error-level logs — makes production debugging near-impossible (#901)
