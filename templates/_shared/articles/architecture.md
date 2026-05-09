---
paths:
  - "{{BACKEND_PATH}}/src/libs/**/*.py"
  - "{{BACKEND_PATH}}/app/**/*.py"
---

# Architecture: Library-First & Service Isolation (Articles I & II)

## Library-First (Article I)

MUST:
- Feature libraries live under `{{BACKEND_PATH}}/src/libs/<service_name>` with `models.py`, `service.py`, `errors.py`
- FastAPI routes are delegation only — no domain branching logic
- Expose pure functions; no side effects at import time
- `src/libs/` modules MUST NOT import from `app.*` — use dependency injection or protocols

SHOULD:
- Extract pure logic to `core/` or `repositories/` for test isolation
- Functions under 40 lines, composition-focused
- Complex libraries add `repositories/`, `validators/`, `transformers/`
- Libraries with multiple bounded contexts SHOULD be split into focused sub-libraries under a shared parent

ANTI-PATTERNS (BLOCKING):
- Business rule branches in route handlers
- Direct DB queries from API layer
- Cyclic cross-library imports
- `from app.` imports inside `src/libs/` (use DI/protocols instead)
- Mock/stub classes in production service files — place in `tests/` fixtures
- Service files exceeding 500 lines without splitting; over 1000 lines blocks merge
- Libraries depending on unrelated libraries — use shared interfaces

{{#HAS_MLFLOW}}
## Prompt Registry

MUST:
- All AI/LLM system prompts MUST be registered in a prompt registry manifest
- Prompt registry is the runtime source of truth and REQUIRED serving source for prompts in normal operation
- Prompt changes MUST be synced to the registry before rollout; constants are seed material only
- Python constant fallback path is degraded-state resiliency only and MUST NOT be treated as a normal operating mode
- All agent prompt reads MUST go through a prompt loader service
- Prompts are cached in the database with TTL and loaded into process memory at startup
- New prompts MUST include metadata tags in the manifest entry
- Adding or modifying a prompt constant requires a corresponding entry in the prompt manifest

ANTI-PATTERNS:
- Importing prompt constants directly in agent files without routing through loader service
- Hardcoding prompts inline without registering them in the manifest
- Treating fallback constants as the primary prompt source during normal operation
{{/HAS_MLFLOW}}

## Service Isolation (Article II)

MUST:
- Services accept dependency-injected clients (DB, cache, HTTP, clock) — no global singletons
- Services return typed results (Pydantic models or standard types), never `dict[str, Any]`
- Injectable clock/time provider for time-sensitive logic
- All external dependencies (time, randomness, APIs) must be injectable

SHOULD:
- Single responsibility per service function
- DomainError exceptions for errors, never mixed return types

ANTI-PATTERNS:
- Services importing FastAPI Request/Response types
- Hard-coded external API URLs or connections
- `datetime.now()` without injection
- Services requiring the HTTP server to test
- Returning `dict[str, Any]` from service methods — define Pydantic response models
