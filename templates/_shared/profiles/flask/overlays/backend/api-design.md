---
description: "Flask API Design: Blueprints, validation, and response envelopes"
applyTo: "{{BACKEND_PATH}}/app/**/*.py, {{BACKEND_PATH}}/src/libs/**/*.py"
---

# API Contract & Documentation (Article VI — Flask Variant)

## Route Design

- Routes are thin: parse request, call service, serialize response, handle
  errors. No business logic.
- Use Blueprints for domain grouping: `app/api/<domain>.py` defines one
  blueprint per domain.
- Register blueprints in the application factory with URL prefixes:
  `app.register_blueprint(bp, url_prefix="/api/v1/items")`

## Request Validation

Flask has no built-in Pydantic integration. Options (in order of preference):

1. **`flask-smorest`** (recommended) — adds OpenAPI spec generation and
   Marshmallow schema validation to Flask.
2. **Manual validation in the service layer** — accept raw `request.json`,
   validate in the service, raise `ValidationError` on failure.
3. **Pydantic in the service layer** — define Pydantic models for input/output,
   validate `request.get_json()` against them before processing.

Never trust unvalidated request data. Even with manual validation, validate
at the boundary (route handler or service entry), not deep in business logic.

## Response Envelope

Use the canonical envelope (Article IV):

```python
# Success
return jsonify({"data": result}), 200

# Error (via error handler)
return jsonify({"error": {"code": "NOT_FOUND", "message": "Item not found"}}), 404
```

## Documentation

- Use `flask-smorest` for automatic OpenAPI spec generation, OR
- Maintain an OpenAPI spec manually in `docs/openapi.yaml`
- Every route MUST have a docstring describing the endpoint, params, and
  response shape

## Anti-Patterns

- Returning raw `dict` without the `{"data": ...}` / `{"error": ...}` envelope
- Inline business logic in `@bp.route` handlers
- Accessing `request.json` deep in library code — validate at the boundary
- Using `jsonify` inside library services — serialization belongs in the route