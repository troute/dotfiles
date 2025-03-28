# CLAUDE.md - Claude Code Guidelines

## Language-Specific Guidelines

### Python

Use Python virtual environments to isolate dependencies:

```bash
python3 -m venv .venv
```

I will often do this myself when setting up a brand new project, so check before attempting to create a new virtual
environment. When using virtual environments, I also configure a `.envrc` to activate the environment automatically:

```bash
# .envrc
source .venv/bin/activate
```

The virtual environment aliases `python`, so use `python` to invoke Python (rather than `python3`, for example).



