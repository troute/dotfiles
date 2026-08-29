# Dotfiles bare repo: git dir is ~/.dotfiles, work tree is $HOME.
alias dotfiles='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
alias d='dotfiles'

# Dotfiles tmux layout (2-pane):
#
# +------------------+------------------+
# |                  |                  |
# |   Claude (0)     |   terminal (1)   |
# |                  |                  |
# +------------------+------------------+
#
# Usage: dotfiles-start
dotfiles-start() {
  local dir="$HOME/.dotfiles"

  if [[ -z "$TMUX" ]]; then
    echo "Not in a tmux session"
    return 1
  fi

  cd "$dir"

  local changes=$(git --git-dir="$dir" --work-tree="$HOME" status --porcelain 2>/dev/null)

  tmux rename-window "dotfiles"
  tmux split-window -h -c "$dir"
  tmux select-pane -t 0

  local claude_flags
  if [[ -n "$changes" ]]; then
    echo "Dotfiles have uncommitted changes."
    read -q "?Resume previous Claude session? [y/N] " && claude_flags="-c"
    echo
  fi
  claude ${claude_flags:-}
}
alias dstart='dotfiles-start'
alias ds='dotfiles-start'
