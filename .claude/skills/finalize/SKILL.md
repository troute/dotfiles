---
name: finalize
description: Finalize a change set for submission.
disable-model-invocation: true
allowed-tools:
  - Bash(git *)
  - Bash(pre-commit run *)
  - Bash(cd e2e && npx playwright test)
---

# Change Set Finalization

## Instructions

Examine the full change set against the target branch and verify that it is finalized for submission (and by extension, for merge). The target branch defaults to `staging`; the preprocessed inputs below are generated against staging. If an argument was provided (e.g., `/finalize main`), the argument is: `$ARGUMENTS`. In that case, **ignore the preprocessed inputs** and run equivalent git commands yourself against the specified branch. Ensure you examine the entirety of the diff and carefully diligence any relevant files you are unfamiliar with.

### 1. Check Freshness

Check whether the branch is behind the target branch (see Inputs below for the commit count and log of upstream changes). If the branch is behind, report the upstream commits and recommend that the user rebase before continuing. **Do not proceed with the remaining steps until the user confirms the branch is up to date or explicitly says to proceed anyway.**

### 2. Review the Change Set

The diff (see Inputs below) shows changes on this branch relative to the target branch. Pay special attention to:

> Completeness. Have we done everything we set out to do? If there is a Linear ticket associated with the current working branch (look for fin-{n} branch prefixing), are we sure that we have met all of the stated and implied requirements (given our best understanding of the state of discussion in the ticket and its comments)? If there are any planning documents associated with this change, have we met their requirements (unless no longer relevant due to changes in our understanding)?

> Simplicity. Is our solution maximally simple while delivering on the original desired behavior?

> Interface design. Are class, method/function, component, and service interfaces minimal, coherent, and well designed? Are they self documenting, via both clear naming and intuitiveness? Do they allow for future extension? Do they lend themselves to easy testing, inspection, and maintenance?

> Idiomatic implementation. Do changes match modern conventions for the languages, libraries, and tools that we are using? Are we doing everything atypical that we should reconsider? Will a future developer be surprised by any of the patterns we are employing?

> Codebase consistency. Do changes match existing patterns in the codebase? If not, is it because existing patterns are flawed? If so, should we tackle those flaws now (see later item about leaving the codebase better than we found it), or simply note them for follow-up?

> Coherence. Does the full change set demonstrate consistent practices? Could earlier changes require tweaks to be brought in line with the final design?

> Decomposition. Are the changes and surrounding code sufficiently decomposed? Are there opportunities for deduplication via decomposition into reusable components?

> File organization. Are files appropriately placed according to codebase conventions? Does the division of responsibilities between files make sense? Does any awkwardness with the file structure resulting from this change set suggest it is time to perform any sort of larger file layout reorganization?

> Judicious commenting. Are all comments non-obvious to an experienced software engineer? Are atypical patterns, shortcuts, and hacks sufficiently explained? Are all comments concise? Do all comments use proper capitalization, punctuation, and grammar?

> Leaving the codebase better than you found it. Is there any adjacent cruft that you can conveniently improve alongside the core change set?

### 3. Run Pre-Commit

Once you have addressed all of the above, ensure that `pre-commit run --all-files` succeeds.

### 4. Run E2E Tests

Run E2E tests headlessly with `cd e2e && npx playwright test`. **Never** use the `--headed` or `--ui` flags. If tests fail, report the failures but do not attempt to fix them — that is a separate task.

### 5. Output

Wait until all steps above are complete, then produce a single consolidated report covering:
- Freshness status
- Review findings (organized by the categories above — only mention categories where you have something to say)
- Pre-commit results
- E2E test results
- A conventional commit message, in the style matching that of the most recent commits on the target branch (see Inputs below for recent commit log)

Brief incremental notes during execution are fine, but the final report should be self-contained.

Do NOT attempt to issue the commit yourself. I will handle all git state management.

Please ultrathink about this. Careful work here will vastly shorten the time to approval for this change set.

## Inputs

### Commits Behind Staging

!`git fetch origin && git rev-list HEAD..origin/staging --count`

### Upstream Changes Since Divergence

!`git fetch origin && git log HEAD..origin/staging --oneline`

### Recent Commits on Staging

!`git fetch origin && git log origin/staging --oneline -20`

### Change Set

!`git fetch origin && git diff origin/staging`

### Main Divergence Context

!`git fetch origin && echo "Commits on main not on staging:" && git log origin/staging..origin/main --oneline -10 && echo "" && echo "Commits on staging not on main:" && git log origin/main..origin/staging --oneline -10`
