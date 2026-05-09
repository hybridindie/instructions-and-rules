---
description: Validate a {{DB_PROVIDER}} SQL migration against sql-standards.md
---

Validate a migration file against the checklist in `.opencode/rules/database/sql-standards.md`.

## Steps

1. Read migration file.
2. Check each checklist item (TEXT not VARCHAR, no ENUM, FK indexes, etc.).
3. Report violations with line numbers.
4. If clean, report: **MIGRATION VALID**.
