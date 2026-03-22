---
name: defer
description: Write a deferred-work document for something out of scope.
---

# Defer

Write a concise markdown document capturing work that we've identified but won't tackle now.

**File**: `defer-{subject}.md` in the current directory, where `{subject}` is a short kebab-case
descriptor (e.g., `defer-sign-normalization.md`). Derive the subject from `$ARGUMENTS` if provided,
otherwise from the current conversation context.

**Structure**:

```markdown
# {Title}

## Problem
What's wrong or missing, in 2-3 sentences.

## Current State
Brief description of how things work today, with key file paths.

## Proposed Direction
How we'd likely approach this, at a high level.

## References
- Relevant file paths, functions, or components
```

Keep it short — this is a breadcrumb for a future session, not a design doc. Write it from the
perspective of someone picking this up fresh.
