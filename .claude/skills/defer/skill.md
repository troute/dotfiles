---
name: defer
description: Write a deferred-work document for something out of scope.
---

# Defer

Write a concise markdown document capturing work that we've identified but won't tackle now.

**File**: `defer-{subject}.md` in the current directory, where `{subject}` is a short kebab-case
descriptor (e.g., `defer-sign-normalization.md`). Derive the subject from `$ARGUMENTS` if provided,
otherwise from the current conversation context.

**Metadata block**: Immediately below the title, include a compact block with the date
written and the current commit SHAs of `origin/main` and `origin/staging`. Run `git fetch`
first so the SHAs reflect the actual remote tips, then:

```bash
date +%Y-%m-%d
git rev-parse --short origin/main 2>/dev/null
git rev-parse --short origin/staging 2>/dev/null
```

Omit any line whose remote branch doesn't exist in this repo (don't fabricate SHAs).

**Structure**:

```markdown
# {Title}

- **Written**: YYYY-MM-DD
- **origin/main**: `abc1234`
- **origin/staging**: `def5678`

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
