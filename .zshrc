# Deduplicate PATH on re-source
typeset -U path

# PATH
export PATH=$HOME/Library/Python/3.11/bin:$PATH
export PATH="/opt/homebrew/opt/postgresql@15/bin:$PATH"
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"

# History
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt EXTENDED_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt SHARE_HISTORY

# Directory navigation
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS

# Vim mode
bindkey -v
bindkey '^R' history-incremental-search-backward
bindkey '^?' backward-delete-char

# Aliases
alias vim=nvim
alias v=nvim
alias g=git
alias ll='eza -a --long --icons=auto'

# Dotfiles management (bare git repo)
alias d='dotfiles'
alias dotfiles='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# Editor
export EDITOR=nvim
export VISUAL=nvim

# Project-specific configs (safe to re-source)
source ~/.zsh/claude.zsh
source ~/.zsh/finform.zsh

# One-time setup (guarded to avoid accumulation on re-source)
if [[ -z "$_ZSHRC_LOADED" ]]; then
  autoload -Uz compinit && compinit

  # Plugins (via Homebrew)
  source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
  source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

  # fzf integration (Ctrl+R for fuzzy history)
  source <(fzf --zsh)

  # Shell hooks
  eval "$(direnv hook zsh)"
  eval "$(starship init zsh)"
  eval "$(fnm env --use-on-cd --shell zsh)"

  _ZSHRC_LOADED=1
fi
