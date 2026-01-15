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

# Completion
autoload -Uz compinit && compinit

# Vim mode
bindkey -v
bindkey '^R' history-incremental-search-backward

# Plugins (via Homebrew)
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# fzf integration (Ctrl+R for fuzzy history)
source <(fzf --zsh)

# Aliases
alias vim=nvim
alias v=nvim
alias ll='eza -a --long --icons'
compdef ll=ls

# Dotfiles management (bare git repo)
alias d='dotfiles'
alias dotfiles='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# Editor
export EDITOR=nvim
export VISUAL=nvim

# direnv
eval "$(direnv hook zsh)"

# Prompt (Starship)
eval "$(starship init zsh)"

# Project-specific configs
source ~/.zsh/claude.zsh
source ~/.zsh/finform.zsh

# fnm (fast node manager)
eval "$(fnm env --use-on-cd --shell zsh)"

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/Users/mtroute/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/mtroute/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/Users/mtroute/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/Users/mtroute/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<
