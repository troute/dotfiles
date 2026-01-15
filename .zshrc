export PATH=$HOME/Library/Python/3.11/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME=""  # Unset to use Starship

# Oh My Zsh
zstyle ':omz:update' mode auto      # update automatically without asking
plugins=(git python pip colored-man-pages zsh-autosuggestions zsh-syntax-highlighting)
source $ZSH/oh-my-zsh.sh

alias vim=nvim
alias v=nvim
compdef vim=nvim
compdef v=nvim

# Allow management of dotfiles using a bare git repository
alias dotfiles='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
compdef dotfiles=git

# Project-specific shell configs
source ~/.zsh/claude.zsh
source ~/.zsh/finform.zsh

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

# Vim mode (must be before starship init)
bindkey -v
bindkey '^R' history-incremental-search-backward

eval "$(direnv hook zsh)"
eval "$(starship init zsh)"

alias ll='eza -a --long --icons'

# Neovim for default editor
export EDITOR=nvim
export VISUAL=nvim

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

export PATH="/opt/homebrew/opt/postgresql@15/bin:$PATH"
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
