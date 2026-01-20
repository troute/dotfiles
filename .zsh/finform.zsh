# Create new finform directory with full setup
finform-init() {
  local n=${1:?Usage: finform-init <1-12>}
  [[ "$n" =~ ^([1-9]|1[0-2])$ ]] || { echo "Slot must be 1-12"; return 1; }

  local dir=~/dev/finform-worktrees/$n
  local src=~/dev/finform-worktrees/1
  local uvicorn_port=$((7999 + n))
  local vite_port=$((5172 + n))

  [[ -d "$dir" ]] && { echo "$dir exists"; return 1; }

  git clone git@github.com:troute/finform.git "$dir" &&
  cd "$dir" &&
  cat > .envrc <<EOF
source .venv/bin/activate
export UVICORN_PORT=$uvicorn_port
EOF
  if [[ -f "$src/.env.local" && "$n" -ne 1 ]]; then
    sed -e "s/localhost:5173/localhost:$vite_port/g" \
        -e "s/localhost:8000/localhost:$uvicorn_port/g" \
        "$src/.env.local" > .env.local
    echo "VITE_PORT=$vite_port" >> .env.local
  fi
  python3.13 -m venv .venv &&
  .venv/bin/pip install -e ".[dev,test]" &&
  (cd frontend && npm install) &&
  direnv allow &&
  pre-commit install
}
alias ff-init='finform-init'

# Finform tmux layout: claude on left, blank/uvicorn/npm on right
# Usage: finform-start [1-12]
finform-start() {
  local n=${1:-1}
  [[ "$n" =~ ^([1-9]|1[0-2])$ ]] || { echo "Slot must be 1-12"; return 1; }

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
  tmux send-keys -t 3 "cd frontend" Enter
  tmux send-keys -t 3 "npm run dev" Enter

  # Top-right (pane 1) stays blank

  # Return to left pane and run claude
  tmux select-pane -t 0
  claude
}
alias ff-start='finform-start'

# Show git status of all finform worktrees
# Usage: finform-status
finform-status() {
  local base=~/dev/finform-worktrees

  for n in {1..12}; do
    local dir="$base/$n"
    local slot=$(printf "%02d" "$n")

    if [[ ! -d "$dir" ]]; then
      echo "$slot: ---"
      continue
    fi

    if [[ ! -d "$dir/.git" ]]; then
      echo "$slot: (not a git repo)"
      continue
    fi

    local branch=$(git -C "$dir" rev-parse --abbrev-ref HEAD 2>/dev/null)
    local changes=$(git -C "$dir" status --porcelain 2>/dev/null)

    if [[ -z "$changes" ]]; then
      echo "$slot: \e[32mclean\e[0m    $branch"
    else
      echo "$slot: dirty    $branch"
    fi
  done
}
alias ff-status='finform-status'

# Pull all clean finform worktrees
# Usage: finform-pull
finform-pull() {
  local base=~/dev/finform-worktrees
  local pulled=0
  local skipped=0

  for n in {1..12}; do
    local dir="$base/$n"

    [[ ! -d "$dir" ]] && continue
    [[ ! -d "$dir/.git" ]] && continue

    local changes=$(git -C "$dir" status --porcelain 2>/dev/null)

    local slot=$(printf "%02d" "$n")

    if [[ -n "$changes" ]]; then
      echo "$slot: \e[33mskipped (dirty)\e[0m"
      ((skipped++))
      continue
    fi

    local output=$(git -C "$dir" pull 2>&1)
    if [[ $? -eq 0 ]]; then
      if [[ "$output" == *"Already up to date"* ]]; then
        echo "$slot: up to date"
      else
        echo "$slot: \e[32mpulled\e[0m"
      fi
      ((pulled++))
    else
      echo "$slot: \e[31mpull failed\e[0m"
    fi
  done

  echo ""
  echo "Pulled: $pulled, Skipped: $skipped"
}
alias ff-pull='finform-pull'
