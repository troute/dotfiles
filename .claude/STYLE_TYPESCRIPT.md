# TypeScript / React Style

Supplements the general principles in CLAUDE.md. **Prettier + ESLint own formatting** (line length, semicolons, quotes, indentation, trailing commas, import ordering) — don't hand-manage it. Below are the manual conventions to follow when writing.

## Style
- Double quotes, semicolons always, 2-space indent, 120-char lines.
- `import type` for type-only imports (enable `verbatimModuleSyntax`).
- Group imports: React → third-party → local (`@/…`), alphabetized, blank line between groups.
- Naming: `PascalCase` components/types, `camelCase` funcs/vars/hooks, `UPPER_SNAKE_CASE` constants; files `PascalCase.tsx` (components) / `camelCase.ts` (utils/hooks).
- Path aliases (`@/*`), never deep relative paths.

## Types
- Strict `tsconfig`; **never `any`** — use `unknown` and narrow. (Generated client code is exempt.)
- Interfaces for props/object shapes; type aliases for unions/intersections; `as const` for readonly literal arrays/objects. Declare a prop interface just above its component.

## State & data
- Server state → TanStack React Query (all fetching/mutations/caching); `enabled` for conditional queries. Local UI state → `useState`. Global client state (auth/theme) → Context with a custom hook that throws when used outside its provider.
- Derive computable state, don't store it. Don't use Context for server state, or React Query for local UI.
- Generate the API client from the backend OpenAPI spec (never hand-edit generated code); import types from the generated module rather than redefining API shapes.
- Toast notifications for async feedback.

## Components
- Default-export pages and primary components; named-export hooks and utilities.
- Build UI on the Radix + Tailwind + `cva`-variants pattern; combine classes with a `cn()` (clsx + tailwind-merge) helper.
- Decompose components once they pass ~200 lines or mix concerns; prefer children/slots over prop-drilling 3+ levels; extract complex conditionals into helpers and reusable stateful logic into custom hooks.
- Routing: hierarchical routes with a protected-route wrapper (an `<Outlet/>` that redirects when unauthenticated).
