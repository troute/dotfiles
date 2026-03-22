---
name: explore
description: Gain thorough context on a topic or area of the codebase.
---

# Explore

Investigate `$ARGUMENTS` across the full stack and report back concisely. Do not implement anything.

## What to Cover

- **Backend**: Models, operations, domain logic, and API endpoints related to the topic. Note
  layer responsibilities — what lives in `api/` vs `domain/` vs `db/operations/`.
- **Frontend**: Components, hooks, React Query usage, and relevant generated types. Check for
  Storybook stories if applicable.
- **Database**: Relevant tables, relationships, and any migration history worth noting.
- **Recent changes**: Use `git log --oneline -20 -- <relevant paths>` to understand what has
  changed recently in this area. Note any in-progress or partially landed work.
- **Key interfaces**: Focus on the boundaries between modules — function signatures, API contracts,
  component props. These are what matter most for understanding how things fit together.

## Output

Produce a structured summary. Keep it concise — I want to understand the lay of the land, not read
every line of code. Call out anything surprising, inconsistent, or potentially problematic.

Use parallel Task agents where it makes sense (e.g., frontend and backend exploration simultaneously).
