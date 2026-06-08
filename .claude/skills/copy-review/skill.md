---
name: copy-review
description: Review all added or modified user-legible copy in the current change set.
allowed-tools:
  - Bash(git *)
---

# Copy Review

Surface every piece of user-legible copy added or modified in the current change set so I can edit it inline and send it back.

## What Counts as Copy

- **Text**: titles, subtitles, headings, body text, button labels, placeholders, tooltips, toasts, error messages, empty states, aria-labels, alt text — anything a user can read.
- **Icons**: any icon rendered in the UI (include the library of origin, e.g. Heroicons, Lucide, Phosphor).
- **Assets**: images, illustrations, or other media files newly referenced or swapped (include the file path).

Be exhaustive. Word choice matters to me, so missing copy is worse than over-including. When in doubt, include it.

## How to Find It

1. Diff the current branch against the target branch. Default to `staging`; if `$ARGUMENTS` looks like a branch name, use that instead.
2. Walk every changed file. Pay attention to:
   - JSX/TSX text nodes and string props (`title`, `label`, `placeholder`, `aria-label`, `alt`, etc.)
   - Constants files, i18n dictionaries, schema descriptions
   - Backend strings that surface to the user (API error messages, validation messages, email/notification templates)
   - Icon component imports and usages
   - New or swapped asset references (`src=`, `import` of images, etc.)
3. Include both **added** and **modified** copy. For modified copy, the new text is what matters — don't show the old.

## Output Format

Output a single fenced code block. Inside, each entry is a one-line `#` comment explaining where the copy lives, what it expresses, and when it appears, followed by the copy itself on the next line. Separate entries with a blank line. No other prose, no headings, no grouping — just the flat list, so I can edit inline and send back.

```
# Login page heading, shown above the email field on first load
Welcome back

# Submit button on the login form
Sign in

# Toast shown after successful password reset
Password updated

# Close icon on the settings modal header
Heroicons XMarkIcon

# New empty-state illustration shown when the asset list is empty
src/assets/empty-assets.svg
```

Keep explanations to one sentence max. Be specific about location (component or page) and trigger (when the user sees it).

## When I Reply With Edits

If I send the block back with edits, substitute each edited line into the actual source file it came from. Match by the original copy and the location described in the comment. Don't touch entries I left unchanged.
