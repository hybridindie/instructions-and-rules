---
name: install-harness
description: Install or update the AI harness in a target project. Fetches the genesis repo if needed, inspects the project stack, infers the right bootstrap flags (omitting frontend when absent, selecting the correct profile), renders via bootstrap.sh, and reports what was installed.
model: sonnet
color: green
argument-hint: "Optional: absolute path to the target project (default: current directory)"
---

Read and follow the complete instructions at `.agents/skills/bootstrap-harness.md` —
the full flow (locate/fetch genesis, identify target, discover, plan review, render,
validate, report) and the update path. Treat the argument below as the target
`output-dir` (default: current directory).

$ARGUMENTS
