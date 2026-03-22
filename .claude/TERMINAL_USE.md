# Terminal Usage Guide

## Purpose

This document captures my preferences and conventions for terminal usage, command patterns, and workflow automation. It is intended to guide AI agents and ensure consistent terminal interactions. See CLAUDE.md for general guidelines that apply across all languages and contexts.

## Related Guides

- **CLAUDE.md** - General coding guidelines, workflow, and principles (DRY, KISS, YAGNI, SOLID)
- **STYLE_PYTHON.md** - Python code style, FastAPI patterns, SQLModel
- **STYLE_TYPESCRIPT.md** - TypeScript, React, state management

## Quick Reference

**Critical Patterns:**
- Always return to project root after `cd` into subdirectories
- Always use virtual environment Python (`python`, not `python3`)
- Conventional commit messages with bracket prefixes
- Chain commands with `&&` to stop on failure

**Common Tools:**
- Git with conventional commits
- uv for Python dependency and version management
- Ruff for Python formatting
- Alembic with autogeneration for migrations
- psql for non-interactive database queries
- jq for JSON processing

## Terminal Conventions

### Always return to project root after directory changes

When running commands in a subdirectory, always chain `&& cd ..` at the end to return to the project root. Getting stranded in a subdirectory causes confusion about file paths and available commands.

#### Do

```bash
# Frontend operations — always return to project root
cd frontend && npm run generate-client && cd ..
cd frontend && npx prettier --write . && cd ..

# Backend operations
cd backend && pytest && cd ..
```

#### Don't

```bash
# Leaves you stranded in frontend/
cd frontend && npm run generate-client

# Now file paths and available commands are wrong
```

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

# Frontend formatting
cd frontend && npm run format && cd ..
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
psql -d <dbname> -c "SELECT * FROM users LIMIT 10"
psql -d <dbname> -c "SELECT COUNT(*) FROM assets"
```

---

### Use uv for Python dependency and environment management

Python projects use uv to manage Python versions, virtual environments, and dependencies. The `.venv` directory is created by `uv sync`, is gitignored, and invisible in file listings. The environment is usually auto-activated via `.envrc`.

#### Do

```bash
# Set up or update the environment (reads .python-version, creates .venv, installs deps)
uv sync

# Add a new dependency
uv add package-name

# Use venv's python (aliased by activation via .envrc)
python script.py
python -m module.submodule

# Run Python tools from venv
alembic upgrade head
uvicorn backend.main:app --reload
pytest
```

#### Don't

```bash
# Don't use pip directly
pip install package-name  # Wrong - bypasses uv lockfile
pip install -e .[dev]  # Wrong - use uv sync instead

# Don't use system python3
python3 script.py  # Wrong - bypasses venv

# Don't create venv manually
python3 -m venv .venv  # Wrong - uv sync handles this
```

Note: The `.venv` directory is gitignored and won't appear in file listings, but it typically exists. After adding dependencies with `uv add`, the lockfile (`uv.lock`) is updated automatically and should be committed.

---

### Project directory location

Projects are typically located in `~/dev/`, but may occasionally be in other directories.

---

### Utility commands

**JSON processing (important - use frequently):**
```bash
npx ccusage --json | jq '.'
cat response.json | jq '.data'
psql -d <dbname> -c "SELECT json_column FROM table" | jq '.field'
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
