---
paths:
  - "supabase/migrations/**"
  - "supabase/seed.sql"
---

# SQL Standards: Schema Design & Migrations

## Data Types

MUST:
- `TEXT` for all string columns — never `VARCHAR(n)`
- `TEXT NOT NULL CHECK (col = ANY(ARRAY[...]))` for status/category columns — never `CREATE TYPE ... AS ENUM`
- `UUID` with `DEFAULT gen_random_uuid()` for primary keys — never `uuid_generate_v4()`
- `TIMESTAMPTZ` for all temporal columns — never `TIMESTAMP` without time zone
- `NUMERIC(p,s)` for money and precise values — never `FLOAT`, `REAL`, or `DOUBLE PRECISION`
- `JSONB` for semi-structured data — never `JSON`
- `INTEGER` or `BIGINT` for counts — never `SMALLINT` unless storage-critical

## Naming

Tables:
- `snake_case`, plural (`creators`, `fan_profiles`, `agency_members`)

Columns:
- `snake_case`, no abbreviations (`description` not `desc`, `configuration` not `config`)
- FK columns: `_id` suffix, singular parent table name (`creator_id`, `agency_id`)
- Timestamps: `_at` suffix (`created_at`, `deleted_at`, `measured_at`)
- URLs: `_url` suffix (`logo_url`, `avatar_url`)
- Booleans: `is_` or `has_` prefix (`is_active`, `has_verified`)
- Counts: `_count` suffix (`follower_count`, `post_count`)
- JSON columns: `_data` or `_metadata` suffix (`metrics_data`, `score_metadata`)

Constraints and indexes:
- CHECK constraints: `{table}_{column}_check`
- Indexes: `idx_{table}_{columns}`

## Table Structure

MUST:
- Every table: `id UUID DEFAULT gen_random_uuid() PRIMARY KEY`
- Every table: `created_at TIMESTAMPTZ DEFAULT now()` and `updated_at TIMESTAMPTZ DEFAULT now()`
- `updated_at` must have a trigger to auto-set on UPDATE
- Use `CREATE TABLE IF NOT EXISTS`

## Indexes

MUST:
- Every FK column gets a corresponding index
- No duplicate indexes — a composite index on `(a, b)` already covers queries on `a` alone
- Don't create indexes on columns already covered by a UNIQUE constraint

SHOULD:
- Composite index column order: highest-selectivity column first

## Constraints

MUST:
- FKs use `REFERENCES` with explicit `ON DELETE` behavior (`CASCADE`, `SET NULL`, or `RESTRICT`)
- `NOT NULL` on every column unless NULL has a defined semantic meaning
- CHECK constraints for value validation — prefer over application-level validation

## Schema Qualification

MUST:
- Always schema-qualify table and function references in migrations: `public.table_name`, `public.function_name()`
- Never rely on `search_path` — it can differ between migration runners, `supabase db reset`, and production

## RPC / Function Standards

MUST:
- Validate inputs at the top of every RPC function — `RAISE EXCEPTION ... USING ERRCODE = '22023'` for NULL, empty, zero, or negative values that would cause division-by-zero or silent corruption
- Restrict `EXECUTE` grants to `service_role` unless the RPC is explicitly designed for client-side use. Default: `REVOKE ALL FROM PUBLIC, anon, authenticated; GRANT EXECUTE TO service_role;`
- When `DROP FUNCTION` + `CREATE FUNCTION` is used, re-apply all grants and ownership in the same migration — dropping a function drops its privileges

## UNLOGGED Tables

SHOULD:
- Prefer `TRUNCATE` over `DELETE` for bulk resets on UNLOGGED tables — avoids row-by-row MVCC overhead and conveys intent

## Migration Checklist

Before committing any `.sql` migration, verify:

- [ ] No `VARCHAR` — use `TEXT`
- [ ] No `ENUM` types — use `TEXT + CHECK`
- [ ] All FK columns have indexes
- [ ] No duplicate indexes (a UNIQUE constraint or composite index on `(a, b, c)` covers queries on `(a)` and `(a, b)` — drop narrower indexes it supersedes)
- [ ] Table has `created_at` and `updated_at` with `TIMESTAMPTZ`
- [ ] `updated_at` has a `BEFORE UPDATE` trigger using `public.update_updated_at_column()`
- [ ] UUIDs use `gen_random_uuid()` not `uuid_generate_v4()`
- [ ] Timestamps use `TIMESTAMPTZ` not `TIMESTAMP`
- [ ] Boolean columns use `is_`/`has_` prefix
- [ ] Count columns use `_count` suffix
- [ ] FK columns use `_id` suffix
- [ ] CHECK constraints named `{table}_{column}_check`
- [ ] `ON DELETE` specified on all FK constraints
- [ ] All table/function references are schema-qualified (`public.`)
- [ ] RPC functions validate inputs and restrict grants to `service_role`
- [ ] New UNIQUE constraints: check for and drop any now-redundant narrower indexes
- [ ] All pgmq queues referenced by backend handlers are created (check `backend/app/worker/handlers/`)

ANTI-PATTERNS (BLOCKING):
- `VARCHAR(n)` columns — use `TEXT`, optionally with CHECK for length
- `CREATE TYPE ... AS ENUM` — use `TEXT + CHECK` for evolvability
- FK columns without indexes — causes slow joins and deletes
- `TIMESTAMP` without time zone — always use `TIMESTAMPTZ`
- Missing `updated_at` trigger — stale timestamps mislead debugging
- Duplicate indexes — wasted storage and write overhead
- Unqualified table/function names — breaks under non-default `search_path`
- `GRANT EXECUTE TO anon, authenticated` on RPCs that only the backend calls — widens attack surface for bucket poisoning/DoS
- Missing input validation in RPC functions — division by zero or NULL propagation hides behind caller's fail-open path
- Partial pgmq queue creation — `pgmq.send` returns `42P01` on fresh DB when queues are missing
