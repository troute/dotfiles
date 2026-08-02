# Python Style

Supplements the general principles in CLAUDE.md. **Ruff owns formatting** (line length, quotes, whitespace, trailing commas, blank lines, indentation, import ordering) — don't hand-manage it. Below are the manual conventions to follow when writing.

## Style
- Type-hint every signature, class attribute, and non-obvious local.
- Absolute imports only (star imports only in `__init__.py`, for package re-export).
- Prefer single quotes; use double only to avoid escaping.
- Naming: `snake_case` / `PascalCase` / `UPPER_SNAKE_CASE`; group related constants in a `str, Enum` class; single leading `_` for private (avoid `__` name-mangling unless you specifically want it).
- Include units in names — `timeout_ms`, `file_size_bytes`, `duration_seconds`.
- f-strings for interpolation; 120-char lines.

## Idioms
- EAFP over LBYL — `try/except`, not pre-checks.
- Never mutable default args — default to `None` and initialize inside.
- Context managers (`with`) for every resource (files, sessions, locks).
- `X | Y` / `X | None` unions, not `Union`/`Optional`.
- `async`/`await` for I/O; keep CPU-bound code synchronous.

## FastAPI / SQLModel / Pydantic
Applies to FastAPI-stack projects; a non-web project ignores this block.
- Pydantic v2: `model_dump`/`model_validate`, a `model_config` dict (not `class Config`), `BaseSettings` loading from `.env.local`; discriminated unions via a `Literal` type field.
- FastAPI: dependency injection for sessions/auth; generator deps (`yield` + `finally`) for cleanup; `Annotated[...]` for DI metadata and `Query`/`Header` constraints; correct HTTP status codes with Pydantic response models; `async` generators for streaming (SSE).
- Separation of concerns: thin routers delegate to a CRUD/operations layer or a domain layer; ORM tables separate from CRUD functions; shared-field mixins (e.g. a timestamp/soft-delete mixin). Project-specific layout and DB conventions live in that project's CLAUDE.md.
