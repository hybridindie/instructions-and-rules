---
paths:
  - "{{BACKEND_PATH}}/src/libs/**/*.py"
  - "{{BACKEND_PATH}}/app/**/*.py"
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

MUST:
- Let DomainError subclasses propagate to the middleware — never `except DomainError: raise HTTPException(...)` in route code
- Use canonical `ErrorCode` enum values when raising DomainError subclasses — never ad-hoc strings
- Derive error envelope fields from the exception object — never hardcode field names via string matching
- Include `exc_info=True` in `logger.error()` calls for exception paths

MUST NOT:
- Catch a DomainError to re-raise as `HTTPException` — the middleware already maps codes
- Invent new error codes outside the `ErrorCode` enum
- Return a 400 when the DomainError maps to 409, 422, or 429

## ANTI-PATTERNS

- Swallowing exceptions silently
- Returning partial responses with implicit errors
- Logging sensitive tokens or user secrets
- Bare `except Exception` catching all errors — catch specific DomainError subclasses
- Using `ValueError`/`TypeError` for domain errors — use DomainError hierarchy
- Duplicate error-handling middleware — consolidate in a single exception handler
- Catching DomainError in a route to convert it to HTTPException
- Ad-hoc error code strings instead of ErrorCode enum values
- Missing `exc_info=True` on error-level logs
