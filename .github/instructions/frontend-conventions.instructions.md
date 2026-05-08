---
description: "Use when editing frontend React/TypeScript code, Zustand stores, UI components, and frontend test patterns."
applyTo: "frontend/**"
---

# Frontend Conventions

## State Management

- Zustand stores only for client state (auth, analytics, platforms, content)
- Store actions are pure wrappers over service calls; side effects isolated
- No global mutable singletons outside Zustand
- No additional state management libraries unless approved via a documented architecture decision record (ADR) citing performance or scalability reasons

## API Integration

- All API calls through typed service modules - no direct fetch in components
- Service calls return either `data` or `error` envelope
- Error boundaries and typed error envelopes at component boundaries

## Security

- Auth tokens stored in memory (never localStorage for sensitive tokens)
- Sanitize all external inputs; never trust client-side data

## Stack

- React 19 + TypeScript + Vite
- shadcn/ui components + Tailwind CSS
- Vitest + MSW + React Testing Library for tests
- Playwright for E2E
- Zod for schema validation

## Type Safety

- No `as any` casts — use proper generics, type widening, or `as never` for test mocks (#343)
- No `dangerouslySetInnerHTML` or raw `innerHTML` — use DOMPurify or text content (#344)

## Code Hygiene

- No `console.log` in production code — remove or gate behind `import.meta.env.DEV` (#317, #341)
- Zustand stores ≤ 300 lines; split into sub-stores with `immer` middleware when larger (#342)

## Testing

### Coverage Targets

- Security-critical components (auth, session management): 90%+ line coverage (#319)
- Zustand stores: 70%+ line coverage (#333)
- Test stack: Vitest + MSW + React Testing Library; Playwright for E2E

### Suite Health (BLOCKING — no exceptions)

The Vitest suite is a binary signal. Either it is green and trusted, or it
is a liar. A partially-green suite is worse than no suite at all.

- **Zero failing tests may be checked in.** `npx vitest run` on a clean
  checkout MUST exit zero. "Pre-existing failure" is not a defence.
- **Zero unconditional skips may be checked in.** Specifically forbidden in
  Vitest specs (`src/**/__tests__/**`, `tests/unit/**`):
  - `it.skip(...)`, `test.skip(...)`, `describe.skip(...)` declarative forms
  - `.todo` test stubs
  - `xit`, `xdescribe` jasmine-style aliases
  If a test is obsolete, delete it. If the component drifted, update it.
- **Playwright runtime skips are permitted** only inside a conditional
  (`if (!isMobile) { test.skip(...) }`). Unconditional declarative
  `test.skip('title', fn)` is forbidden.
- **Test drift is a bug, not a placeholder.** When you change a component
  prop, aria-label, store field, service signature, or API response shape,
  update the co-owning tests in the same commit.
- **Wall-clock-sensitive assertions MUST use relative dates** (`Date.now()
  - offset`) or `vi.useFakeTimers()`. Hardcoded ISO strings that imply
  "recent" will rot. Past bugs: `tier.test.ts` pinned `grace_expires_at`
  to 2026-04-01; `analytics.test.ts` default-30-day-window used 2026-02-17
  as "recent".
- **Deterministic test infrastructure.** Any randomness (`Math.random`,
  crypto UUIDs where identity matters, etc.) must be seedable or faked.
  Flaky tests are failing tests with extra steps.

### Test Runner Discipline

- **Vitest and Playwright have disjoint test files.** `vite.config.ts`
  MUST set `test.exclude` to include `tests/e2e/**` — otherwise Vitest
  collects Playwright specs and 50+ false failures hide real ones.
- **MSW handler paths are relative.** The shared handlers register
  `/api/...` paths. For them to match, the `apiClient` must issue requests
  against the jsdom origin. `.env.test` MUST set `VITE_API_URL=""` so
  Vite-loaded tests use an empty base URL and handlers match.
- **Module-mock shapes must match real exports.** For icon libraries like
  `lucide-react`, enumerate the subset the component uses — Vitest rejects
  `Proxy`-backed factories. Add new icons explicitly when the component
  grows them; don't try to be clever.

### Mocking Anti-Patterns

- Tests that assert on component text, `aria-label`, store fields, or
  service method signatures that don't exist in the current codebase are
  bugs, not placeholders.
- Wall-clock-dependent assertions without fake timers.
- Proxy-backed module mocks (Vitest rejects them at module-load time).
- Hardcoding `XMLHttpRequest` globals when the component now delegates to
  a service wrapper — mock the service instead.
