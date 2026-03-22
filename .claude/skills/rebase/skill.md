---
name: rebase
description: Get the current branch up to date with a target branch.
allowed-tools:
  - Bash(git *)
---

# Rebase

Get the current branch up to date with a target branch. The target defaults to `staging`;
if an argument is provided (e.g., `/rebase main`), use that instead: `$ARGUMENTS`.

## Steps

1. **Assess the current state.** Run `git status` and `git log --oneline -5`. Determine whether
   there are uncommitted changes (staged or unstaged), stashed work, or a clean working tree.

2. **Fetch the target.** Run `git fetch origin`.

3. **Stash if needed.** If there are uncommitted changes, stash them with a descriptive message
   before proceeding.

4. **Rebase.** Run `git rebase origin/{target}`. If there are conflicts, resolve them — prefer
   our changes when the intent is clear, and flag ambiguous conflicts for my review.

5. **Pop stash if applicable.** If we stashed in step 3, pop it and resolve any conflicts.

6. **Report.** Summarize what happened: how many commits were replayed, whether conflicts were
   resolved (and how), and whether the stash popped cleanly. If anything looks risky, say so.

Do not push. I handle that myself.
