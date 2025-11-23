# Style Guide - TypeScript

## TODO

Ensure ESLint/Prettier configurations in my projects match this guide.

## Auto-Formatting vs. Manual Conventions

**Prettier + ESLint Auto-Format (don't manually enforce these):**
- Line length (120 chars)
- Semicolons
- Quote style (double quotes)
- Indentation (2 spaces)
- Trailing commas
- Import organization (with plugins)

**Manual Conventions (follow when writing code):**
- Type safety (`never use `any`, prefer `unknown`)
- `import type` for type-only imports
- Naming conventions (PascalCase, camelCase)
- Component patterns (custom hooks, composition)
- State management decisions (useState vs Context vs React Query)
- Architecture patterns (route organization, error handling)

All rules are documented below for completeness, but trust Prettier/ESLint for formatting details.

## Quick Reference

**Most Important Rules:**
- Never use `any`, prefer `unknown`
- Use `import type` for type-only imports
- Double quotes and semicolons always
- Use path aliases (@/) for imports
- Strict TypeScript configuration

**React Patterns:**
- React Query for all server state
- Context with custom hooks for global state
- State management decision tree
- Decompose components appropriately
- Protected route pattern

**UI Components:**
- ShadCN/Radix UI component pattern
- cn() utility for combining Tailwind classes
- Custom hooks for reusable logic

## Purpose

This document is a comprehensive, up-to-date representation of my preferences for TypeScript code style and best practices. It is organized into two main sections: Style Conventions (formatting and syntax) and Best Practices (architectural and design patterns). See CLAUDE.md for general guidelines that apply across all languages.

## Related Guides

- **CLAUDE.md** - General coding guidelines, workflow, and principles (DRY, KISS, YAGNI, SOLID)
- **TERMINAL_USE.md** - Terminal commands, Git conventions, and tool usage
- **STYLE_PYTHON.md** - Python/FastAPI guidelines

Note: Entry format and maintenance guidelines are defined in CLAUDE.md.

## Style Conventions

### Use double quotes for strings

Use double quotes for all string literals to maintain consistency across the codebase.

#### Do

```typescript
const name = "Alice";
const message = "Hello, world!";
```

#### Don't

```typescript
const name = 'Alice';
const message = 'Hello, world!';
```

---

### Always use semicolons

Include semicolons at the end of statements for explicit statement termination.

#### Do

```typescript
const user = { name: "Alice", age: 30 };
return user.name;
```

#### Don't

```typescript
const user = { name: "Alice", age: 30 }
return user.name
```

---

### Use 120 character maximum line length

Allow up to 120 characters per line, configured in Prettier, providing room for modern displays while maintaining readability.

---

### Use 2 spaces for indentation

Use 2-space indentation for all code to maintain consistency with the broader JavaScript/TypeScript ecosystem.

#### Do

```typescript
function example() {
  if (condition) {
    doSomething();
  }
}
```

---

### Organize imports in three groups with blank lines between

Group imports by type: React first, then third-party packages, then local imports. Sort alphabetically within each group. Use Prettier with import sorting plugin.

#### Do

```typescript
import { type FormEvent, useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";

import { useMutation, useQuery } from "@tanstack/react-query";
import { toast } from "sonner";

import { Button } from "@/components/ui/button";
import type { User } from "@/gen/types.gen";
```

#### Don't

```typescript
import { Button } from "@/components/ui/button";
import { toast } from "sonner";
import { useState } from "react";
import type { User } from "@/gen/types.gen";
```

Note: Configure Prettier with `@trivago/prettier-plugin-sort-imports` and set `importOrderSeparation: true`.

---

### Use `import type` for type-only imports

Explicitly mark type imports with `import type` to make it clear they're compile-time only and enable proper tree-shaking.

#### Do

```typescript
import type { ReactNode } from "react";
import { createContext, useContext } from "react";

import type { User, Asset } from "@/gen/types.gen";
```

#### Don't

```typescript
import { ReactNode, createContext, useContext } from "react";
import { User, Asset } from "@/gen/types.gen";
```

Note: Enable `verbatimModuleSyntax: true` in tsconfig.json to enforce this.

---

### Use PascalCase for components and types, camelCase for functions and variables

Follow TypeScript naming conventions: PascalCase for React components, types, and interfaces; camelCase for functions, variables, and hooks; UPPER_SNAKE_CASE for constants.

#### Do

```typescript
// Components and types
interface UserProps {
  user: User;
}

function UserProfile({ user }: UserProps) {
  // Component implementation
}

// Functions and variables
const selectedAssetId = assetIdFromUrl ? Number(assetIdFromUrl) : null;

function getUserName(user: User): string {
  return user.name;
}

// Constants
const MAX_RETRY_ATTEMPTS = 3;
const EXPORTABLE_KEYS = ["Summary", "Report"] as const;
```

---

### Name files with PascalCase for components, camelCase for utilities

Use PascalCase.tsx for React component files and camelCase.ts for utility/hook files to make file purposes clear at a glance.

#### Do

```
components/
  UserProfile.tsx
  AssetNavigation.tsx
  ui/
    Button.tsx
hooks/
  useAssetTabs.ts
  useAuth.ts
lib/
  utils.ts
```

#### Don't

```
components/
  user-profile.tsx
  asset_navigation.tsx
hooks/
  UseAssetTabs.ts
```

---

## Best Practices and Conventions

### Use strict TypeScript configuration

Enable all strict type-checking options in tsconfig.json to catch errors at compile time and ensure type safety.

#### Do

```json
{
  "compilerOptions": {
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noFallthroughCasesInSwitch": true,
    "verbatimModuleSyntax": true
  }
}
```

Note: Reference finform/frontend tsconfig.json for complete configuration.

---

### Never use `any`, prefer `unknown` for truly unknown types

Avoid `any` as it disables type checking. Use `unknown` when a type is genuinely unknown, forcing explicit type checks before use.

#### Do

```typescript
interface MessageProps {
  message: {
    text: string;
    tool_call?: {
      id: string;
      name: string;
      input: unknown; // Unknown structure, must be validated before use
    };
  };
}

function processData(data: unknown): string {
  if (typeof data === "string") {
    return data.toUpperCase();
  }
  return String(data);
}
```

#### Don't

```typescript
function processData(data: any): string {
  return data.toUpperCase(); // No type safety
}
```

Note: Generated API client code may contain `any`, which is acceptable since it's auto-generated.

---

### Use interfaces for props and object shapes, types for unions and complex types

Prefer interfaces for React component props and object structures. Use type aliases for unions, intersections, and complex type manipulations.

#### Do

```typescript
// Interfaces for props and objects
interface UserProfileProps {
  user: User;
  onUpdate: (user: User) => void;
}

interface AuthContextType {
  user: User | null;
  isAuthenticated: boolean;
  login: (password: string) => Promise<void>;
}

// Types for unions and complex types
type Status = "pending" | "success" | "error";
type Nullable<T> = T | null;
```

---

### Use const assertions for readonly arrays and literal types

Apply `as const` to arrays and objects that should be treated as readonly literal types.

#### Do

```typescript
const EXPORTABLE_ARTIFACT_KEYS = [
  "Executive Summary",
  "Leasing and Income Report",
  "Maintenance Report",
] as const;

const TAB_DEFINITIONS = [
  { id: "Workflows", label: "Workflows" },
  { id: "Documents", label: "Documents" },
] as const;
```

---

### Prefer default exports for pages and main components, named exports for utilities

Use default exports for page components and primary feature components. Use named exports for utilities, hooks, and shared components.

#### Do

```typescript
// pages/Login.tsx - default export
export default function Login() {
  // Component implementation
}

// hooks/useAuth.ts - named export
export function useAuth() {
  // Hook implementation
}

// components/ProtectedRoute.tsx - named export for utilities
export function ProtectedRoute({ children }: ProtectedRouteProps) {
  // Component implementation
}
```

Note: You may need to add `// eslint-disable-next-line react-refresh/only-export-components` above named exports in certain cases.

---

### Define prop interfaces before component definitions

Declare prop interfaces immediately before the component that uses them for better readability and organization.

#### Do

```typescript
interface MessageProps {
  message: {
    message_id: string;
    text: string;
    timestamp: Date;
    sender: string;
  };
}

export default function Message({ message }: MessageProps) {
  // Component implementation
}
```

---

### Use TanStack React Query for server state management

Use React Query for all API data fetching, mutations, and server state caching. Keep local UI state in useState.

#### Do

```typescript
import { useQuery, useMutation } from "@tanstack/react-query";
import { getAssetsAssetsGetOptions, createAssetAssetsPostMutation } from "@/gen/@tanstack/react-query.gen";

function AssetList() {
  // Server state with React Query
  const { data: assets, isLoading, refetch } = useQuery(
    getAssetsAssetsGetOptions()
  );

  const createAsset = useMutation({
    ...createAssetAssetsPostMutation(),
    onSuccess: () => {
      refetch();
      toast.success("Asset created successfully");
    },
    onError: () => {
      toast.error("Failed to create asset");
    },
  });

  // Local UI state with useState
  const [assetName, setAssetName] = useState("");

  // Component implementation
}
```

---

### Use context with custom hooks for global state

Create contexts with custom hooks that enforce proper usage and provide clear error messages when used outside providers.

#### Do

```typescript
import type { ReactNode } from "react";
import { createContext, useContext, useState } from "react";

import type { User } from "@/gen/types.gen";

interface AuthContextType {
  user: User | null;
  isAuthenticated: boolean;
  login: (password: string) => Promise<void>;
  logout: () => void;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null);

  // Context implementation

  return (
    <AuthContext.Provider value={{ user, isAuthenticated: !!user, login, logout }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error("useAuth must be used within AuthProvider");
  }
  return context;
}
```

---

### Use toast notifications for user feedback

Provide user feedback for async operations using toast notifications instead of inline error states.

#### Do

```typescript
import { useMutation } from "@tanstack/react-query";
import { toast } from "sonner";

import { createAssetAssetsPostMutation } from "@/gen/@tanstack/react-query.gen";

const createAsset = useMutation({
  ...createAssetAssetsPostMutation(),
  onSuccess: () => {
    toast.success("Asset created successfully");
    refetch();
  },
  onError: () => {
    toast.error("Failed to create asset. Please try again.");
  },
});
```

---

### Extract helper functions for complex conditional logic

When component logic becomes complex, extract helper functions for better readability and testability.

#### Do

```typescript
export default function Message({ message }: MessageProps) {
  const getMessageTypeLabel = () => {
    if (message.is_thinking) return "Thinking";
    if (message.sender === "user") return "You";
    return "Analyst";
  };

  const getMessageStyles = () => {
    if (message.is_thinking) {
      return "bg-neutral-100 border-2 border-dashed border-neutral-400";
    }
    return "bg-gray-100 border border-gray-300";
  };

  return (
    <div className={getMessageStyles()}>
      <span>{getMessageTypeLabel()}</span>
    </div>
  );
}
```

---

### Use custom hooks for reusable stateful logic

Extract reusable logic into custom hooks with clear names and return types.

#### Do

```typescript
import type { ArtifactBasic } from "@/gen/types.gen";

interface TabDefinition {
  id: string;
  artifactKey?: string;
  artifactKeyPrefix?: string;
}

const TAB_DEFINITIONS: TabDefinition[] = [
  { id: "Workflows" },
  { id: "Documents" },
  // ... other tab definitions
];

export function useAssetTabs(artifacts: ArtifactBasic[] | undefined): TabDefinition[] {
  if (!artifacts) {
    return [TAB_DEFINITIONS[0], TAB_DEFINITIONS[1]];
  }

  return TAB_DEFINITIONS.filter((tab) => {
    if (tab.id === "Workflows" || tab.id === "Documents") return true;

    if (tab.artifactKeyPrefix) {
      return artifacts.some((a) => a.key.startsWith(tab.artifactKeyPrefix!));
    }

    return artifacts.some((a) => a.key === tab.artifactKey);
  });
}
```

---

### Use path aliases for cleaner imports

Configure TypeScript path aliases (e.g., `@/*`) to avoid relative import paths and make refactoring easier.

#### Do

```typescript
// tsconfig.json
{
  "compilerOptions": {
    "paths": {
      "@/*": ["./src/*"]
    }
  }
}

// In component files
import { Button } from "@/components/ui/button";
import { useAuth } from "@/contexts/AuthContext";
import type { User } from "@/gen/types.gen";
```

#### Don't

```typescript
import { Button } from "../../../components/ui/button";
import { useAuth } from "../../contexts/AuthContext";
```

---

### Use enabled conditions for conditional queries

Use the `enabled` option in React Query to prevent queries from running when dependencies aren't ready.

#### Do

```typescript
import { useQuery } from "@tanstack/react-query";

import { getAssetArtifactsOptions } from "@/gen/@tanstack/react-query.gen";

const { data: artifactVersions, isLoading } = useQuery({
  ...getAssetArtifactsOptions({
    path: { asset_id: assetId },
    query: { key: artifactKey },
  }),
  enabled: !!artifactKey, // Only run when artifactKey is available
});
```

---

### Use ShadCN/Radix UI component pattern

Build UI components using the ShadCN pattern: Radix UI primitives + Tailwind + class-variance-authority for variants.

#### Do

```typescript
import * as React from "react";
import { cva, type VariantProps } from "class-variance-authority";
import { cn } from "@/lib/utils";

const buttonVariants = cva(
  "inline-flex items-center justify-center rounded-md font-medium transition-colors",
  {
    variants: {
      variant: {
        default: "bg-primary text-white hover:bg-primary/90",
        outline: "border border-input bg-background hover:bg-accent",
      },
      size: {
        default: "h-10 px-4 py-2",
        sm: "h-9 rounded-md px-3",
      },
    },
    defaultVariants: {
      variant: "default",
      size: "default",
    },
  }
);

function Button({
  className,
  variant,
  size,
  ...props
}: React.ComponentProps<"button"> & VariantProps<typeof buttonVariants>) {
  return (
    <button
      className={cn(buttonVariants({ variant, size, className }))}
      {...props}
    />
  );
}

export { Button, buttonVariants };
```

---

### Use cn() utility for combining Tailwind classes

Use the cn() utility (clsx + tailwind-merge) to combine and deduplicate Tailwind classes, preventing conflicts.

#### Do

```typescript
import { cn } from "@/lib/utils";

<div className={cn("bg-gray-100 p-4", isActive && "bg-blue-500", className)} />
```

Note: The cn() utility is defined as:
```typescript
import { clsx, type ClassValue } from "clsx";
import { twMerge } from "tailwind-merge";

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}
```

---

### Generate API clients from OpenAPI specs

Use `@hey-api/openapi-ts` to generate TypeScript clients from OpenAPI specifications, providing type-safe API access.

#### Do

```typescript
// Configure generated client
import { client } from "@/gen/client.gen";

client.setConfig({
  baseUrl: import.meta.env.VITE_API_BASE_URL,
  credentials: "include",
});

// Use generated React Query hooks
import { getAssetsAssetsGetOptions } from "@/gen/@tanstack/react-query.gen";

const { data: assets } = useQuery(getAssetsAssetsGetOptions());
```

Note: Add `src/gen` to ESLint ignore to avoid linting generated code.

---

### Choose state management based on scope and source of truth

Use useState for component-local UI state, React Query for server state, and Context only for truly global client state.

#### Do

```typescript
import { createContext, useState } from "react";

import { useQuery } from "@tanstack/react-query";

import { Button } from "@/components/ui/button";
import { getExamplesOptions } from "@/gen/@tanstack/react-query.gen";
import type { Item } from "@/gen/types.gen";

// Local UI state - useState
function ExampleFilter() {
  const [selectedFilter, setSelectedFilter] = useState<"all" | "active">("all");
  return <Button onClick={() => setSelectedFilter("all")}>All</Button>;
}

// Server state - React Query
function ExampleList() {
  const { data } = useQuery(getExamplesOptions());
  return <div>{data?.map(item => <Item key={item.id} {...item} />)}</div>;
}

// Global client state - Context (auth, theme, preferences)
const ThemeContext = createContext<{ theme: "light" | "dark" } | undefined>(undefined);

// Derived state - compute, don't store
function ExampleSummary({ items }: { items: Item[] }) {
  const total = items.reduce((sum, item) => sum + item.value, 0);
  return <p>Total: {total}</p>;
}
```

**Decision Rules:**
- Server data (from API)? → React Query
- Component-local UI? → useState
- Global client state (auth/theme)? → Context
- Can be computed? → Derive it, don't store it

#### Don't

```typescript
// Don't store derived state
function ExampleSummary({ items }: { items: Item[] }) {
  const [total, setTotal] = useState(0);
  useEffect(() => {
    setTotal(items.reduce((sum, item) => sum + item.value, 0));
  }, [items]);
  return <p>Total: {total}</p>; // Just compute it directly!
}

// Don't use Context for server state
const DataContext = createContext<Item[] | undefined>(undefined);
// Use React Query instead

// Don't use React Query for local UI state
const filterMutation = useMutation({
  mutationFn: (filter: string) => Promise.resolve(filter),
}); // Just use useState!

// Don't prop drill 3+ levels - use Context or composition
<Parent>
  <Child user={user}>
    <GrandChild user={user}>
      <GreatGrandChild user={user} /> {/* Too deep! */}
    </GrandChild>
  </Child>
</Parent>
```

---

### Use composition patterns and decompose components appropriately

Break down large components into smaller, focused pieces. Use children props and composition to avoid prop drilling.

#### Do

```typescript
import type { ReactNode } from "react";

import { useQuery } from "@tanstack/react-query";

import { getExamplesOptions } from "@/gen/@tanstack/react-query.gen";

// Decompose complex components into smaller focused pieces
// Before: One large component
function ExamplePage() {
  // 200+ lines of mixed concerns...
}

// After: Decomposed into focused components
function ExamplePage() {
  return (
    <div>
      <ExampleHeader />
      <ExampleFilters />
      <ExampleList />
    </div>
  );
}

function ExampleList() {
  const { data } = useQuery(getExamplesOptions());
  return <div>{data?.map(item => <ExampleCard key={item.id} item={item} />)}</div>;
}

// Good: Composition with children
function Card({ children }: { children: ReactNode }) {
  return <div className="border rounded p-4">{children}</div>;
}

// Good: Slots pattern for complex layouts
interface LayoutProps {
  sidebar: ReactNode;
  main: ReactNode;
}

function Layout({ sidebar, main }: LayoutProps) {
  return (
    <div className="flex">
      <aside>{sidebar}</aside>
      <main>{main}</main>
    </div>
  );
}
```

Note: Decompose components when they exceed ~200 lines, mix multiple concerns, or when pieces could be reused. Extract helper functions for complex logic. Use children/slots instead of prop drilling 3+ levels deep.

---

### Organize routes with React Router and use protected route pattern

Structure routes hierarchically and use wrapper components for authentication.

#### Do

```typescript
import { BrowserRouter, Navigate, Outlet, Route, Routes, useNavigate } from "react-router-dom";

import { useMutation } from "@tanstack/react-query";

import { useAuth } from "@/contexts/AuthContext";
import { createExampleMutation } from "@/gen/@tanstack/react-query.gen";

// Route organization in App.tsx
function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/login" element={<Login />} />
        <Route element={<ProtectedRoute />}>
          <Route path="/" element={<Home />} />
          <Route path="/examples" element={<ExampleList />} />
          <Route path="/examples/:id" element={<ExampleDetail />} />
        </Route>
      </Routes>
    </BrowserRouter>
  );
}

// Protected route wrapper
function ProtectedRoute() {
  const { isAuthenticated } = useAuth();
  return isAuthenticated ? <Outlet /> : <Navigate to="/login" />;
}

// Programmatic navigation
function ExampleForm() {
  const navigate = useNavigate();
  const createMutation = useMutation({
    ...createExampleMutation(),
    onSuccess: (data) => navigate(`/examples/${data.id}`),
  });
}
```

---
