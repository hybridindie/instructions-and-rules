---
paths:
  - "{{BACKEND_PATH}}/app/**/*.py"
  - "{{BACKEND_PATH}}/src/libs/**/*.py"
  - "{{BACKEND_PATH}}/pyproject.toml"
---

# Logging, Observability & Telemetry

## MUST

### Log Levels
| Level | When to Use |
|-------|-------------|
| DEBUG | Development-only; disabled in production |
| INFO | Normal operational events: requests served, jobs completed, user actions |
| WARNING | Anomalous but non-fatal: slow queries, deprecated API usage, rate limit close |
| ERROR | Exceptions caught and handled: `DomainError`, failed external calls with retry |
| CRITICAL | Unrecoverable: database unreachable, security breach, data corruption |

- Log level MUST be configurable via environment variable without code change
- Production default: `WARNING` (backend), `ERROR` (external services)

### Structured JSON Format
Every log line MUST be valid JSON with these required fields:
```json
{
  "timestamp": "2026-05-09T12:34:56.789Z",
  "level": "ERROR",
  "service": "{{PROJECT_SLUG}}",
  "correlation_id": "550e8400-e29b-41d4-a716-446655440000",
  "trace_id": "abc123def456",
  "span_id": "span789",
  "message": "User login failed",
  "logger": "auth_service",
  "file": "auth_service.py",
  "line": 42
}
```

- Optional "context" field for additional structured data (MUST be a flat dict, max 10 keys)
- Optional "error" field for exception details: `{"type": "DomainError", "code": "AUTH_FAILED", "message": "..."}`
- NO free-form string concatenation: use structured fields instead of `f"User {user_id} failed"`

### Correlation IDs
- Every incoming request MUST receive or generate a `correlation_id` (UUID)
- Propagate the same `correlation_id` through all downstream service calls (HTTP header `X-Correlation-ID`)
- Include `correlation_id` in every log line related to that request
- Store `correlation_id` in the request context (FastAPI `request.state` or contextvar)

### PII Redaction
- PII MUST NOT appear in logs: email, phone, name, address, IP, SSN, payment info
- Use hashed or tokenized identifiers: `user_id_sha256`, `email_domain_only`
- Redaction MUST be automatic at the logging layer, not a human review step

### Error Logging
- Every caught exception path MUST log at `ERROR` level with `exc_info=True` (preserves stack trace)
- Do NOT log the same error multiple times as it bubbles up — log once at the boundary (middleware)
- CRITICAL errors MUST trigger an alert (PagerDuty, Slack, or equivalent)

## SHOULD

- OpenTelemetry traces for request flow visualization (spans for DB queries, external calls)
- Structured metrics (Prometheus/datadog): counters for API calls, histograms for latency, gauges for queue depth
- Log sampling for high-volume endpoints: 100% errors, 1% successful GETs
- Centralized log aggregation: Datadog, Splunk, Grafana Loki, or CloudWatch

## ANTI-PATTERNS (BLOCKING)

- `print()` statements in production code (bypasses format, aggregation, and PII checks)
- Unstructured log lines: `"User failed login: " + email` (cannot be parsed by aggregation tools)
- Logging PII in plaintext (GDPR violation, audit failure)
- Noisy DEBUG logging left enabled in production (cost, noise, missed signals)
- Multiple log lines for a single conceptual event (use structured fields instead)
- Stack traces without context (which request, which user, which endpoint)

## Enforcement Checklist

- [ ] JSON format enforced in all log output
- [ ] Required fields present for every log line
- [ ] Correlation ID propagated through all requests and service calls
- [ ] Zero PII in application logs (verify with automated scan)
- [ ] `exc_info=True` on all ERROR-level exception logs
- [ ] `print()` statements absent from production code
