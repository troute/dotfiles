---
name: undefer
description: Pick up deferred work from a defer-*.md or untracked markdown doc.
---

# Undefer

Resume work that was previously deferred.

## Steps

1. **Find the document.** Look for `defer-*.md` files in the current directory. If none exist,
   look for any untracked markdown files (`git ls-files --others --exclude-standard '*.md'`).
   If multiple candidates exist, list them and ask which one to use. If an argument was provided
   (`$ARGUMENTS`), use it to match by filename or subject.

2. **Read it.** Read the deferred document and understand the problem, current state, and
   proposed direction.

3. **Explore the referenced areas.** For each area mentioned in the document, investigate across
   the full stack:
   - **Backend**: Models, operations, domain logic, and API endpoints. Note layer responsibilities.
   - **Frontend**: Components, hooks, React Query usage, generated types. Check Storybook stories
     if applicable.
   - **Database**: Relevant tables, relationships, migration history.
   - **Recent changes**: Use `git log --oneline -20 -- <relevant paths>` to see what has changed
     since the document was written. This is critical — the deferral may be stale.
   - **Key interfaces**: Focus on boundaries between modules — function signatures, API contracts,
     component props.
   Use parallel Task agents where it makes sense (e.g., frontend and backend simultaneously).

4. **Report.** Summarize what you found. Specifically call out:
   - Whether the problem described still exists
   - What has changed since the deferral that affects the proposed direction
   - Whether the proposed direction still makes sense, or if a different approach is warranted
   Ask how I'd like to proceed.

Do not start implementing. This is context gathering only.
