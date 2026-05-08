#!/usr/bin/env bash
# check-agent-drift.sh
#
# Enforces stack-parity between .claude/ prompt files (agents, skills,
# commands, rules) and CLAUDE.md. Prevents the failure mode we hit when
# .claude/agents/*.md started claiming "TypeScript 6, Vite 8, PostgreSQL 16"
# while CLAUDE.md said "TypeScript 5.9, Vite 7.3, PostgreSQL 17" and the
# agents quietly produced wrong code because nobody was running them.
#
# The check is intentionally narrow: it scans for stack version claims that
# commonly drift (framework + major version) and flags any occurrence in
# .claude/ that contradicts CLAUDE.md. It does NOT try to parse natural
# language — it's a greppable invariant.
#
# Exit codes:
#   0 — no drift detected
#   1 — drift detected (violations printed)

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

if [ ! -f CLAUDE.md ]; then
  echo "check-agent-drift: CLAUDE.md not found at $ROOT/CLAUDE.md" >&2
  exit 1
fi

red()    { printf '\033[0;31m%s\033[0m\n' "$*"; }
green()  { printf '\033[0;32m%s\033[0m\n' "$*"; }
yellow() { printf '\033[0;33m%s\033[0m\n' "$*"; }

violations=0

# Pull authoritative versions from CLAUDE.md. The patterns below match the
# current format; if the format changes, update this block.
authoritative_python=$(grep -oE 'Python [0-9]+\.[0-9]+' CLAUDE.md | head -1)
authoritative_fastapi=$(grep -oE 'FastAPI [0-9]+\.[0-9]+\+?' CLAUDE.md | head -1)
authoritative_postgres=$(grep -oE 'PostgreSQL [0-9]+' CLAUDE.md | head -1)
authoritative_react=$(grep -oE 'React [0-9]+' CLAUDE.md | head -1)
authoritative_typescript=$(grep -oE 'TypeScript [0-9]+\.[0-9]+' CLAUDE.md | head -1)
authoritative_vite=$(grep -oE 'Vite [0-9]+\.[0-9]+' CLAUDE.md | head -1)

# If CLAUDE.md is silent on a stack component, we can't enforce parity for it.
check_parity() {
  local label=$1 authoritative=$2 pattern=$3
  if [ -z "$authoritative" ]; then
    return
  fi

  # Find any occurrence in .claude/**/*.md that matches the framework name
  # followed by a version. Scope explicitly to curated directories —
  # .claude/worktrees/ contains .venv/ with thousands of library matches
  # and must never be scanned. Likewise exclude .claude/projects/ which
  # can hold generated artefacts.
  local hits
  hits=$(
    grep -rn -E "$pattern" \
      --include='*.md' \
      .claude/agents .claude/skills .claude/commands .claude/rules \
      2>/dev/null || true
  )

  if [ -z "$hits" ]; then
    return
  fi

  # Filter to lines whose version doesn't match the authoritative one.
  local drifted=""
  while IFS= read -r line; do
    [ -z "$line" ] && continue
    # Extract the framework+version claim from the line.
    local claim
    claim=$(echo "$line" | grep -oE "$pattern" | head -1)
    if [ -n "$claim" ] && [ "$claim" != "$authoritative" ]; then
      drifted="${drifted}${line}
"
    fi
  done <<< "$hits"

  if [ -n "$drifted" ]; then
    red "DRIFT: $label in .claude/ disagrees with CLAUDE.md"
    yellow "  Authoritative (CLAUDE.md): $authoritative"
    printf '%s' "$drifted" | while IFS= read -r l; do
      [ -n "$l" ] && printf '  %s\n' "$l"
    done
    violations=$((violations + 1))
  fi
}

check_parity "Python version"     "$authoritative_python"     'Python [0-9]+\.[0-9]+'
check_parity "FastAPI version"    "$authoritative_fastapi"    'FastAPI [0-9]+\.[0-9]+\+?'
check_parity "PostgreSQL version" "$authoritative_postgres"   'PostgreSQL [0-9]+'
check_parity "React version"      "$authoritative_react"      'React [0-9]+'
check_parity "TypeScript version" "$authoritative_typescript" 'TypeScript [0-9]+\.[0-9]+'
check_parity "Vite version"       "$authoritative_vite"       'Vite [0-9]+\.[0-9]+'

if [ $violations -gt 0 ]; then
  printf '\n'
  red "check-agent-drift: $violations drift categor(y/ies) found."
  yellow 'Fix the drifted file(s) or update CLAUDE.md if the authoritative version changed.'
  yellow 'Rule: .claude/*.md files that duplicate stack info must be updated in the'
  yellow 'same commit as CLAUDE.md — "test drift is a bug, not a placeholder".'
  exit 1
fi

green "check-agent-drift: all .claude/*.md stack claims match CLAUDE.md."
exit 0
