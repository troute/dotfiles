# Claude Code with daily brew upgrade
# Usage: finform-cc [1-6] [--resume] [other claude args...]
#   finform-cc        → slot 1
#   finform-cc 3      → slot 3
#   finform-cc --resume → slot 1 with resume
#   finform-cc 3 --resume → slot 3 with resume
finform-cc() {
  local marker="/tmp/.claude_last_upgrade"
  local today=$(date +%Y-%m-%d)
  if [[ ! -f "$marker" ]] || [[ "$(cat "$marker")" != "$today" ]]; then
    brew upgrade claude-code
    echo "$today" > "$marker"
  fi

  local slot=1
  local args=()

  for arg in "$@"; do
    if [[ "$arg" =~ ^[1-6]$ ]]; then
      slot="$arg"
    else
      args+=("$arg")
    fi
  done

  cd ~/dev/finform-worktrees/$slot
  claude "${args[@]}"
}

# Finform tmux layout: claude on left, blank/uvicorn/npm on right
finform-start() {
  local n=${1:-1}
  local dir="$HOME/dev/finform-worktrees/$n"

  if [[ ! -d "$dir" ]]; then
    echo "Directory $dir does not exist"
    return 1
  fi

  if [[ -z "$TMUX" ]]; then
    echo "Not in a tmux session"
    return 1
  fi

  cd "$dir"

  # Name the tmux window
  tmux rename-window "finform-$n"

  # Split vertically (right pane becomes selected)
  tmux split-window -h -c "$dir"

  # Split right pane horizontally twice for 3 panes
  tmux split-window -v -c "$dir"
  tmux split-window -v -c "$dir"

  # Pane layout: 0=left, 1=top-right, 2=middle-right, 3=bottom-right (selected)

  # Send uvicorn to middle-right
  tmux send-keys -t 2 "uvicorn backend.main:app --reload" Enter

  # Send npm to bottom-right (frontend subdir)
  tmux send-keys -t 3 "cd frontend && npm run dev" Enter

  # Top-right (pane 1) stays blank

  # Return to left pane and run claude
  tmux select-pane -t 0
  claude
}
