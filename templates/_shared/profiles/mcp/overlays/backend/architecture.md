---
description: "MCP Server Architecture: Tools, Prompts, Resources, and Context"
applyTo: "{{BACKEND_PATH}}/src/libs/**/*.py, {{BACKEND_PATH}}/app/**/*.py"
---

# Architecture: MCP Server (Library-First)

Replace FastAPI-specific guidance with MCP semantics while keeping the library-first principle intact.

## Article I (Restated): Library-First for MCP

All feature code lives in `{{BACKEND_PATH}}/src/libs/<service>/`.
Zero business logic in `@mcp.tool()` or `@mcp.prompt()` handlers.

## Article II (Restated): Service Isolation

- Use dependency injection for DB / HTTP / config clients
- Return typed Pydantic models (not raw dicts)
- No `mcp.server` imports inside library code

## MCP Conventions

- **Tools**: Expose deterministic, sandboxed functions via `@mcp.tool()`
- **Prompts**: Templated system/user messages via `@mcp.prompt()`
- **Resources**: External data URIs via `@mcp.resource()`
- **Context**: Use `mcp.server.Context` for cancellation and progress, never globals

## Article V: Async-First

MCP servers must be fully async. All `@mcp.tool()` handlers are `async def`.
Never use `asyncio.run()` internally; the server runtime manages the loop.

## API Design Mapping (FastAPI → MCP)

| FastAPI Concept | MCP Equivalent |
|-----------------|----------------|
| `@app.get("/items")` | `@mcp.tool()` with descriptive name |
| `response_model=ItemOut` | Return typed Pydantic model (validated by SDK) |
| `Depends(get_db)` | DI via constructor or context (runtime-injected) |
| OpenAPI docs | Automatic tool schema exposed to clients |
| Route handlers | Tool prompt resource handlers (thin boundary) |
| Request/Response | Tool `args` dict + return value |

## Anti-Patterns

- Hardcoding server lifecycle inside a library function
- Using `threading` or `subprocess` inside a tool without async wrapping
- Storing state in module-level variables (MCP servers may be long-lived)
- Returning raw `dict` instead of Pydantic models (breaks client type safety)
