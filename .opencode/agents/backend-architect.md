---
description: "Backend architect router for the genesis repo. Invoke for backend design work — new API routes, service libraries, repository patterns, async workflows. Assumes the project's constitutional articles."
mode: subagent
permission:
  edit: deny
  bash: deny
---

Read and follow the complete agent definition at `templates/_shared/agents/backend-architect.md`.
That file is the canonical source; this wrapper is a thin pointer. Substitute
`{{PROJECT_NAME}}` with "instructions-and-rules", `{{BACKEND_PATH}}` with the
relevant backend path, and `{{DB_PROVIDER}}` with "supabase" when interpreting
the instructions.