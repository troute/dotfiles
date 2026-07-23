# ~/.Brewfile — usage: brew bundle --global/-g

tap "f1bonacc1/tap"

# Shell prompt and plugins
brew "starship"
brew "direnv"
brew "zsh-autosuggestions"
brew "zsh-syntax-highlighting"

# Terminal multiplexer
brew "tmux"

# NeoVim and dependencies
brew "neovim"
brew "stylua"
brew "tree-sitter-cli"

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

# Docker
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

# PAM module so Touch ID for sudo works inside tmux
# (After install, add to /etc/pam.d/sudo_local — see README.md step 5)
brew "pam-reattach"

# CLIs distributed as casks
cask "claude-code"
cask "ngrok"

# GUI applications
cask "1password"
cask "google-chrome"
cask "brave-browser"
cask "ghostty"
cask "linear"
cask "wispr-flow"
cask "tailscale-app"
cask "zoom"
cask "stats"
cask "libreoffice"

# Mac App Store (mas)
brew "mas"
mas "Magnet", id: 441258766
