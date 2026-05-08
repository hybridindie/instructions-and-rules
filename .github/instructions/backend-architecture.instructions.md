---
description: "Use when working on backend architecture, service boundaries, and library organization across app and libs modules."
applyTo: "backend/src/libs/**/*.py, backend/app/**/*.py"
---

# Architecture: Library-First & Service Isolation (Articles I & II)

> **Quick reference**
> | Concern | Rule |
> |---------|------|
> | Library location | `backend/src/libs/<service_name>` |
> | Route responsibility | Parse input → inject deps → call service → return result |
> | Service responsibility | Business logic only; no FastAPI/HTTP imports |
> | Prompt source | MLflow Prompt Registry (constants = fallback only) |
> | Return types | Typed Pydantic models — never `dict[str, Any]` |

## Library-First (Article I)

MUST:
- Feature libraries live under `backend/src/libs/<service_name>` with `models.py`, `service.py`, `errors.py`
- FastAPI routes must only delegate requests to service layer functions without implementing branching logic
- Expose pure functions; no side effects at import time
- `src/libs/` modules MUST NOT import from `app.*` — use dependency injection or protocols (#323)

SHOULD:
- Extract pure logic to `core/` or `repositories/` for test isolation
- Functions under 40 lines, composition-focused
- Complex libraries add `repositories/`, `validators/`, `transformers/`
- Libraries with multiple bounded contexts (e.g., analytics: aggregation, forecasting, plateau detection) SHOULD be split into focused sub-libraries under a shared parent (#335)

ANTI-PATTERNS (BLOCKING):
- Business rule branches in route handlers
- Direct DB queries from API layer
- Cyclic cross-library imports
- `from app.` imports inside `src/libs/` (use DI/protocols instead) (#323)
- Mock/stub classes in production service files — place in `tests/` fixtures (#337)
- Service files exceeding 500 lines without splitting; over 1000 lines blocks merge (#339)
- Libraries depending on unrelated libraries (e.g., scheduler→dashboard) — use shared interfaces (#340)

## MLflow Prompt Registry

MUST:
- All AI/LLM system prompts MUST be registered in `prompt_registry.py` via `_build_prompt_manifest()`
- MLflow Prompt Registry is the runtime source of truth and REQUIRED serving source for prompts in normal operation
- Prompt changes MUST be synced to MLflow Prompt Registry before rollout; constants are seed material only
- Python constant fallback path is degraded-state resiliency only and MUST NOT be treated as a normal operating mode
- All agent prompt reads MUST go through `get_prompt_loader().get_prompt(name, fallback=CONSTANT)`
- Prompts are cached in Postgres (`app_cache` table) with 5-min TTL and loaded into process memory at startup
- New prompts MUST include `agent` and `stage` tags in the manifest entry
- Adding or modifying a prompt constant requires a corresponding entry in the prompt manifest

ANTI-PATTERNS:
- Importing prompt constants directly in agent files without routing through PromptLoaderService
- Hardcoding prompts inline without registering them in the manifest
- Creating prompt constants without adding them to `_build_prompt_manifest()`
- Shipping prompt edits without publishing/syncing the corresponding MLflow Prompt Registry version
- Treating fallback constants as the primary prompt source during normal operation

## Service Isolation (Article II)

MUST:
- Services accept dependency-injected clients (DB, cache, HTTP, clock) - no global singletons
- Services return typed results (Pydantic models or standard types), never `dict[str, Any]` (#338)
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
- Returning `dict[str, Any]` from service methods — define Pydantic response models (#338)
