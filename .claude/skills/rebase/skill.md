---
name: rebase
description: Get the current branch up to date with a target branch.
allowed-tools:
  - Bash(git *)
  - Bash(cd frontend && npm install *)
  - Bash(uv sync)
  - Bash(alembic upgrade *)
---

# Rebase

Get the current branch up to date with a target branch. The target defaults to `staging`.
If an argument is provided, the argument is: `$ARGUMENTS`. If it looks like a branch name
(e.g., `main`), use it as the target. Otherwise, treat it as additional context or instructions.

## Steps

1. **Assess the current state.** Run `git status` and `git log --oneline -5`. Determine whether
   there are uncommitted changes (staged or unstaged), stashed work, or a clean working tree.

2. **Fetch the target.** Run `git fetch origin`.

3. **Stash if needed.** If there are uncommitted changes, stash them with a descriptive message
   before proceeding.

4. **Rebase.** Run `git rebase origin/{target}`. If there are conflicts, resolve them — prefer
   our changes when the intent is clear, and flag ambiguous conflicts for my review.

5. **Pop stash if applicable.** If we stashed in step 3, pop it and resolve any conflicts.

6. **Sync dependencies.** If lockfiles changed during the rebase (`package-lock.json`, `uv.lock`,
   `yarn.lock`, `poetry.lock`, etc.), install the new dependencies. In finform, that means
   `cd frontend && npm install && cd ..` for frontend changes and `uv sync` for backend changes.
   In other projects, use common sense based on the lockfile and project conventions.

7. **Apply migrations.** If new Alembic migrations landed (`alembic/versions/` has new files),
   run `alembic upgrade head`. If the migration history has diverged (local branch created a
   migration that now conflicts with upstream), flag it for my review rather than attempting
   to reconcile automatically.

8. **Report.** Summarize what happened: how many commits were replayed, whether conflicts were
   resolved (and how), whether the stash popped cleanly, whether dependencies were synced, and
   whether any migrations were applied. If anything looks risky, say so.

Do not push. I handle that myself.
