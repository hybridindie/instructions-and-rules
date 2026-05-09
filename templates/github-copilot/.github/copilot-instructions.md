# GitHub Copilot Project Instructions – {{PROJECT_NAME}}

Authoritative context for AI code suggestions in this repository.  
Scope: This document is self-contained for GitHub Copilot. The shared constitutional source of truth is `/.claude/rules/` (Articles I–IX) and `/.github/instructions/*.instructions.md`.

---

## 1. Core Mission

All new or refactored code MUST comply with the Constitutional Articles, grouped by concern:

- **Structure** (I–II): library-first, service isolation
- **Quality** (III, VIII): TDD, CI/CD determinism
- **Reliability** (IV–V): structured errors, async-first, no blocking I/O
- **API & Security** (VI–VII): OpenAPI docs, auth/encryption, input validation
- **Traceability** (IX): inline Article references in non-trivial logic

## 2. Constitutional Articles (Pointer Table)

| Article | Requirement (Summary) | Detailed Rules |
|---------|----------------------|----------------|
| I | Library-first: all features live in `{{BACKEND_PATH}}/src/libs/<service>/`. Zero business logic in route handlers. | `/.github/instructions/backend-architecture.instructions.md` |
| II | Service isolation: DI, typed Pydantic returns, no FastAPI imports in service layer. | `/.github/instructions/backend-architecture.instructions.md` |
| III | TDD mandatory. Failing test first. Tiered coverage: Security 90%+, Business 70%+, AI/ML 50%+. | `/.github/instructions/backend-testing.instructions.md` |
| IV | Structured errors: `DomainError` hierarchy, sanitized envelopes, no leaked stack traces. | `/.github/instructions/backend-error-handling.instructions.md` |
| V | Async-first: no blocking I/O, explicit timeouts, DI for DB/cache/HTTP, no global singletons. | `/.github/instructions/backend-async-patterns.instructions.md` |
| VI | OpenAPI documented endpoints, Pydantic `response_model`, no raw dict handling. | `/.github/instructions/backend-api-design.instructions.md` |
| VII | OAuth2/JWT. AES-256. Secrets never hardcoded. Tokens redacted in logs. | `/.github/instructions/backend-security.instructions.md` |
| VIII | CI green: lint, type, tests, coverage, security scan. Lockfiles committed. | `/.github/instructions/cicd.instructions.md` |
| IX | PR checklist per article. CalVer. Doc references present. | `/.github/instructions/enforcement.instructions.md` |
| PRIV | GDPR/data retention. Right to erasure. PII minimized. | `/.github/instructions/privacy-gdpr.instructions.md` |
| RATE | Token-bucket rate limits. Tiered quotas. 429 headers. | `/.github/instructions/rate-limiting.instructions.md` |
| INSEC | CSP, XSS, SQL injection, command injection prevention. | `/.github/instructions/input-security.instructions.md` |
| PROD | Feature flags, canary deploys, rollback procedures. | `/.github/instructions/production-safety.instructions.md` |
| DEPS | Dependabot alerts. CVE SLA. Lockfiles + SBOM. | `/.github/instructions/dependency-security.instructions.md` |
| OBS | Structured JSON logs. PII redaction. Correlation IDs. OpenTelemetry traces. | `/.github/instructions/logging-observability.instructions.md` |
| HLTH | `/health`, `/ready`, `/live`. Graceful shutdown. K8s probes. | `/.github/instructions/health-endpoints.instructions.md` |
| DOCS | README 8-section rule. ADR template. API docs with examples. | `/.github/instructions/documentation-standards.instructions.md` |
| PERF | Backend p95 latency SLOs. Frontend bundle budgets. Core Web Vitals. | `/.github/instructions/performance-budgets.instructions.md` |
| ERRB | Availability SLOs. Burn rate alerts. SEV classification. Blameless post-mortems. | `/.github/instructions/error-budgets.instructions.md` |

> **When suggesting code, load the relevant scoped instruction for the file you're editing.** Do not restate the full article text.

## 3. Tech Stack & Architecture

- Python {{PYTHON_VERSION}} + FastAPI {{FASTAPI_VERSION}}
- PostgreSQL ({{DB_EXTENSIONS}}) via {{DB_PROVIDER}} client
- React {{REACT_VERSION}} + TypeScript {{TYPESCRIPT_VERSION}} + Vite
- {{STATE_MANAGER}} stores (auth, analytics, content) ≤ 300 lines
- Test runners: {{TEST_BACKEND_CMD}} (backend), {{TEST_FRONTEND_CMD}} (frontend)
- shadcn/ui + Tailwind

{{#HAS_MLFLOW}}
- MLflow Prompt Registry is the runtime source of truth for all AI/LLM prompts.
{{/HAS_MLFLOW}}
{{#HAS_LANGGRAPH}}
- LangGraph 1.0 for agent orchestration.
{{/HAS_LANGGRAPH}}

## 4. Suggestion Do / Do Not

Do:
- Propose a **failing test first** before implementation (Article III).
- Reference Articles in critical comments: `# Article V: async DB interaction`.
- Keep functions small, pure, typed, and side-effect minimal.
- Use dependency injection. Return Pydantic models.

Do NOT:
- Insert blocking `time.sleep` or synchronous DB calls in async code.
- Embed secrets, tokens, or credentials in code.
- Add business logic directly into FastAPI routes.
- Use `print` for operational logging.
- Use bare `except Exception` — catch specific `DomainError` subclasses.
- Return `dict[str, Any]` from service methods.
- Use `asyncio.sleep()` in tests.

## 5. Common Templates

Test First Skeleton:
```python
# tests/contract/test_<service>_<action>.py
import pytest
from libs.<service>.models import <Model>

@pytest.mark.asyncio
async def test_<action>_contract__fails_without_required_field():
    payload = {...}  # Missing required field
    with pytest.raises(ValueError):
        await <service>_service.<action>(payload)
```

Domain Service Function Skeleton:
```python
# Article I, III, V
async def create_resource(payload: ResourceIn) -> ResourceOut:
    # Validate (Article III tests enforce contracts)
    # Interact with persistence via injected repository
    return ResourceOut(...)
```

## 6. Acceptance Checklist (Apply Before Suggesting)

- [ ] Test exists & fails initially? (III)
- [ ] Business logic isolated in library? (I)
- [ ] Async and non-blocking? (V)
- [ ] Structured error path? (IV)
- [ ] Endpoint documented & typed? (VI)
- [ ] Security addressed? (VII)
- [ ] No global mutable singletons? (V)

## 7. When User Requests a Quick Hack

Politely steer toward constitutional compliance. If they explicitly insist, annotate generated code with `# WARNING: Non-compliant (explain)`.

## 8. Evolution

Updates to these instructions: PR modifying ONLY this file + reference rationale + impacted Articles. These instructions stand alone; do not couple changes to other agent prompt files.

---

## Versioning Policy (CalVer)

`YYYY.MM.DD[-N]`. The authoritative constitution lives in `/.claude/rules/`. Changelog entries reflect the CalVer date.

{{CUSTOM_INSTRUCTIONS}}

---
End of Copilot Instructions.
