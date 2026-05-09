---
paths:
  - "{{BACKEND_PATH}}/src/libs/**/*.py"
  - "{{BACKEND_PATH}}/app/**/*.py"
---

# Async-First & Typed Interfaces (Article V)

All backend services must use async/await with Pydantic-typed interfaces.

## MUST

- Inject DB/cache/network clients; prohibit global connection singletons
- Provide Pydantic models for request/response boundaries
- No blocking synchronous I/O inside `async def` (wrap unavoidable legacy via executor with comment)
- No shared mutable state across requests — stateless functions or DI only
- External I/O (HTTP/DB/cache/message bus) must set explicit timeouts
- Background processing: native asyncio + database queues + LISTEN/NOTIFY for real-time
- No Celery/Redis/Valkey without explicit approval
- Batch-process large datasets asynchronously — no synchronous loops over unbounded collections
- Multi-step workflows that must be atomic: use outbox/saga pattern, not fire-and-forget

## SHOULD

- Injectable clock/time provider for deterministic tests
- Retries: up to 3 with exponential backoff starting at 200ms (with jitter)
- Explicit concurrency strategies (gather, semaphore) with comments

## Concurrency & Atomicity

Read-then-write patterns on shared database state are a race condition.

MUST:
- Use atomic database operations for check-and-mutate workflows: `INSERT ... ON CONFLICT DO UPDATE`, database RPC, or advisory locks — never SELECT-then-UPDATE in application code
- Counter increments MUST use `SET col = col + 1` server-side — never read, add 1 in Python, write back
- JSONB partial updates on concurrent-write paths MUST use server-side `jsonb_set()` or an RPC
- When a new UNIQUE constraint makes an existing index redundant, drop the old index in the same migration

SHOULD:
- Prefer a single database RPC over multiple round-trips when the operation requires atomicity
- Document concurrency assumptions in docstrings when a method is safe only under single-writer semantics

## ANTI-PATTERNS

- Synchronous HTTP/DB clients inside async code
- CPU-bound loops in async code (offload to worker/task queue)
- Mutable module-level lists/dicts for request-scoped data
- Read-then-write (SELECT + UPDATE) for counters or rate limits
- Application-side JSONB merge for concurrent-write paths
- Creating event loops at import time
