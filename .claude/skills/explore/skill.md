---
name: explore
description: Build deep, implementation-ready context in a specific area of the codebase.
---

# Explore

Build working context in the area named by `$ARGUMENTS` so that implementing there afterward
feels easy. This is for your own context, not a tutorial for the user. Don't implement anything.

**Linear ticket:** If `$ARGUMENTS` indicates a ticket ("linear", "ticket", "next ticket"), first
fetch the top-priority unclaimed non-backlog ticket via Linear MCP, confirm it and mark it In
Progress, then explore exactly as below using the ticket as the target.

## What a good exploration does

You're building the context you'd want in hand the moment you start implementing. Aim for:

- **Trace one full vertical slice** end to end (endpoint → operation → model → migration, or
  component → hook → React Query → generated client → endpoint) rather than skimming many files.
  One traced path teaches the pattern; a broad skim doesn't.
- **Find the exemplar to copy.** Name the existing feature most structurally analogous to the
  coming work — "build it like X" is the most valuable thing you can surface.
- **Extract the local conventions**, not the global style guide: how this area handles errors,
  threads sessions/DI, validates, names, and tests — what makes a diff blend in.
- **Pin the insertion points.** Where does new code physically land — which file gets the
  endpoint, which module the operation, where the migration, where it's wired/registered.
- **Surface invariants and gotchas** — the non-obvious constraints that bite: ordering
  dependencies, shared state, things that must stay in sync (e.g. backend model ↔ generated
  client), sign/idempotency rules.
- **Read recent history** (`git log --oneline -20 -- <paths>`) for half-built or adjacent work,
  defer docs, and patterns to follow or collide with.
- **Note the dead ends** — deprecated or deceptively-relevant paths, so implementation doesn't
  wander into them.

Cover the stack as relevant: backend (models, operations, domain, endpoints), frontend
(components, hooks, React Query, generated types), database (tables, migrations). Do the reading
yourself so the context lives here; fan out to parallel Task agents only for genuinely large
sweeps, and demand dense returns.

A bad exploration lists files and narrates what the code does. A good one tells you where to put
your hands and what to imitate.

## Output

Dense. Exactly three parts, nothing else:

1. **One paragraph of prose** — how to implement in this area: the seam where changes go, the
   conventions to follow, the exemplar to mirror, and the one or two gotchas that matter.
2. **Key files** — bulleted, one per line: `path/to/file — 5–10 words on its relevant role`.
3. **Key symbols** — bulleted, one per line: classes, endpoints, interfaces, functions, and
   (frontend-heavy areas) components that carry weight: `SymbolName — kind; 5–10 words on why it's load-bearing`.

No headings inside these parts, no per-item paragraphs, no code walls.
