---
description: "Flask Error Handling: error handlers, DomainError mapping, response envelope"
applyTo: "{{BACKEND_PATH}}/src/libs/**/*.py, {{BACKEND_PATH}}/app/**/*.py"
---

# Error Handling & Observability (Article IV — Flask Variant)

## DomainError Hierarchy

Same DomainError hierarchy as the canonical article — errors are structured
with a stable `code` for clients. The difference is how they map to HTTP
responses.

## Flask Error Handlers (replaces FastAPI middleware)

Register error handlers in the application factory:

```python
from myapp.errors import DomainError, NotFoundError, ValidationError

def create_app():
    app = Flask(__name__)
    
    @app.errorhandler(NotFoundError)
    def handle_not_found(e):
        return jsonify({"error": {"code": e.code, "message": str(e)}}), 404
    
    @app.errorhandler(ValidationError)
    def handle_validation(e):
        return jsonify({"error": {"code": e.code, "message": str(e), "context": e.context}}), 422
    
    @app.errorhandler(DomainError)
    def handle_domain_error(e):
        return jsonify({"error": {"code": e.code, "message": str(e)}}), 500
    
    @app.errorhandler(500)
    def handle_unexpected(e):
        return jsonify({"error": {"code": "INTERNAL", "message": "Unexpected error"}}), 500
    
    return app
```

## Rules

- DomainError subclasses propagate from services — never catch and
  re-raise as `HTTPException` or `abort()` in service code.
- Route handlers let DomainError propagate to the registered handlers.
- `abort(404)` is for framework-level 404s (route not found); business
  404s raise `NotFoundError`.
- Error responses MUST use the canonical envelope:
  `{"error": {"code": ..., "message": ..., "context": ...}}`
- Never leak stack traces in production — the 500 handler returns a
  generic message; log the full trace server-side.

## Anti-Patterns

- `try/except DomainError: abort(400)` in route code — let it propagate
- Returning raw strings or non-envelope dicts from error handlers
- Using `abort()` for business logic errors — reserve for HTTP framework errors
- Catching `Exception` broadly — catch specific DomainError subclasses