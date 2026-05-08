---
paths:
  - "backend/src/libs/auth_manager/**/*.py"
  - "backend/src/libs/platform_auth/**/*.py"
  - "backend/src/libs/route_guard/**/*.py"
  - "backend/app/api/routes/auth*.py"
  - "backend/app/core/security*.py"
  - "backend/app/core/dependencies*.py"
---

# Secure-by-Default (Article VII)

- Auth uses OAuth2/JWT. No endpoints bypassing access checks
- Validate JWT (signature, exp, aud, iss) on every protected request
- Encrypt secrets at rest (AES-256 GCM) and redact before logging
- Enforce least privilege in service-to-service operations
- Rotate keys regularly and document schedule
- Security-critical code requires 90%+ test coverage (Article III)

## Dependency & Configuration Hygiene

- Prefer actively maintained libraries; audit dependencies for CVEs before adoption (#330)
- Validate security-critical config at application startup — reject missing/weak secrets in production (#345, #331)
- Token lifetimes: access ≤ 15min, refresh ≤ 7d in production (#331)

ANTI-PATTERNS:
- Storing plaintext secrets or credentials
- Using weak cryptographic primitives
- Bypassing auth checks (hidden endpoints / debug flags)
- Logging PII or tokens
