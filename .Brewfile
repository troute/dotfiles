# ~/.Brewfile — Homebrew dependencies for new-laptop bootstrap.
# After installing Homebrew, run: brew bundle --file=~/.Brewfile

tap "f1bonacc1/tap"

# Shell prompt and plugins
brew "starship"
brew "direnv"
brew "zsh-autosuggestions"
brew "zsh-syntax-highlighting"

# Terminal multiplexer and editor
brew "tmux"
brew "neovim"

# CLI utilities
brew "eza"
brew "fzf"
brew "gh"
brew "jq"
brew "ripgrep"
brew "tree"
brew "watch"
brew "mkcert"

# Language toolchains
brew "fnm"
brew "uv"

# Docker (Desktop provides daemon + CLI; formula adds shell completion)
brew "docker-completion"
cask "docker-desktop"

# Process orchestration
brew "f1bonacc1/tap/process-compose"

# Postgres and tooling
brew "postgresql@17", restart_service: :changed, link: true
brew "pgcli"
brew "pgvector"

# Workflow / deploy / cloud
brew "temporal", restart_service: :changed
brew "railway"
cask "gcloud-cli"

# Fonts
cask "font-roboto-mono-nerd-font"

# PAM module so Touch ID for sudo works inside tmux
# (After install, add to /etc/pam.d/sudo_local — see README.md step 5)
brew "pam-reattach"

# CLIs distributed as casks
cask "claude-code"
cask "ngrok"
