---
description: "Article compliance reviewer for the genesis repo. Reviews a PR or code change for compliance with Constitutional Articles I–IX. Flags violations, suggests fixes, verifies checklist items."
mode: subagent
permission:
  edit: deny
  bash: deny
---

Read and follow the complete agent definition at `templates/_shared/agents/article-compliance-reviewer.md`.
That file is the canonical source; this wrapper is a thin pointer. Substitute
`{{PROJECT_NAME}}` with "instructions-and-rules" when interpreting the instructions.