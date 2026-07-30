---
paths:
  - "{{FRONTEND_PATH}}/**"
---

# Frontend Conventions (Next.js Variant)

Replaces the Vite+React conventions for Next.js projects (App Router).

## State Management

- {{STATE_MANAGER}} stores only for client state ({{FRONTEND_STORE_EXAMPLES}})
- Store actions are pure wrappers over service calls; side effects isolated
- No global mutable singletons outside {{STATE_MANAGER}}
- No additional state management libraries without explicit justification
- **Server Components cannot use stores** — stores are client-only. Pass
  server-fetched data as props; hydrate stores in `'use client'` components.

## API Integration

- All API calls through typed service modules — no direct fetch in components
- Service calls return either `data` or `error` envelope
- Error boundaries and typed error envelopes at component boundaries
- **Server Components can fetch data directly** (no service module needed for
  server-side reads), but mutations must go through Server Actions or API routes
- **Server Actions** (`'use server'`) are the preferred mutation path for
  Next.js — they replace traditional POST endpoints for app-internal mutations

## Security

- Auth tokens stored in memory (never localStorage for sensitive tokens)
- Sanitize all external inputs; never trust client-side data
- **`dangerouslySetInnerHTML`** is BLOCKED unless DOMPurify-sanitized (same rule)
- **Server Components have no `window`/`document`** — never reference browser
  APIs in server-rendered code

## Stack

- Next.js (React {{REACT_VERSION}}) + TypeScript
- {{UI_LIBRARY}} components{{#TAILWIND}} + Tailwind CSS{{/TAILWIND}}
- App Router (`app/` directory) — not Pages Router
- Vitest + MSW + React Testing Library for unit/integration tests
- {{E2E_TOOL}} for E2E
{{#ZOD_VALIDATION}}- Zod for schema validation (server-side form parsing, API contracts){{/ZOD_VALIDATION}}

## Routing & Rendering

- **App Router** (`app/` directory): `app/<segment>/page.tsx` for pages,
  `app/<segment>/layout.tsx` for layouts, `app/<segment>/loading.tsx` for
  Suspense fallbacks, `app/<segment>/error.tsx` for error boundaries.
- **Server Components** (default): no `'use client'` directive. Can fetch
  data, access DB/services server-side, never use browser APIs.
- **Client Components** (`'use client'`): interactive, stateful, browser-API
  access. Minimize — push as much as possible to Server Components.
- **Dynamic routes**: `app/<segment>/[id]/page.tsx` — params arrive as props.
- **API routes**: `app/api/<route>/route.ts` — use for external webhooks or
  non-Next.js clients. Prefer Server Actions for internal mutations.

## Type Safety

- No `as any` casts — use proper generics, type widening, or `as never` for test mocks
- No `dangerouslySetInnerHTML` or raw `innerHTML` — use DOMPurify or text content
- **Server/Client boundary**: props passed from Server to Client Components
  must be serializable (no class instances, functions, or Dates — use
  strings/numbers/plain objects)

## Code Hygiene

- No `console.log` in production code — remove or gate behind `process.env.NODE_ENV === 'development'`
- {{STATE_MANAGER}} stores ≤ 300 lines; split into sub-stores with `immer` middleware when larger
- **No `vite.config.ts`** — Next.js uses `next.config.js`/`next.config.ts`/`next.config.mjs`
- **No manual chunk splitting** — Next.js handles code splitting automatically

## Testing

- Security-critical components (auth, session management): 90%+ coverage
- {{STATE_MANAGER}} stores: 70%+ coverage
- Test stack: Vitest + MSW + React Testing Library; {{E2E_TOOL}} for E2E
- **Server Components**: test via the data they render (props → output),
  not via browser APIs. Use `@testing-library/react` with `renderToString` or
  test the page's data-fetching function directly.
- **Server Actions**: test as async functions — call with mocked arguments,
  assert the return value or DB state change.

### Suite Health (BLOCKING — no exceptions)

The Vitest suite is a binary signal. Either it is green and trusted, or it is a liar.

- **Zero failing tests may be checked in.** `{{TEST_FRONTEND_CMD}}` on a clean checkout MUST exit zero.
- **Zero unconditional skips may be checked in.** Forbidden: `it.skip(...)`, `test.skip(...)`, `describe.skip(...)`, `.todo`, `xit`, `xdescribe`.
- **{{E2E_TOOL}} runtime skips are permitted** only inside a conditional (`if (!isMobile) { test.skip(...) }`).
- **Test drift is a bug, not a placeholder.** When you change a component prop, aria-label, store field, service signature, or API response shape, update the co-owning tests in the same commit.
- **Wall-clock-sensitive assertions MUST use relative dates** or `vi.useFakeTimers()`. Hardcoded ISO strings that imply "recent" will rot.
- **Deterministic test infrastructure.** Any randomness must be seedable or faked.

### Test Runner Discipline

- **Vitest and {{E2E_TOOL}} have disjoint test files.** `vitest.config.ts` MUST set `test.exclude` to include `tests/e2e/**` and `e2e/**`.
- **MSW handler paths are relative.** The shared handlers register `/api/...` paths.
- **Module-mock shapes must match real exports.** For icon libraries, enumerate the subset the component uses — Vitest rejects `Proxy`-backed factories.
- **Next.js mocks**: use `next/navigation` mocks for `useRouter`, `usePathname`, etc. Never mock the entire `next` package — mock specific exports.

### Mocking Anti-Patterns

- Tests that assert on component text, `aria-label`, store fields, or service method signatures that don't exist in the current codebase
- Wall-clock-dependent assertions without fake timers
- Proxy-backed module mocks
- Hardcoding `XMLHttpRequest` globals when the component now delegates to a service wrapper
- Mocking `next/server` or `next/headers` in client component tests (they're server-only)