---
description: "MCP Server API Design: Tools, Prompts, Resources, and typed interfaces"
applyTo: "{{BACKEND_PATH}}/app/**/*.py, {{BACKEND_PATH}}/src/libs/**/*.py"
---

# API Contract & Documentation (Article VI — MCP Variant)

## Tool Design

Every `@mcp.tool()` handler MUST:
- Accept a typed Pydantic model for arguments
- Return a typed Pydantic model for output
- Document the tool in the docstring (becomes client-facing description)
- Validate all inputs before side effects

```python
from mcp.server import Server
from pydantic import BaseModel

class WeatherIn(BaseModel):
    city: str
    units: str = "metric"

class WeatherOut(BaseModel):
    temperature: float
    description: str

@mcp.tool()
async def get_weather(args: WeatherIn) -> WeatherOut:
    """Fetch current weather for a city."""
    ...
```

## Resource Design

Resources are read-only data URIs. Use `@mcp.resource()` with:
- `uri` template parameter
- Return type: `str` (text) or `bytes` (binary)

## Prompt Design

Prompts are templates for LLM system/user messages. Use `@mcp.prompt()` with:
- Jinja2 or f-string templates
- Optional parameters as Pydantic models

## Error Design

MCP tool errors become structured JSON-RPC errors. Use:
- `mcp_tool_error` code for deterministic tool failures
- `mcp_validation_error` for schema violations
- `mcp_internal_error` for unexpected exceptions

## Anti-Patterns

- Returning raw `dict` from a tool (breaks client type safety)
- Side effects in `@mcp.resource()` handlers
- Using `print()` for operational logging (use structured JSON logs)
