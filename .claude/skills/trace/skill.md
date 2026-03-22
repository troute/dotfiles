---
name: trace
description: Trace all usage of a symbol across the full stack.
---

# Trace

Trace all usage of `$ARGUMENTS` across the codebase. Do not modify anything.

## What to Do

1. **Find the definition** — locate where this symbol is defined (model, function, component, endpoint, etc.).
2. **Trace all references** — grep for imports, call sites, and indirect usage across backend and frontend.
   Include generated client code (`src/gen/`) to bridge backend endpoints to frontend consumers.
3. **Map the dependency graph** — who calls this, and who calls the callers? Focus on the interfaces
   and responsibilities at each level, not implementation details.
4. **Identify dead paths** — if some references are unreachable from the UI or from any active code
   path, call that out explicitly.

## Output

A concise summary: where it's defined, who uses it, and whether any of those usages are dead.
If I asked about this because I'm considering removing or modifying it, tell me the blast radius.

For key functions and methods, include an annotated signature with one argument per line. Use your
judgement — skip this when the signature is trivial or self-explanatory. Format:

```python
# Resolves a normalized account from a posting, falling back through COA hierarchy
def resolve_account(
    posting: Posting,           # the raw GL posting to resolve
    coa: ChartOfAccounts,       # chart of accounts for hierarchical lookup
    strategy: MatchStrategy,    # controls exact vs fuzzy matching behavior
) -> ResolvedAccount | None:
```

For classes, include a simplified representation showing key fields and methods:

```python
# Dict with flexible 3-level account matching (exact, code-only, name-only)
class AccountDict(MutableMapping[AccountIdentifier, V]):
    # Key fields
    _by_str: dict[str, ...]       # exact stringified match index
    _by_code: dict[str, ...]      # code-only match index
    _by_name: dict[str, ...]      # name-only match index

    # Key methods
    def get(key: AccountIdentifier) -> V | None
    def enrich_key(key: AccountIdentifier) -> None  # upgrades partial keys with full info
```
