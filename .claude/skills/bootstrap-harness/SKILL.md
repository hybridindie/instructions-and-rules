---
name: bootstrap-harness
description: Scan a project, interview the user about unknowns, and generate a complete AI harness (Copilot + Claude + Opencode) with Constitutional Articles I–IX
user-invocable: true
disable-model-invocation: true
arguments:
  - name: output-dir
    description: "Directory to write the harness into (default: current directory)"
    required: false
---

Read and follow the complete instructions at `.agents/skills/bootstrap-harness.md` —
all five phases (discovery, interview, render, validation, report) and the rules.

Render the harness into the following output directory (default: current directory):

$ARGUMENTS
