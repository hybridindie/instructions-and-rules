#!/usr/bin/env bash
# PostToolUse: Warn when a route handler contains direct Supabase/DB queries (Article I violation).
# Routes must be thin wrappers — all DB work belongs in service libraries (backend/src/libs/).

file="${TOOL_INPUT_FILE_PATH:-${TOOL_INPUT_file_path:-}}"

case "$file" in
  */backend/app/api/routes/*.py|*/backend/src/api/routes/*.py) ;;
  *) exit 0 ;;
esac

[ -f "$file" ] || exit 0

# Match Supabase-style query methods on any client variable (supabase, db, client,
# service_db, etc.), not just the two literal names. Routes should never call
# .table()/.rpc()/.from_()/.schema() directly — that work belongs in a service.
db_query_pattern='\b[A-Za-z_][A-Za-z0-9_]*\.(table|rpc|from_|schema)\('

if grep -qE "$db_query_pattern" "$file" 2>/dev/null; then
    violations=$(grep -nE "$db_query_pattern" "$file" 2>/dev/null | head -5)
    echo "ARTICLE-I: $file contains direct Supabase/DB calls in a route handler. Move all DB operations into a service library (backend/src/libs/). Violations:"
    echo "$violations"
fi

exit 0
