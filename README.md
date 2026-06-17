# dotfiles

Personal macOS dotfiles, managed as a bare git repository.
Git dir at `~/.dotfiles/`, work tree at `$HOME`.

## Bootstrap

### 1. Xcode Command Line Tools

```bash
xcode-select --install
```

Click through GUI installer (~5–15 min).

### 2. Homebrew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Ignore the post-install hints about adding brew to PATH — the tracked `.zprofile`
already handles it. brew will land on PATH after step 3's `exec zsh`.

### 3. Clone the bare dotfiles repo

HTTPS, not SSH — no key uploaded yet.

```bash
git clone --bare https://github.com/troute/dotfiles.git $HOME/.dotfiles
git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME checkout
git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME config status.showUntrackedFiles no
exec zsh
```

### 4. Install from the Brewfile

```bash
brew bundle --file=~/.Brewfile
```

### 5. Touch ID for sudo

`pam_reattach` must load before `pam_tid` for Touch ID to work inside tmux.

```bash
sudo tee /etc/pam.d/sudo_local > /dev/null <<'EOF'
auth       optional       /opt/homebrew/lib/pam/pam_reattach.so
auth       sufficient     pam_tid.so
EOF
```

### 6. Docker Desktop first launch

Open `Docker.app` once to accept terms.

### 7. Auth

```bash
gh auth login
gcloud auth login
gcloud auth application-default login
railway login
```

Plus 1Password app + browser extension (enable Touch ID in 1Password settings).

If `gh` didn't set up SSH:

```bash
ssh-keygen -t ed25519
gh ssh-key add ~/.ssh/id_ed25519.pub
```

### 8. Apps not in the Brewfile

Terminal, browser, 1Password, Slack, etc. — install manually.

## After bootstrap

See `~/.dotfiles/CLAUDE.md` for the bare-repo workflow (the `dotfiles` / `d` aliases,
adding new tracked files, etc.).

## Tracked files

| Category | Files |
|---|---|
| Shell | `~/.zshrc`, `~/.zprofile`, `~/.zshenv`, `~/.zsh/finform.zsh`, `~/.zsh/claude.zsh` |
| tmux | `~/.tmux.conf` |
| Git | `~/.gitconfig` |
| Neovim | `~/.config/nvim/` |
| Claude Code | `~/.claude/CLAUDE.md`, `STYLE_PYTHON.md`, `STYLE_TYPESCRIPT.md`, `TERMINAL_USE.md`, `settings.json`, `settings.local.json`, `skills/*/skill.md`, `scripts/extract-session.py` |
| Python | `~/.ruff.toml`, `~/.pdbrc.py` |
| Starship | `~/.config/starship.toml` |
| Homebrew | `~/.Brewfile` |
| Docs | `~/README.md` |
