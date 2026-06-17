# dotfiles

Personal macOS dotfiles, managed as a bare git repository.
Git dir at `~/.dotfiles/`, work tree at `$HOME`.

## New macOS bootstrap

### 1. macOS basics

Apple ID + Software Update.

### 2. Xcode Command Line Tools

```bash
xcode-select --install
```

Click through GUI installer (~5–15 min).

### 3. Homebrew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Run the two `eval` lines from the post-install hints to add `/opt/homebrew/bin` to PATH.

### 4. Clone the bare dotfiles repo

HTTPS, not SSH — no key uploaded yet. The backup dance handles macOS's default `.zshrc`
and any other conflicts.

```bash
git clone --bare https://github.com/troute/dotfiles.git $HOME/.dotfiles
alias dotfiles='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

mkdir -p $HOME/.dotfiles-backup
dotfiles checkout 2>&1 | grep -E "^\s+\." | awk '{print $1}' \
  | xargs -I{} mv {} $HOME/.dotfiles-backup/{} 2>/dev/null

dotfiles checkout
dotfiles config status.showUntrackedFiles no

exec zsh
```

### 5. Install from the Brewfile

```bash
brew bundle --file=~/.Brewfile
```

### 6. Touch ID for sudo

`pam_reattach` must load before `pam_tid` for Touch ID to work inside tmux.

```bash
sudo tee /etc/pam.d/sudo_local > /dev/null <<'EOF'
auth       optional       /opt/homebrew/lib/pam/pam_reattach.so
auth       sufficient     pam_tid.so
EOF
```

### 7. Docker Desktop first launch

Open `Docker.app` once to accept terms.

### 8. Global tools not in the Brewfile

```bash
uv tool install pylint
npm install -g @posthog/cli
```

### 9. Auth

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

### 10. Apps not in the Brewfile

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
