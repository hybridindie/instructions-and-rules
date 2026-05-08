---
description: "Use when editing FastAPI route handlers and API boundary modules; enforce endpoint docs, explicit response models, and thin-route delegation."
applyTo: "backend/app/api/**/*.py"
---

# API Contract & Documentation (Article VI)

Apply these constraints in priority order:

1. **Delegate** — Route handlers do parsing + dependency injection + delegation only; no domain logic inline.
2. **Document** — Every endpoint must have `summary` and `response_model`. Add `description` if the route performs more than one operation or includes complex logic.
3. **Validate** — Validate all inbound payloads using Pydantic models (no raw dict handling).
4. **Communicate changes** — Version or document breaking changes prior to merging.
5. **Provide examples** — Add examples to model `model_config` or `json_schema_extra` for OpenAPI clarity.

ANTI-PATTERNS:
- Silent shape changes without migration notes
- Business logic in route handlers (delegate to service layer)
