---
name: explore
description: Gain thorough context on a topic or area of the codebase.
---

# Explore

## Linear Ticket Mode

If `$ARGUMENTS` is "linear", "ticket", "next ticket", or otherwise suggests the user wants to pick
up work from Linear rather than explore the codebase, follow this flow instead:

1. **Fetch non-backlogged tickets** — Use Linear MCP tools to get tickets that are not in the
   backlog. Only these are in scope.
2. **Filter to available work** — Only consider tickets that are not already in progress, completed,
   cancelled, or otherwise claimed.
4. **Sort by priority** — Urgent > High > Medium > Low > No Priority.
5. **Pick a ticket** — From the highest available priority group, choose one arbitrarily.
6. **Present the ticket** — Show the ticket identifier, title, priority, and description. Ask the
   user if they want to proceed with this ticket.
7. **On confirmation** — Mark the ticket as "In Progress" in Linear via MCP, then explore the
   relevant area of the codebase using the ticket's context (follow the codebase exploration flow
   below).

If no qualifying tickets are found, report that clearly.

---

## Codebase Exploration

Investigate `$ARGUMENTS` across the full stack and report back concisely. Do not implement anything.

### What to Cover

- **Backend**: Models, operations, domain logic, and API endpoints related to the topic. Note
  layer responsibilities — what lives in `api/` vs `domain/` vs `db/operations/`.
- **Frontend**: Components, hooks, React Query usage, and relevant generated types. Check for
  Storybook stories if applicable.
- **Database**: Relevant tables, relationships, and any migration history worth noting.
- **Recent changes**: Use `git log --oneline -20 -- <relevant paths>` to understand what has
  changed recently in this area. Note any in-progress or partially landed work.
- **Key interfaces**: Focus on the boundaries between modules — function signatures, API contracts,
  component props. These are what matter most for understanding how things fit together.

### Output

Produce a structured summary. Keep it concise — I want to understand the lay of the land, not read
every line of code. Call out anything surprising, inconsistent, or potentially problematic.

Use parallel Task agents where it makes sense (e.g., frontend and backend exploration simultaneously).
