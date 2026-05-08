---
description: "Use when touching auth, route guards, security dependencies, or backend security-critical modules and endpoints."
applyTo: "backend/src/libs/auth_manager/**/*.py, backend/src/libs/platform_auth/**/*.py, backend/src/libs/route_guard/**/*.py, backend/app/api/routes/auth*.py, backend/app/core/security*.py, backend/app/core/dependencies*.py"
---

# Secure-by-Default (Article VII)

## Authentication

- Auth uses OAuth2/JWT. No endpoints bypassing access checks.
- Validate JWT (signature, `exp`, `aud`, `iss`) on every protected request. If a JWT is invalid or expired, respond with HTTP 401 Unauthorized and log the event (without the token value).
- Token lifetimes: access ≤ 15min, refresh ≤ 7d in production (#331).

## Data Protection

- Encrypt secrets at rest (AES-256 GCM) and redact before logging.
- Rotate signing keys every 90 days; document the rotation schedule and next due date in the project runbook.
- Security-critical code requires 90%+ test coverage (Article III).

## Access Control

- Enforce least privilege in service-to-service operations.
- No hidden endpoints or debug flags that bypass auth checks.

## Dependency & Configuration Hygiene

- Prefer actively maintained libraries; audit dependencies for CVEs before adoption (#330).
- Validate security-critical config (database credentials, API keys, and encryption keys) at application startup — reject missing or weak secrets in production (#345, #331).

ANTI-PATTERNS:
- Storing plaintext secrets or credentials
- Using weak cryptographic primitives
- Bypassing auth checks (hidden endpoints / debug flags)
- Logging PII or tokens
