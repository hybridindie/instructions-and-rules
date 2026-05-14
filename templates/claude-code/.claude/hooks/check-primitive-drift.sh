#!/bin/bash
set -euo pipefail

# Check that mirrored primitives have identical body content between Claude, Copilot, and OpenCode.
# Checks five types of pairs from templates/_shared/mirror-pairs.json:
#   entries         → .claude/rules/       <-> .github/instructions/
#   agent_entries   → .claude/agents/      <-> .github/agents/
#   command_entries → .claude/commands/    <-> .github/prompts/
#   agent_entries   → .claude/agents/      <-> .opencode/agents/   (opencode_dir entries)
#   command_entries → .claude/commands/    <-> .opencode/commands/ (opencode_dir entries)

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

# ---------------------------------------------------------------------------
# Helper: extract body (text after second --- delimiter)
# ---------------------------------------------------------------------------
extract_body() {
  awk '/^---$/{if (++count == 2) nextfile} count >= 2' "$1"
}

# ---------------------------------------------------------------------------
# 1. Article mirror pairs: .claude/rules/ <-> .github/instructions/
# ---------------------------------------------------------------------------
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

  claude_body=$(extract_body "$claude_path")
  copilot_body=$(extract_body "$copilot_path")

  if [[ "$claude_body" != "$copilot_body" ]]; then
    echo "DRIFT: .claude/rules/$claude_file <-> .github/instructions/$copilot_file"
    DRIFT=$((DRIFT + 1))
  fi
done <<< "$ENTRIES"

# ---------------------------------------------------------------------------
# 2. Agent mirror pairs: .claude/agents/ <-> .github/agents/
# ---------------------------------------------------------------------------
if command -v jq > /dev/null 2>&1; then
  AGENT_ENTRIES=$(jq -c '.agent_entries[]?' "$MIRROR_PAIRS_JSON" 2>/dev/null || echo "")
else
  AGENT_ENTRIES=$(python3 -c "
import json, sys
with open('$MIRROR_PAIRS_JSON') as f:
    data = json.load(f)
for entry in data.get('agent_entries', []):
    print(json.dumps(entry))
")
fi

if [[ -n "$AGENT_ENTRIES" ]]; then
  while IFS= read -r entry; do
    [[ -z "$entry" ]] && continue
    if command -v jq > /dev/null 2>&1; then
      source_file=$(echo "$entry" | jq -r '.source_file')
      copilot_file=$(echo "$entry" | jq -r '.copilot_file')
    else
      source_file=$(echo "$entry" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('source_file',''))")
      copilot_file=$(echo "$entry" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('copilot_file',''))")
    fi

    claude_path=".claude/agents/$source_file"
    copilot_path=".github/agents/$copilot_file"

    if [[ ! -f "$claude_path" || ! -f "$copilot_path" ]]; then
      echo "SKIP: Missing file(s) for agent pair .claude/agents/$source_file <-> .github/agents/$copilot_file"
      continue
    fi

    claude_body=$(extract_body "$claude_path")
    copilot_body=$(extract_body "$copilot_path")

    if [[ "$claude_body" != "$copilot_body" ]]; then
      echo "DRIFT: .claude/agents/$source_file <-> .github/agents/$copilot_file"
      DRIFT=$((DRIFT + 1))
    fi
  done <<< "$AGENT_ENTRIES"
fi

# ---------------------------------------------------------------------------
# 3. Command mirror pairs: .claude/commands/ <-> .github/prompts/
# ---------------------------------------------------------------------------
if command -v jq > /dev/null 2>&1; then
  COMMAND_ENTRIES=$(jq -c '.command_entries[]?' "$MIRROR_PAIRS_JSON" 2>/dev/null || echo "")
else
  COMMAND_ENTRIES=$(python3 -c "
import json, sys
with open('$MIRROR_PAIRS_JSON') as f:
    data = json.load(f)
for entry in data.get('command_entries', []):
    print(json.dumps(entry))
")
fi

if [[ -n "$COMMAND_ENTRIES" ]]; then
  while IFS= read -r entry; do
    [[ -z "$entry" ]] && continue
    if command -v jq > /dev/null 2>&1; then
      source_file=$(echo "$entry" | jq -r '.source_file')
      copilot_file=$(echo "$entry" | jq -r '.copilot_file')
    else
      source_file=$(echo "$entry" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('source_file',''))")
      copilot_file=$(echo "$entry" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('copilot_file',''))")
    fi

    claude_path=".claude/commands/$source_file"
    copilot_path=".github/prompts/$copilot_file"

    if [[ ! -f "$claude_path" || ! -f "$copilot_path" ]]; then
      echo "SKIP: Missing file(s) for command pair .claude/commands/$source_file <-> .github/prompts/$copilot_file"
      continue
    fi

    claude_body=$(extract_body "$claude_path")
    copilot_body=$(extract_body "$copilot_path")

    if [[ "$claude_body" != "$copilot_body" ]]; then
      echo "DRIFT: .claude/commands/$source_file <-> .github/prompts/$copilot_file"
      DRIFT=$((DRIFT + 1))
    fi
  done <<< "$COMMAND_ENTRIES"
fi

# ---------------------------------------------------------------------------
# 4. OpenCode agent mirror pairs: .claude/agents/ <-> .opencode/agents/
# ---------------------------------------------------------------------------
if command -v jq > /dev/null 2>&1; then
  OC_AGENT_ENTRIES=$(jq -c '.agent_entries[]? | select(.opencode_dir)' "$MIRROR_PAIRS_JSON" 2>/dev/null || echo "")
else
  OC_AGENT_ENTRIES=$(python3 -c "
import json, sys
with open('$MIRROR_PAIRS_JSON') as f:
    data = json.load(f)
for entry in data.get('agent_entries', []):
    if entry.get('opencode_dir'):
        print(json.dumps(entry))
")
fi

if [[ -n "$OC_AGENT_ENTRIES" ]]; then
  while IFS= read -r entry; do
    [[ -z "$entry" ]] && continue
    if command -v jq > /dev/null 2>&1; then
      source_file=$(echo "$entry" | jq -r '.source_file')
      opencode_dir=$(echo "$entry" | jq -r '.opencode_dir')
    else
      source_file=$(echo "$entry" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('source_file',''))")
      opencode_dir=$(echo "$entry" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('opencode_dir',''))")
    fi

    claude_path=".claude/agents/$source_file"
    opencode_path="$opencode_dir/$source_file"

    if [[ ! -f "$claude_path" || ! -f "$opencode_path" ]]; then
      echo "SKIP: Missing file(s) for opencode agent pair .claude/agents/$source_file <-> $opencode_path"
      continue
    fi

    claude_body=$(extract_body "$claude_path")
    opencode_body=$(extract_body "$opencode_path")

    if [[ "$claude_body" != "$opencode_body" ]]; then
      echo "DRIFT: .claude/agents/$source_file <-> $opencode_path"
      DRIFT=$((DRIFT + 1))
    fi
  done <<< "$OC_AGENT_ENTRIES"
fi

# ---------------------------------------------------------------------------
# 5. OpenCode command mirror pairs: .claude/commands/ <-> .opencode/commands/
# ---------------------------------------------------------------------------
if command -v jq > /dev/null 2>&1; then
  OC_COMMAND_ENTRIES=$(jq -c '.command_entries[]? | select(.opencode_dir)' "$MIRROR_PAIRS_JSON" 2>/dev/null || echo "")
else
  OC_COMMAND_ENTRIES=$(python3 -c "
import json, sys
with open('$MIRROR_PAIRS_JSON') as f:
    data = json.load(f)
for entry in data.get('command_entries', []):
    if entry.get('opencode_dir'):
        print(json.dumps(entry))
")
fi

if [[ -n "$OC_COMMAND_ENTRIES" ]]; then
  while IFS= read -r entry; do
    [[ -z "$entry" ]] && continue
    if command -v jq > /dev/null 2>&1; then
      source_file=$(echo "$entry" | jq -r '.source_file')
      opencode_dir=$(echo "$entry" | jq -r '.opencode_dir')
    else
      source_file=$(echo "$entry" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('source_file',''))")
      opencode_dir=$(echo "$entry" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('opencode_dir',''))")
    fi

    claude_path=".claude/commands/$source_file"
    opencode_path="$opencode_dir/$source_file"

    if [[ ! -f "$claude_path" || ! -f "$opencode_path" ]]; then
      echo "SKIP: Missing file(s) for opencode command pair .claude/commands/$source_file <-> $opencode_path"
      continue
    fi

    claude_body=$(extract_body "$claude_path")
    opencode_body=$(extract_body "$opencode_path")

    if [[ "$claude_body" != "$opencode_body" ]]; then
      echo "DRIFT: .claude/commands/$source_file <-> $opencode_path"
      DRIFT=$((DRIFT + 1))
    fi
  done <<< "$OC_COMMAND_ENTRIES"
fi

if [[ $DRIFT -gt 0 ]]; then
  echo "FAIL: $DRIFT mirror pair(s) have drifted."
  exit 1
fi

echo "PASS: All mirrors in sync."
