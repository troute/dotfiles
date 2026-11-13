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

Use bracket-prefixed commit messages to categorize changes clearly: a lowercase title of at most 72 characters,
with `[feat]` reserved for major features (most net-new work is `[fix]` or `[chore]`) and a `[fix]` title reading as a
sentence that describes the problem.

#### Do

```bash
git commit -m '[feat] restrict monitored inboxes to access groups'   # major features only
git commit -m '[fix] database connection times out under load'       # describes the problem
git commit -m '[chore] update dependencies'
git commit -m '[wip/fix] partial timeout fix'                         # development only; bare [wip] is fine too
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
git push --force-with-lease   # never plain -f, and never to a shared default branch

# Clean up commit history before push
git rebase -i HEAD~3
```

#### Don't

```bash
git commit -m 'fixed stuff'
git commit -m 'updates'
git commit -m 'WIP'  # Use [wip] prefix instead
git push -f          # Use --force-with-lease, which refuses to clobber commits you haven't seen
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
git add . && git commit -m '[chore] update dependencies' && git push
```

#### Don't

```bash
# Don't use semicolons when you want to stop on errors
ruff check . ; ruff format . ; git add .  # Continues even if ruff check fails
```

---

### Pipe to `tail`/`grep` for large, fast outputs only

Use `tail`/`grep` sparingly for commands that run quickly but produce large outputs.
Avoid using `tail`/`grep` for long-duration commands with periodic or uncertain outputs,
as it prevents me from seeing progress and hides valuable signal after completion.

#### Do

```bash
zsh verbose-but-fast.zsh | grep foobar
zsh verbose-but-fast.zsh | tail -n 10
```

#### Don't

```bash
zsh slow.zsh | tail -n 10
zsh emits-progress.zsh | tail -n 10
zsh may-have-error-output.zsh | grep foobar
```

---

### Never let a pipe decide a gate's verdict

A pipeline's exit code is its last command's, so a failing test, build or migration piped through `tail` or `tee` reports success. When pass/fail matters, keep `pipefail` on and judge by the tool's own summary line.

#### Do

```bash
set -o pipefail; npx playwright test --reporter=line 2>&1 | tail -40
pre-commit run --all-files   # unpiped; read its own pass/fail lines
```

#### Don't

```bash
npx playwright test 2>&1 | tail -40      # exit 0 even when tests failed
docker build . || echo "build done"      # masks the failure entirely
```

---

### The shell is zsh on macOS

zsh doesn't word-split an unquoted `$var` and aborts on a glob that matches nothing, and the BSD tools lack GNU idioms, so a few habits fail, sometimes silently.

#### Do

```bash
grep -rn foo --include='*.py' .           # quote glob arguments
for f in ${=FILES}; do …; done            # or loop over an array / in Python
perl -pi -e 's/\bold\b/new/g' file        # word boundaries; `git grep -P` and `rg` also have \b
perl -e 'alarm shift; exec @ARGV' 60 cmd  # macOS has no `timeout`
```

#### Don't

```bash
grep -rn foo --include=*.py .             # "no matches found", command never runs
for f in $FILES; do …; done               # one iteration over the whole string
sed -i '' 's/\bold\b/new/g' file          # BSD sed has no \b: silently replaces nothing
timeout 60 cmd                            # command not found
```

Note: after a bulk rename, grep for the old name to confirm it's gone.

---
