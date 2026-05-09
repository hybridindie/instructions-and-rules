---
name: create-migration
description: Scaffold a {{DB_PROVIDER}} SQL migration compliant with sql-standards.md
user-invocable: true
disable-model-invocation: true
arguments:
  - name: description
    description: "Migration description in snake_case"
    required: true
  - name: tables
    description: "Comma-separated list of tables"
    required: true
---

# Create Migration

Generate a SQL migration file compliant with `.opencode/rules/database/sql-standards.md`.

## Steps

1. Filename: `supabase/migrations/{timestamp}_{description}.sql`
2. Follow checklist: TEXT not VARCHAR, no ENUM, FK indexes, updated_at trigger, schema-qualified names.
3. Include DOWN section for rollback.

## Rules

- Never use VARCHAR or ENUM.
- Always schema-qualify with `public.`.
- Always include ON DELETE on FKs.
