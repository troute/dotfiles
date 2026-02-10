---
name: finalize
description: Finalize a change set for submission.
disable-model-invocation: true
allowed-tools:
  - Bash(git *)
  - Bash(git fetch origin && git diff origin/main)
  - Bash(pre-commit run *)
---

# Change Set Finalization

## Instructions

Please examine our full change set relative to latest main, and verify that it is finalized for submission (and by extension, for merge). Please ensure you examine the entirety of the git diff and carefully diligence any relevant files you are unfamiliar with.

Pay special attention to:

> Interface design. Are class, method/function, component, and service interfaces minimal, coherent, and well designed? Are they self documenting, via both clear naming and intuitiveness? Do they allow for future extension? Do they lend themselves to easy testing, inspection, and maintenance?

> Coherence. Does the full change set demonstrate consistent practices? Could earlier changes require tweaks to be brought in line with the final design?

> Decomposition. Are the changes and surrounding code sufficiently decomposed? Are there opportunities for deduplication via decomposition into reusable components?

> File organization. Are files appropriately placed according to codebase conventions? Does the division of responsibilities between files make sense? Does any awkwardness with the file structure resulting from this change set suggest it is time to perform any sort of larger file layout reorganization?

> Judicious commenting. Are all comments non-obvious to an experienced software engineer? Are atypical patterns, shortcuts, and hacks sufficiently explained? Are all comments concise? Do all comments use proper capitalization, punctuation, and grammar?

> Leaving the codebase better than you found it. Is there any adjacent cruft that you can conveniently improve alongside the core change set?

Once you have addressed all of the above, please ensure that `pre-commit run --all-files` succeeds.

Finally, please output a conventional commit message, in the style matching that of the most recent commits on main:

!`git log origin/main --oneline -20`

Please ultrathink about this. Careful work here will vastly shorten the time to approval for this change set.

## Diff

!`git fetch origin && git diff origin/main`
