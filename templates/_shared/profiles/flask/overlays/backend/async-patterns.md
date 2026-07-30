---
description: "Flask Async Patterns: sync-first, background tasks, no event loop"
applyTo: "{{BACKEND_PATH}}/src/libs/**/*.py, {{BACKEND_PATH}}/app/**/*.py"
---

# Async-First & Typed Interfaces (Article V — Flask Variant)

Flask is sync-first. This overlay replaces the FastAPI async-first guidance.

## Sync-First

- Route handlers are synchronous `def` functions, not `async def`.
- Database access uses sync drivers: `psycopg`, `psycopg2`, or the
  `{{DB_PROVIDER}}` sync client. Never `asyncpg`.
- For I/O-bound operations (external API calls, long processing), use:
  1. pgmq background jobs (preferred — Article I compatible)
  2. `concurrent.futures.ThreadPoolExecutor` for CPU-bound parallel work
  3. A task queue only if pgmq is insufficient

## No Event Loop

- Never call `asyncio.run()` inside a Flask route handler.
- Never use `aiohttp` or `httpx.AsyncClient` in sync Flask code — use
  `httpx.Client` (sync) or `requests`.
- If a dependency requires async, wrap it in a background task, not in the
  request path.

## Typed Interfaces

- Service functions use type hints: `def get_items(db: Connection) -> list[Item]:`
- Use `dataclass` or Pydantic models for input/output types in the service
  layer (not for Flask request parsing — see api-design overlay).
- No `Any` returns from service functions — use `Result[T, E]` or
  `tuple[T, ErrorCode | None]`.

## Injection

- Inject dependencies via function arguments, not Flask globals:
  `def get_items(db: Connection) -> list[Item]` not
  `def get_items() -> list[Item]: db = current_app.db`
- In route handlers, resolve dependencies from the app context:
  `db = current_app.extensions["db"]` then pass to the service.

## Anti-Patterns

- `async def` route handlers in a sync Flask app (ASGI mismatch)
- Module-level database connections or app instances
- `time.sleep()` in a request handler — offload to a background task
- Using `g` for business state — `g` is for per-request plumbing only