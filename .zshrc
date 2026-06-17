# Deduplicate PATH on re-source
typeset -U path

# PATH
export PATH="/opt/homebrew/opt/postgresql@17/bin:$PATH"

# History
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt EXTENDED_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY

# Directory navigation
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS

# Vim mode
bindkey -v
bindkey '^R' history-incremental-search-backward
bindkey '^?' backward-delete-char
export KEYTIMEOUT=10

# Vim text objects (ci", da(, vi[, etc.)
autoload -U select-quoted select-bracketed
zle -N select-quoted
zle -N select-bracketed
for m in visual viopp; do
  for c in {a,i}{\',\",\`}; do
    bindkey -M $m $c select-quoted
  done
  for c in {a,i}${(s..)^:-'()[]{}<>bB'}; do
    bindkey -M $m $c select-bracketed
  done
done

# Cursor shape: block for normal mode, beam for insert
zle-keymap-select() {
  case $KEYMAP in
    vicmd)      print -n '\e[2 q' ;;
    viins|main) print -n '\e[6 q' ;;
  esac
}
zle -N zle-keymap-select
zle-line-init() { print -n '\e[6 q' }
zle -N zle-line-init

# Aliases
alias vim=nvim
alias v=nvim
alias g=git
alias ll='eza -a --long --icons=auto'
alias c=claude

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
