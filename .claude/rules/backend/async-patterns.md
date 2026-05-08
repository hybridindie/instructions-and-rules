---
paths:
  - "backend/src/libs/**/*.py"
  - "backend/app/**/*.py"
---

# Async-First & Typed Interfaces (Article V)

All backend services must use async/await with Pydantic-typed interfaces.

## MUST

- Inject DB/cache/network clients; prohibit global connection singletons
- Provide Pydantic models for request/response boundaries
- No blocking synchronous I/O inside `async def` (wrap unavoidable legacy via executor with comment)
- No shared mutable state across requests - stateless functions or DI only
- External I/O (HTTP/DB/cache/message bus) must set explicit timeouts
- Background processing: native asyncio + pgmq for queues + LISTEN/NOTIFY for real-time
- No Celery/Redis/Valkey without AWG approval
- Batch-process large datasets asynchronously — no synchronous loops over unbounded collections (#326)
- Multi-step workflows that must be atomic: use outbox/saga pattern, not fire-and-forget (#336)

## SHOULD

- Injectable clock/time provider for deterministic tests
- Retries: up to 3 with exponential backoff starting at 200ms (with jitter)
- Explicit concurrency strategies (gather, semaphore) with comments

## Concurrency & Atomicity

Read-then-write patterns on shared database state are a race condition. Under concurrent requests, increments get lost, counts under-report, and rate limits can be bypassed.

MUST:
- Use atomic database operations for check-and-mutate workflows: `INSERT ... ON CONFLICT DO UPDATE`, Postgres RPC, or advisory locks — never SELECT-then-UPDATE in application code
- Counter increments (`success_count`, `failure_count`, `request_count`) MUST use `SET col = col + 1` server-side — never read the current value, add 1 in Python, and write it back
- JSONB partial updates on concurrent-write paths MUST use server-side `jsonb_set()` or an RPC — never read the full document, merge in Python, and write the whole document back
- When a new UNIQUE constraint makes an existing index redundant, drop the old index in the same migration

SHOULD:
- Prefer a single Postgres RPC over multiple round-trips when the operation requires atomicity (e.g., rate-limit check-and-increment)
- Document concurrency assumptions in docstrings when a method is safe only under single-writer semantics

## ANTI-PATTERNS

- Synchronous HTTP/DB clients inside async code
- CPU-bound loops in async code (offload to worker/task queue)
- Mutable module-level lists/dicts for request-scoped data
- Read-then-write (SELECT + UPDATE) for counters or rate limits — loses increments under concurrency (#891, #898, #901)
- Application-side JSONB merge for concurrent-write paths — concurrent updates to different keys overwrite each other (#891)
- Creating event loops at import time (`asyncio.new_event_loop()` + `set_event_loop()` in module scope) — mutates thread state, causes test cross-talk (#888)
