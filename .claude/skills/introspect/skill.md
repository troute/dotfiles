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

Use `~/.claude/scripts/extract-session.py` to strip the log down to reviewable content:

```bash
# Conversation text (user + assistant messages, no thinking/tool details)
python3 ~/.claude/scripts/extract-session.py <path-to-jsonl>

# Failed tool calls only (tool name, input, error message)
python3 ~/.claude/scripts/extract-session.py --errors <path-to-jsonl>
```

Pipe output to files if needed for length. Run both extractions.

## What to Look For

Read through the extracted conversation and identify:

- **Corrections**: Places where the user had to redirect, re-explain, or push back. These suggest
  missing or unclear CLAUDE.md guidance.
- **Repeated patterns**: Workflows or conventions the user reinforced multiple times. These should
  be documented if they aren't already.
- **Friction**: Moments where Claude went in circles, over-engineered, or misunderstood scope.
  Consider what guidance would have prevented it.
- **Knowledge gaps**: Things Claude had to discover about the codebase mid-session that could have
  been short-circuited by a line or two in the project-level CLAUDE.md. Examples: architectural
  conventions, domain-specific terminology, relationships between modules, or gotchas that only
  become apparent after reading the code.
- **Failed tool calls**: Review the `--errors` output. Look for patterns — wrong table/column names
  suggest missing schema knowledge, permission rejections suggest missing allowed-tools entries,
  and repeated command failures suggest missing CLI conventions or environment setup docs.

Cross-reference findings against the existing `~/.claude/CLAUDE.md` and the project-level `CLAUDE.md`
to avoid suggesting things that are already documented.

## Output

Present each finding as a concrete, actionable suggestion — specify which file it belongs in and
draft the exact text to add. Keep suggestions concise and in the voice of the existing guidelines.
