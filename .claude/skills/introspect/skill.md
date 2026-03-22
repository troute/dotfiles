---
name: introspect
description: Examine this session's own log for CLAUDE.md improvements.
---

# Introspect

Review the current session's conversation log and identify actionable improvements for the global
`~/.claude/CLAUDE.md` or the project-level `CLAUDE.md`.

## Finding the Log

The current session's JSONL log lives at:

```
~/.claude/projects/{project-dir-slug}/{session-id}.jsonl
```

Where `{project-dir-slug}` is the working directory path with `/` replaced by `-` (e.g.,
`-Users-mtroute-dev-finform-worktrees-5`). To find the current session file, list the project
directory sorted by modification time and pick the most recently modified `.jsonl`.

## Extracting Readable Content

Use `~/.claude/scripts/extract-session.py` to strip the log down to user and assistant text:

```bash
python3 ~/.claude/scripts/extract-session.py <path-to-jsonl>
```

This removes thinking blocks, tool call details, and file snapshots. Pipe it to a file if needed
for length.

## What to Look For

Read through the extracted conversation and identify:

- **Corrections**: Places where the user had to redirect, re-explain, or push back. These suggest
  missing or unclear CLAUDE.md guidance.
- **Repeated patterns**: Workflows or conventions the user reinforced multiple times. These should
  be documented if they aren't already.
- **Friction**: Moments where Claude went in circles, over-engineered, or misunderstood scope.
  Consider what guidance would have prevented it.

Cross-reference findings against the existing `~/.claude/CLAUDE.md` and the project-level `CLAUDE.md`
to avoid suggesting things that are already documented.

## Output

Present each finding as a concrete, actionable suggestion — specify which file it belongs in and
draft the exact text to add. Keep suggestions concise and in the voice of the existing guidelines.
