---
description: "Scaffold a {{DB_PROVIDER}} SQL migration compliant with sql-standards.md"
---

# Create Migration

Generate a {{DB_PROVIDER}} SQL migration file compliant with `.claude/rules/database/sql-standards.md`.

## Steps

1. Determine the migration filename: `{{DB_PROVIDER}}/migrations/{timestamp}_{description}.sql`
   - Timestamp format: `YYYYMMDDHHMMSS`

2. For each table, generate SQL following the checklist:
   - `CREATE TABLE IF NOT EXISTS public.{table} (...)`
   - `id UUID DEFAULT gen_random_uuid() PRIMARY KEY`
   - `created_at TIMESTAMPTZ DEFAULT now()`
   - `updated_at TIMESTAMPTZ DEFAULT now()`
   - `BEFORE UPDATE` trigger for `updated_at`
   - All string columns: `TEXT` (never `VARCHAR`)
   - Status/category columns: `TEXT NOT NULL CHECK (col = ANY(ARRAY[...]))`
   - FK columns: `{singular_parent}_id UUID REFERENCES public.{parent}(id) ON DELETE {CASCADE|SET NULL|RESTRICT}`
   - FK columns get indexes: `CREATE INDEX idx_{table}_{fk_col} ON public.{table}({fk_col})`
   - CHECK constraints named `{table}_{column}_check`
   - All references schema-qualified with `public.`

3. Include a `DOWN` section at the bottom (commented out) for rollback:
   ```sql
   -- DOWN
   -- DROP TABLE IF EXISTS public.{table} CASCADE;
   ```

4. Validate against the Migration Checklist from sql-standards.md.

## Output

Provide the full migration file content, ready to write to `{{DB_PROVIDER}}/migrations/`.

## Rules

- Never use `VARCHAR` or `ENUM`.
- Always schema-qualify.
- Always include `ON DELETE` on FKs.
- Always include `updated_at` trigger.
- Never create redundant indexes.
