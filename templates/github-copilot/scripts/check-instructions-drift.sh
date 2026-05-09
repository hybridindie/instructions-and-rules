#!/bin/bash
set -euo pipefail

# Cross-harness drift checker for Copilot + Claude side.
# Validates that .github/instructions/*.instructions.md bodies match .claude/rules/
# Uses templates/_shared/mirror-pairs.json as the source of truth.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MIRROR_PAIRS_JSON="$SCRIPT_DIR/../templates/_shared/mirror-pairs.json"

STRICT=0
for arg in "$@"; do
  case "$arg" in
    --strict) STRICT=1 ;;
  esac
done

if [[ ! -f "$MIRROR_PAIRS_JSON" ]]; then
  echo "ERROR: mirror-pairs.json not found at $MIRROR_PAIRS_JSON"
  exit 1
fi

DRIFT=0

# Use jq if available, otherwise python3
if command -v jq >/dev/null 2>&1; then
  ENTRIES=$(jq -c '.entries[]' "$MIRROR_PAIRS_JSON")
else
  ENTRIES=$(python3 -c "
import json, sys
with open('$MIRROR_PAIRS_JSON') as f:
    data=json.load(f)
for e in data.get('entries',[]):
    print(json.dumps(e))
")
fi

while IFS= read -r entry; do
  if command -v jq >/dev/null 2>&1; then
    claude_file=$(echo "$entry" | jq -r '.claude_file')
    copilot_file=$(echo "$entry" | jq -r '.copilot_file')
  else
    claude_file=$(echo "$entry" | python3 -c 'import sys,json; print(json.load(sys.stdin).get("claude_file",""))')
    copilot_file=$(echo "$entry" | python3 -c 'import sys,json; print(json.load(sys.stdin).get("copilot_file",""))')
  fi

  claude_path="$SCRIPT_DIR/../../.claude/rules/$claude_file"
  copilot_path="$SCRIPT_DIR/../../.github/instructions/$copilot_file"

  if [[ ! -f "$claude_path" || ! -f "$copilot_path" ]]; then
    if [[ $STRICT -eq 1 ]]; then
      echo "FAIL: Missing file(s) for pair $claude_file <-> $copilot_file"
      DRIFT=$((DRIFT + 1))
    else
      echo "SKIP: Missing file(s) for pair $claude_file <-> $copilot_file"
    fi
    continue
  fi

  # Extract body
  claude_body=$(awk '/^---$/{if (++count == 2) nextfile} count >= 2' "$claude_path")
  copilot_body=$(awk '/^---$/{if (++count == 2) nextfile} count >= 2' "$copilot_path")

  if [[ "$claude_body" != "$copilot_body" ]]; then
    # Show first differing lines for quick diagnosis
    echo "DRIFT: $claude_file <-> $copilot_file"
    if command -v diff >/dev/null 2>&1; then
      diff -u <(echo "$claude_body") <(echo "$copilot_body") | head -20 || true
    fi
    DRIFT=$((DRIFT + 1))
  fi
done <<< "$ENTRIES"

if [[ $DRIFT -gt 0 ]]; then
  echo "FAIL: $DRIFT mirror pair(s) have drifted."
  echo "Run 'bash templates/scripts/bootstrap.sh ...' to re-render mirrors."
  exit 1
fi

echo "PASS: All mirrors in sync."
