Personal dotfiles managed as a bare git repository. The git directory is `~/.dotfiles/`;
the working tree is `$HOME`. All tracked files live in the home directory, not in this folder.

## Git Access

All git operations require the bare repo flags. Two aliases are defined in `.zshrc`:

```bash
alias dotfiles='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
alias d='dotfiles'
```

When running commands from this directory (or anywhere), always use the alias or the full flags:

```bash
dotfiles status
dotfiles add ~/.zshrc
dotfiles commit -m '[chore] update zshrc'
dotfiles diff
dotfiles log --oneline
```

Standard `git` commands will not work — they see `~/.dotfiles/` as the bare git directory, not a normal repo.

`status.showUntrackedFiles` is set to `no` in the repo config, so `dotfiles status` only shows
changes to already-tracked files. To add a new file, explicitly `dotfiles add <path>`.

## Tracked Files

| Category | Files |
|---|---|
| Shell | `~/.zshrc`, `~/.zprofile`, `~/.zshenv`, `~/.zsh/finform.zsh`, `~/.zsh/claude.zsh`, `~/.zsh/dotfiles.zsh` |
| tmux | `~/.tmux.conf` |
| Git | `~/.gitconfig` |
| Neovim | `~/.config/nvim/` (init.lua, lazy config, plugin configs) |
| Claude Code | `~/.claude/CLAUDE.md`, `STYLE_PYTHON.md`, `STYLE_TYPESCRIPT.md`, `TERMINAL_USE.md`, `settings.json`, `settings.local.json`, `skills/*/skill.md`, `scripts/extract-session.py` |
| Python tools | `~/.ruff.toml`, `~/.pdbrc.py` |
| Starship | `~/.config/starship.toml` |
| Homebrew | `~/.Brewfile` (run `brew bundle --global` to install on a new machine) |

## Editing Files

When I ask you to modify a dotfile, read and edit the file at its actual home directory path
(e.g. `~/.zshrc`, `~/.tmux.conf`). After editing, stage with `dotfiles add <path>`.
