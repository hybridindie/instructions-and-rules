---
description: "Use when editing Supabase infrastructure, repository access patterns, database dependency wiring, or database architecture docs."
applyTo: "supabase/**, backend/src/libs/**/repositories/**, backend/src/libs/**/repository.py, backend/app/core/dependencies*.py, backend/docs/DATABASE_ARCHITECTURE.md"
---

# PostgreSQL-Only Infrastructure (Article V)

PostgreSQL 17 is the single infrastructure component for all data and messaging.

## Extensions & Features

- **pgvector** - Vector embeddings for AI/ML
- **pgmq** - Message queues (guaranteed "exactly once" delivery)
- **LISTEN/NOTIFY** - Real-time event streaming (8KB payload limit)
- **HSTORE + UNLOGGED tables** - Cache, sessions, rate limiting

## MUST

- Use repository pattern to isolate database-specific logic from business logic
- No direct SQL in business logic - use Supabase client or repository abstraction
- UNLOGGED tables for ephemeral data (cache, sessions) - faster writes, acceptable data loss on crash
- Cache operations via HSTORE-based tables (app_cache, app_sessions, rate_limits) with automatic expiration
- All DB operations via Supabase client (`app/core/dependencies.get_supabase`)
- New migrations in `supabase/migrations/*.sql`
- Keep LISTEN/NOTIFY payloads under 8KB; store larger data in tables and send keys

## Supabase Repositories

New repositories belong in their service library (`src/libs/<service>/repository.py` or `src/libs/<service>/repositories/`), not in `app/repositories/`.

### Legacy (`app/repositories/`)
- `CreatorSupabaseRepository` - Creator CRUD
- `PlatformConnectionSupabaseRepository` - Platform connections
- `MetricsSupabaseRepository` - Metrics/analytics
- `SchedulerSupabaseRepository` - Content scheduling
- `AgencySupabaseRepository` - Agency management
- `CommentSupabaseRepository` - Instagram comments
- `SupabaseOnboardingRepository` - Onboarding flows
- `FanSegmentSupabaseRepository` - Fan segmentation

### Service-library repos (`src/libs/`)
- `SupabaseRepository[T]` (`database/`) - Generic base class
- `SupabaseSessionRepository` (`ai_coach/`) - AI Coach sessions
- `SupabaseVivaRepository` (`viva_agents/`) - VI creation sessions
- `VIImportRepository` (`vi_import/`) - VI import sessions
- `WorkflowRepository` (`workflow_engine/`) - Workflow definitions/runs
- `SupabaseStrategyRepository` (`plateau_breaker/`) - Growth strategies
- `SupabaseMetricSnapshotRepository` (`plateau_breaker/`) - Metric snapshots
- `SupabaseEffectivenessRepository` (`plateau_breaker/`) - Strategy effectiveness
- `AnalyticsEventsRepository` (`analytics_engine/`) - Analytics events
- `ContentModerationRepository` (`admin_service/`) - Content moderation
- `UserAdminRepository` (`admin_service/`) - Admin user management
- `AuditRepository` (`admin_service/`) - Audit logging
- `SettingsRepository` (`admin_service/`) - Admin settings
- `AnnouncementRepository` (`admin_service/`) - Announcements
- `CredentialsRepository` (`onlyfans_integration/`) - OnlyFans credentials
- `SubscriberRepository` (`onlyfans_integration/`) - OnlyFans subscribers
- `ChallengeRepository` (`onlyfans_integration/`) - OnlyFans challenges
- `ContentRepository` (`onlyfans_integration/`) - OnlyFans content
- `AnalyticsRepository` (`onlyfans_integration/`) - OnlyFans analytics
