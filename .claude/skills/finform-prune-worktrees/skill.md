---
name: finform-prune-worktrees
description: Sweep all Finform worktrees, report each slot's state (services, Claude session, tmux, divergence from staging, and what's needed to unblock it), then interactively prune the ones with no active work.
---

# Finform: Prune Worktrees

Finform-specific skill. It lives here (staged in the dotfiles repo) so it can be iterated on
before being promoted into the Finform monorepo's `.claude/skills/`. Nothing here is generic.

Finform runs up to 12 parallel worktrees at `~/dev/finform-worktrees/1..12`. Each has its own
process-compose stack, database, ports, and (often) a live Claude session in a tmux window.
Over a work session they accumulate: some hold real in-flight work, others are stale husks
worth tearing down. This skill surveys all of them and drives an interactive prune.

If `$ARGUMENTS` names specific slots (e.g. `3 7 10`), scope the entire run to just those.

## Critical: shell setup

Every `Bash` call in this skill MUST begin with `source ~/.zsh/finform.zsh &&`. The non-interactive
tool shell runs `compinit`, which strips the `_finform-*` private helpers — without re-sourcing,
`_finform-prune-scan` and the service/session data it gathers are silently missing.

## What owns what (never tear down shared infra)

- **process-compose** owns every per-slot service: backend (`api`), frontend (`vite`), storybook,
  hocuspocus, temporal **worker**, and the two docker containers `s3mock-finform-<n>` /
  `unoserver-finform-<n>` (started as `docker run --rm` inside process-compose).
- **Shared / system, NEVER touched by a prune:** the Temporal server (7233/8233), Postgres.
- Teardown is `finform-kill <N>` — it stops process-compose (which stops its docker containers),
  kills the slot's Claude session, and closes the tmux window. **It does not touch the working
  tree**: uncommitted files stay on disk. Always pass an explicit slot number; never call it
  bare (bare = self-teardown, which would kill this very session).

## Step 1 — Scan

```bash
source ~/.zsh/finform.zsh && _finform-prune-scan
```

This prints one JSON object per slot. Fields: `slot`, `exists`, `branch`, `dirty`, `dirty_count`,
`ahead` (commits on HEAD not in **`origin/staging`** — the scan fetches it first), `behind` (how
many commits HEAD trails `origin/staging`, i.e. staleness), `services{api,vite,storybook,hocuspocus,pc_socket,s3mock,unoserver}`,
`has_tmux`, `tmux_name`, `has_claude` (a live Claude session rooted in the worktree), `live_transcript`
(newest session JSONL), `transcript_bytes`, `transcript_lines`. Parse it and keep it as the backbone.

These are **independent clones**, not shared git worktrees — each has its own local `staging` that
drifts tens of commits behind origin. A large `behind` just means "stale clone," not un-landed work.

## Step 2 — Divergence themes

For every slot that is `dirty` OR `ahead > 0`, summarize how it diverges from staging in a
**3–5 word, 100-thousand-foot theme** (the broadest area, not a file list). Always compare against
**`origin/staging`**, never local `staging`. Gather cheaply in one batched call, e.g. per relevant slot:

```bash
source ~/.zsh/finform.zsh
d=~/dev/finform-worktrees/<n>
git -C "$d" log --oneline origin/staging..HEAD | head -20     # committed divergence
git -C "$d" -c color.ui=never diff --stat origin/staging      # uncommitted+committed vs remote
git -C "$d" status --short                                     # incl. untracked
```

Distill each into a theme like "invoice OCR pipeline", "storybook seed cleanup",
"login redirect handling". A clean slot with `ahead:0` has no theme — it is not diverged.

**Squash-merge trap — verify before calling a branch "un-landed."** Finform squash-merges, so a
fully-merged feature branch still shows `ahead > 0` and `git cherry` still marks its commits `+`
(the squash has a different patch-id). NEVER conclude a non-`staging` branch has un-landed work from
ancestry/`git cherry` alone. Verify by **content**: take a distinctive symbol, function, file, or
migration the branch introduced and check whether it already exists in `origin/staging`
(`git -C "$d" grep <symbol> origin/staging -- <path>`, or `git -C "$d" show origin/staging:<file>`).
If the substance is present, the branch is merged and safe to reset/delete despite `ahead > 0`.

## Step 3 — Session substance + what's needed to unblock

This is the payoff of the prune: for each slot with an active session (`has_claude`) — and for any
**dirty orphan** (`dirty` but `has_claude:false`, which may still hold uncommitted context worth
saving) — figure out (a) whether the session is substantive and (b) **what YOU would have to do to
move it forward.**

Cheap pre-gate first: `transcript_bytes`/`transcript_lines` from the scan. A tiny transcript
(e.g. < ~40 KB / < ~60 lines) is almost certainly not substantive. For everything above that, read
a bounded preview (~5k tokens) of the live transcript — opening intent + recent state. **Bound the
INPUT by line-slicing before parsing** (pipe `head`/`tail` into `extract-session.py -`), so this
stays cheap and NEVER needs skipping even for a multi-hundred-MB transcript:

```bash
live="<live_transcript>"
echo "── opening ──"
head -n 60  "$live" | python3 ~/.claude/scripts/extract-session.py - | head -c 6000
echo; echo "── recent ──"
tail -n 160 "$live" | python3 ~/.claude/scripts/extract-session.py - | tail -c 8000
```

`head -n`/`tail -n` read only a slice of the file (JSONL is line-per-record, so slicing never
splits a record), and the byte caps guard against a single oversized line. Batch these across the
relevant slots in one call. From each preview, determine:

- **Substantive?** Did real work happen, or was it a throwaway (a question, an aborted start, nothing landed)?
- **Blocking state → what's required of the user.** Classify the next action *you* must take, e.g.:
  answer a question Claude is waiting on · make a design decision between stated options · review/approve
  a diff · resolve a merge conflict with staging · just commit + push · provide missing info/credentials ·
  investigate a failing test · nothing (finished, safe to drop).
- **Unblock effort:** easy / medium / hard — how much of your attention resuming it would cost.

The goal is that after this step you can see, at a glance, **which worktrees you can cheaply unblock**
versus which are safe to prune.

## Step 4 — Classify

- **idle** — clean, on `staging`, `ahead:0`, no session, no services, no tmux. Nothing to do; skip.
- **auto-prune** — has running state (services/tmux/session) BUT `dirty:false` AND `ahead:0` AND no
  substantive session. This is the ONLY case you tear down without asking. Do it, and report it.
- **candidate** — everything else: dirty, ahead of staging, or a session with real history. These go
  to the user.

## Step 5 — Short summary, then per-worktree multi-select

Print a **short** overview first (a few lines): counts per category, what you auto-pruned, and a
highlight of the easy-to-unblock wins. Then present the candidates as a per-worktree **multi-select**
asking which to tear down. Each option: label `slot N — <theme>`; description packs the key facts
(branch/ahead, dirty count, services up, session substance, and the unblock note + effort from Step 3).

`AskUserQuestion` allows at most 4 options per question, so chunk candidates into groups of ≤4 and ask
multiple multi-select questions in the same call. Selecting a slot = approve teardown; leaving it
unselected = keep it.

## Step 6 — Execute, with a capture guard

For each slot the user selected for teardown:

- If it is **dirty or had a substantive session**, do NOT tear down blindly — first offer to **capture
  state**: commit, `git stash`, or write a short `defer-*.md` in the worktree summarizing where things
  stood and what's needed to resume. (`finform-kill` leaves files on disk, so the diff survives; what's
  lost is the live session context — that's what capture preserves.) Only after the user chooses, run
  `finform-kill <N>`.
- If it is **clean**, run `finform-kill <N>` directly.

```bash
source ~/.zsh/finform.zsh && finform-kill <N>
```

Then offer to dig deeper into any **kept** worktree — to actually unblock it (act on the Step-3 next
action) or to capture its state — following the user's lead on how far to go.

## Guardrails

- Never `finform-kill` without an explicit slot number.
- Never destroy a session's context or uncommitted work without offering capture first — the sole
  exception is the Step-4 auto-prune case (clean + no substantive session).
- Never stop the shared Temporal server or Postgres.
- Keep the conversation in the user's hands: the multi-select is the default decision point, and the
  user sets how aggressively to cull and how deep to investigate.
