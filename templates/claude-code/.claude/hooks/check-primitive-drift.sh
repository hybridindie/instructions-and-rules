#!/bin/bash
set -euo pipefail

# Check that .claude/rules/ and .github/instructions/ mirrors have identical body content.
# Reads mirror pairs from templates/_shared/mirror-pairs.json (single source of truth).

MIRROR_PAIRS_JSON="templates/_shared/mirror-pairs.json"

if [[ ! -f "$MIRROR_PAIRS_JSON" ]]; then
  # Fallback: look relative to script location
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  MIRROR_PAIRS_JSON="$SCRIPT_DIR/../../../templates/_shared/mirror-pairs.json"
fi

if [[ ! -f "$MIRROR_PAIRS_JSON" ]]; then
  echo "ERROR: mirror-pairs.json not found at $MIRROR_PAIRS_JSON"
  exit 1
fi

DRIFT=0

# Use jq if available, otherwise python3
if command -v jq > /dev/null 2>&1; then
  ENTRIES=$(jq -c '.entries[]' "$MIRROR_PAIRS_JSON")
else
  ENTRIES=$(python3 -c "
import json, sys
with open('$MIRROR_PAIRS_JSON') as f:
    data = json.load(f)
for entry in data.get('entries', []):
    print(json.dumps(entry))
")
fi

while IFS= read -r entry; do
  if command -v jq > /dev/null 2>&1; then
    claude_file=$(echo "$entry" | jq -r '.claude_file')
    copilot_file=$(echo "$entry" | jq -r '.copilot_file')
  else
    claude_file=$(echo "$entry" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('claude_file',''))")
    copilot_file=$(echo "$entry" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('copilot_file',''))")
  fi

  claude_path=".claude/rules/$claude_file"
  copilot_path=".github/instructions/$copilot_file"

  if [[ ! -f "$claude_path" || ! -f "$copilot_path" ]]; then
    echo "SKIP: Missing file(s) for pair .claude/rules/$claude_file <-> .github/instructions/$copilot_file"
    continue
  fi

  # Extract body (everything after the second --- frontmatter delimiter)
  claude_body=$(awk '/^---$/{if (++count == 2) nextfile} count >= 2' "$claude_path")
  copilot_body=$(awk '/^---$/{if (++count == 2) nextfile} count >= 2' "$copilot_path")

  if [[ "$claude_body" != "$copilot_body" ]]; then
    echo "DRIFT: .claude/rules/$claude_file <-> .github/instructions/$copilot_file"
    DRIFT=$((DRIFT + 1))
  fi
done <<< "$ENTRIES"

if [[ $DRIFT -gt 0 ]]; then
  echo "FAIL: $DRIFT mirror pair(s) have drifted."
  exit 1
fi

echo "PASS: All mirrors in sync."
