# Dotfiles

My personal dotfiles, managed using a git bare repository.

## Setup

```bash
# Clone the bare repository to ~/.dotfiles
git clone --bare git@github.com:yourusername/dotfiles.git $HOME/.dotfiles
```

```bash
# Use an alias for easier management
alias dotfiles='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
```

```bash
# Checkout the files
dotfiles checkout
```

```bash
# Hide untracked files
dotfiles config --local status.showUntrackedFiles no
```
