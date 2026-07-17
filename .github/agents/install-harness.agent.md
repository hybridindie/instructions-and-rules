---
name: install-harness
description: Install or update the AI harness in a target project. Fetches the genesis repo if needed, inspects the project stack, infers the right bootstrap flags (omitting frontend when absent, selecting the correct profile), renders via bootstrap.sh, and reports what was installed.
argument-hint: "Optional: absolute path to the target project (default: current directory)"
---

Read and follow the complete instructions at `.agents/skills/bootstrap-harness.md` —
the full flow (locate/fetch genesis, identify target, discover, plan review, render,
validate, report) and the update path. Treat the provided argument as the target
`output-dir` (default: current directory).

If you cannot run shell commands directly, show the user each command and wait for
them to run it and paste the output before continuing.
