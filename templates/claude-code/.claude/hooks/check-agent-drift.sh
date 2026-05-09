#!/bin/bash
set -euo pipefail

# Check that .claude/agents/*.md and .claude/rules/*.md stack version claims
# match CLAUDE.md (or the canonical tech stack).

ERRORS=0

# Extract stack versions from CLAUDE.md
PYTHON_V=$(grep -oP 'Python \K[0-9.]+' CLAUDE.md | head -1 || echo "")
FASTAPI_V=$(grep -oP 'FastAPI \K[0-9.+]+' CLAUDE.md | head -1 || echo "")
REACT_V=$(grep -oP 'React \K[0-9]+' CLAUDE.md | head -1 || echo "")
TS_V=$(grep -oP 'TypeScript \K[0-9.]+' CLAUDE.md | head -1 || echo "")
VITE_V=$(grep -oP 'Vite \K[0-9.]+' CLAUDE.md | head -1 || echo "")

for f in .claude/agents/*.md .claude/rules/**/*.md; do
  [[ -f "$f" ]] || continue
  # Simple grep for version contradictions (heuristic)
  if grep -q "Python 3\.11" "$f" && [[ "$PYTHON_V" != "3.11" ]]; then
    echo "AGENT-DRIFT: $f claims Python 3.11 but CLAUDE.md says Python $PYTHON_V"
    ERRORS=$((ERRORS + 1))
  fi
  if grep -q "FastAPI 0\.10" "$f" && [[ "$FASTAPI_V" != "0.10"* ]]; then
    echo "AGENT-DRIFT: $f claims FastAPI 0.10 but CLAUDE.md says FastAPI $FASTAPI_V"
    ERRORS=$((ERRORS + 1))
  fi
done

if [[ $ERRORS -gt 0 ]]; then
  echo "FAIL: $ERRORS agent drift issue(s) found."
  exit 1
fi

echo "PASS: Agent versions consistent with CLAUDE.md."
