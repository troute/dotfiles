# Terminal Usage Guide

## Purpose

This document captures my preferences and conventions for terminal usage, command patterns, and workflow automation. It is intended to guide AI agents and ensure consistent terminal interactions. See CLAUDE.md for general guidelines that apply across all languages and contexts.

## Related Guides

- **CLAUDE.md** - General coding guidelines, workflow, and principles (DRY, KISS, YAGNI, SOLID)
- **STYLE_PYTHON.md** - Python code style, FastAPI patterns, SQLModel
- **STYLE_TYPESCRIPT.md** - TypeScript, React, state management

## Quick Reference

**Critical Patterns:**
- Use subprocess pattern for directory-specific commands
- Always use virtual environment Python (`python`, not `python3`)
- Conventional commit messages with bracket prefixes
- Chain commands with `&&` to stop on failure

**Common Tools:**
- Git with conventional commits
- Ruff for Python formatting
- Alembic with autogeneration for migrations
- psql for non-interactive database queries
- jq for JSON processing

## Terminal Conventions

### Use subprocess pattern for directory-specific commands

Use `(cd directory && command)` instead of `cd directory && command` to preserve the current working directory. This prevents unexpected PWD changes that can confuse both humans and AI agents.

#### Do

```bash
# Frontend operations
(cd frontend && npm run generate-client)
(cd frontend && npx prettier --write .)
(cd frontend && npm run dev)

# Backend operations (if applicable)
(cd backend && pytest)
```

#### Don't

```bash
# Changes PWD unexpectedly
cd frontend && npm run generate-client
cd frontend && npx prettier --write .

# Now you're in frontend/ directory - may be confusing
```

Note: This pattern is especially important when AI agents execute commands, as they may lose track of the current directory.

---

### Use conventional commit message format

Use bracket-prefixed commit messages to categorize changes clearly.

#### Do

```bash
git commit -m '[feat] add new authentication endpoint'
git commit -m '[fix] resolve database connection timeout'
git commit -m '[chore] update dependencies'
git commit -m '[wip] partial implementation of reports feature'  # Development only
```

**Common commit sequences:**

```bash
# Standard commit flow
git status
git add .
git commit -m '[type] message'
git push

# Amend recent commit with formatting changes
ruff format .
git add .
git commit --amend --no-edit
git push -f

# Clean up commit history before push
git rebase -i HEAD~3
```

#### Don't

```bash
git commit -m 'fixed stuff'
git commit -m 'updates'
git commit -m 'WIP'  # Use [wip] prefix instead
```

Note: `[wip]` commits are development aids only and should never appear in main branches. Use interactive rebase to clean them up before merging.

---

### Use formatters frequently and proactively

Run formatters often to maintain consistent code style.

#### Do

```bash
# Python formatting
ruff format .

# Frontend formatting (using subprocess!)
(cd frontend && npm run format)
```

---

### Database migration pattern

Use alembic with autogeneration for database migrations. Use psql for non-interactive queries.

#### Do

```bash
# Create migration from model changes (always autogenerate first)
alembic revision --autogenerate -m "add user table"

# Apply migrations
alembic upgrade head

# Full reset (development only)
alembic downgrade base && alembic upgrade head

# Database queries (non-interactive, scriptable)
psql -d finform -c "SELECT * FROM users LIMIT 10"
psql -d finform -c "SELECT COUNT(*) FROM assets"
```

---

### Always use the virtual environment Python

Python projects typically use a virtual environment at `.venv` (95% of cases), which is gitignored and invisible in file listings. The environment is usually auto-activated via `.envrc`.

#### Do

```bash
# Use venv's python (aliased by activation)
python script.py
python -m module.submodule

# Install packages in venv
pip install package-name
pip install -e .[dev]

# Run Python tools from venv
alembic upgrade head
uvicorn backend.main:app --reload
pytest
```

#### Don't

```bash
# Don't use system python3
python3 script.py  # Wrong - bypasses venv
python3 -m pip install package  # Wrong - installs to system

# Don't create venv if .venv already exists
python3 -m venv .venv  # Check first - likely already exists
```

Note: The `.venv` directory is gitignored and won't appear in file listings, but it typically exists. Only use `python3` when explicitly creating the venv itself or when working outside the venv context (rare).

---

### Project directory location

Projects are typically located in `~/dev/`, but may occasionally be in other directories.

---

### Utility commands

**JSON processing (important - use frequently):**
```bash
npx ccusage --json | jq '.'
cat response.json | jq '.data'
psql -d finform -c "SELECT json_column FROM table" | jq '.field'
```

**Clipboard:**
```bash
cat file.txt | pbcopy     # Copy to clipboard
pbpaste > file.txt        # Paste from clipboard
```

**Directory structure:**
```bash
tree dir -L 2             # Show 2 levels deep
tree . -L 3               # Current directory, 3 levels
```

**Open files (macOS):**
```bash
open .                    # Open current directory in Finder
open file.csv             # Open file in default app
```

---

### Command chaining with &&

Use `&&` to chain commands that should stop on failure.

#### Do

```bash
ruff check . && ruff format . && git add .
alembic downgrade base && alembic upgrade head
git add . && git commit -m '[feat] new feature' && git push
```

#### Don't

```bash
# Don't use semicolons when you want to stop on errors
ruff check . ; ruff format . ; git add .  # Continues even if ruff check fails
```

---
