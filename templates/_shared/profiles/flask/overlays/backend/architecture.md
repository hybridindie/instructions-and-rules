---
description: "Flask Server Architecture: Blueprints, services, and library-first"
applyTo: "{{BACKEND_PATH}}/src/libs/**/*.py, {{BACKEND_PATH}}/app/**/*.py"
---

# Architecture: Flask Server (Library-First)

Replace FastAPI-specific guidance with Flask equivalents while keeping the
library-first principle intact.

## Article I (Restated): Library-First for Flask

All feature code lives in `{{BACKEND_PATH}}/src/libs/<service>/`.
Zero business logic in route handlers or blueprint registration code.

## Article II (Restated): Service Isolation

- Use dependency injection for DB / HTTP / config clients (constructor
  injection or Flask's `current_app.config` — never module-level globals)
- Service functions are pure: accept typed arguments, return typed results
- No Flask app object inside library code — pass it or use application context

## Flask Conventions

- **Blueprints** are the unit of route organization (equivalent to FastAPI
  APIRouter). Register blueprints in `app/__init__.py`, define them in
  `app/api/<domain>.py`.
- **Application factory pattern**: `create_app()` returns a configured Flask
  app. Never instantiate at module level.
- **Extensions** (db, mail, etc.) are initialized on the app, not globally.

## Article V: Sync-First (Flask)

Flask route handlers are synchronous by default. Do NOT force async unless
using a WSGI server that supports it (e.g., gevent).

- Use `psycopg` (sync) or `psycopg2` for database access, not `asyncpg`.
- For I/O-bound work, use background tasks (pgmq, Celery with Redis only if
  absolutely necessary) rather than async handlers.
- Never block the event loop — Flask doesn't have one. Use worker threads
  or background queues for long operations.

## API Design Mapping (FastAPI → Flask)

| FastAPI Concept | Flask Equivalent |
|-----------------|------------------|
| `@app.get("/items")` | `@bp.route("/items", methods=["GET"])` |
| `response_model=ItemOut` | Manual serialization via `dataclass` or `pydantic` in the service layer |
| `Depends(get_db)` | `g.db` or `current_app` context, or constructor injection |
| OpenAPI docs (auto) | `flask-smorest` or manual OpenAPI spec |
| `HTTPException(status, detail)` | `abort(status)` or custom error handler |
| Pydantic request model | `flask-smorest` args parsing, or manual validation in the service |

## Anti-Patterns

- Business logic in `@bp.route` handlers — delegate to library services
- Module-level Flask app or db instances — use the factory pattern
- `app.config` accessed inside library code — pass config via DI
- Using `asyncio.run()` inside a sync Flask handler — use background tasks instead