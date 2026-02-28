# Create new finform directory with full setup
finform-init() {
  local n=${1:?Usage: finform-init <1-12>}
  [[ "$n" =~ ^([1-9]|1[0-2])$ ]] || { echo "Slot must be 1-12"; return 1; }

  local dir=~/dev/finform-worktrees/$n
  local src=~/dev/finform-worktrees/1
  local uvicorn_port=$((7999 + n))
  local vite_port=$((5172 + n))
  local storybook_port=$((6005 + n))
  local temporal_task_queue=$(printf "finform-worktree-%02d" "$n")

  [[ -d "$dir" ]] && { echo "$dir exists"; return 1; }

  git clone git@github.com:troute/finform.git "$dir" &&
  cd "$dir" &&
  cat > .envrc <<EOF
source .venv/bin/activate
export UVICORN_PORT=$uvicorn_port
export VITE_PORT=$vite_port
export STORYBOOK_PORT=$storybook_port
EOF
  if [[ -f "$src/.env.local" && "$n" -ne 1 ]]; then
    sed -e "s/localhost:5173/localhost:$vite_port/g" \
        -e "s/localhost:8000/localhost:$uvicorn_port/g" \
        -e "s/^TEMPORAL_TASK_QUEUE=.*/TEMPORAL_TASK_QUEUE=$temporal_task_queue/" \
        "$src/.env.local" > .env.local
    echo "VITE_PORT=$vite_port" >> .env.local
  fi
  python3.13 -m venv .venv &&
  .venv/bin/pip install -e ".[dev,test]" &&
  (cd frontend && npm install) &&
  direnv allow &&
  pre-commit install
}
alias finit='finform-init'

# Finform tmux layout: claude on left, blank/uvicorn/npm on right (+ optional storybook)
# Usage: finform-start [-s|--storybook] [1-12]
finform-start() {
  local -a opt_storybook
  zparseopts -D -E -- s=opt_storybook -storybook=opt_storybook

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

  # Detect orphan state before creating the window
  local is_orphan=false
  local changes=$(git -C "$dir" status --porcelain 2>/dev/null)
  if [[ -n "$changes" ]]; then
    local tmux_windows=$(tmux list-windows -F '#{window_name}' 2>/dev/null)
    if ! echo "$tmux_windows" | grep -q "^f-${n}\b"; then
      is_orphan=true
    fi
  fi

  # Name the tmux window
  tmux rename-window "f-$n [${VITE_PORT:-???}]"

  # Split vertically (right pane becomes selected)
  tmux split-window -h -c "$dir"

  # Split right pane horizontally
  tmux split-window -v -c "$dir"
  tmux split-window -v -c "$dir"
  tmux split-window -v -c "$dir"
  if (( ${#opt_storybook} )); then
    tmux split-window -v -c "$dir"
  fi

  # Pane layout: 0=left, 1=top-right (blank), 2=uvicorn, 3=npm, 4=temporal worker, 5=storybook (if -s)

  # Send uvicorn to pane 2
  tmux send-keys -t 2 "pip install -e '.[dev,test]' && uvicorn backend.main:app --reload" Enter

  # Send npm dev to pane 3
  tmux send-keys -t 3 "cd frontend && npm install && npm run dev" Enter

  # Send temporal worker to pane 4
  tmux send-keys -t 4 "python -m backend.temporal.worker" Enter

  if (( ${#opt_storybook} )); then
    tmux send-keys -t 5 "cd frontend && npm run storybook" Enter
  fi

  # Return to left pane and offer resume if orphan
  tmux select-pane -t 0
  local claude_flags=""
  if $is_orphan; then
    echo "Worktree $n has uncommitted changes with no active session."
    read -q "?Resume previous Claude session? [y/N] " && claude_flags="-c"
    echo
  fi
  claude $claude_flags
}
alias fstart='finform-start'
alias fs='finform-start'

# Show git status of all finform worktrees
# Usage: finform-status
finform-status() {
  local base=~/dev/finform-worktrees
  local c_green=$'\e[32m' c_yellow=$'\e[33m' c_cyan=$'\e[36m' c_red=$'\e[31m' c_reset=$'\e[0m'
  local dir slot branch branch_display changes is_dirty has_tmux has_claude
  local uvicorn_port vite_port storybook_port services services_str
  local flags git_field window_line

  local listening=$(netstat -an -p tcp 2>/dev/null | grep LISTEN)
  local claude_cwds=$(lsof -c claude -a -d cwd -Fn 2>/dev/null | grep '^n' | sed 's/^n//')

  # Get tmux window names (fast)
  local tmux_windows=""
  if [[ -n "$TMUX" ]]; then
    tmux_windows=$(tmux list-windows -F '#{window_name}' 2>/dev/null)
  fi

  for n in {1..12}; do
    dir="$base/$n"
    slot=$(printf "%02d" "$n")

    if [[ ! -d "$dir" ]]; then
      echo "$slot: ---"
      continue
    fi

    if [[ ! -d "$dir/.git" ]]; then
      echo "$slot: (not a git repo)"
      continue
    fi

    branch=$(git -C "$dir" rev-parse --abbrev-ref HEAD 2>/dev/null)
    changes=$(git -C "$dir" status --porcelain 2>/dev/null)

    if [[ -z "$changes" ]]; then
      is_dirty=false
    else
      is_dirty=true
    fi

    # Check for tmux window and claude session
    has_tmux=false
    has_claude=false
    if [[ -n "$tmux_windows" ]]; then
      window_line=$(echo "$tmux_windows" | grep "^f-${n}\b")
      [[ -n "$window_line" ]] && has_tmux=true
    fi
    if [[ -n "$claude_cwds" ]]; then
      echo "$claude_cwds" | grep -q "^${dir}$" && has_claude=true
    fi

    # Build git status field (5 chars visible: clean/dirty)
    git_field=""
    if $is_dirty; then
      git_field="${c_yellow}dirty${c_reset}"
    else
      git_field="${c_green}clean${c_reset}"
    fi

    # Build services field
    uvicorn_port=$((7999 + n))
    vite_port=$((5172 + n))
    storybook_port=$((6005 + n))

    services=()
    echo "$listening" | grep -q "\.${uvicorn_port} " && services+="api:${uvicorn_port}"
    echo "$listening" | grep -q "\.${vite_port} " && services+="vite:${vite_port}"
    echo "$listening" | grep -q "\.${storybook_port} " && services+="storybook:${storybook_port}"

    services_str=""
    if (( ${#services} )); then
      services_str="  ${c_cyan}[${(j:, :)services}]${c_reset}"
    fi

    # Build flags (claude, orphan)
    flags=""
    if $has_claude; then
      flags="  ${c_cyan}claude${c_reset}"
    fi
    if $is_dirty && ! $has_tmux; then
      flags="${flags}  ${c_red}orphan${c_reset}"
    fi

    # Color branch name: staging=green, main=yellow, other=plain
    local padded_branch=$(printf "%-20s" "$branch")
    if [[ "$branch" == "staging" ]]; then
      branch_display="${c_green}${padded_branch}${c_reset}"
    elif [[ "$branch" == "main" ]]; then
      branch_display="${c_yellow}${padded_branch}${c_reset}"
    else
      branch_display="$padded_branch"
    fi

    printf "%s: %b  %b%b%b\n" "$slot" "$git_field" "$branch_display" "$services_str" "$flags"
  done
}
alias fstatus='finform-status'
alias fst='finform-status'

# Pull all clean finform worktrees on staging
# Usage: finform-pull
finform-pull() {
  local base=~/dev/finform-worktrees
  local pulled=0
  local skipped=0
  local c_green=$'\e[32m' c_yellow=$'\e[33m' c_red=$'\e[31m' c_dim=$'\e[2m' c_reset=$'\e[0m'
  local dir slot output branch changes old_head new_head commit_count dirty_count

  for n in {1..12}; do
    dir="$base/$n"

    [[ ! -d "$dir" ]] && continue
    [[ ! -d "$dir/.git" ]] && continue

    slot=$(printf "%02d" "$n")
    branch=$(git -C "$dir" rev-parse --abbrev-ref HEAD 2>/dev/null)

    if [[ "$branch" != "staging" ]]; then
      echo "$slot: ${c_yellow}skipped${c_reset} ${c_dim}($branch)${c_reset}"
      ((skipped++))
      continue
    fi

    changes=$(git -C "$dir" status --porcelain 2>/dev/null)

    if [[ -n "$changes" ]]; then
      dirty_count=$(echo "$changes" | wc -l | tr -d ' ')
      echo "$slot: ${c_yellow}skipped${c_reset} ${c_dim}($dirty_count dirty files)${c_reset}"
      ((skipped++))
      continue
    fi

    old_head=$(git -C "$dir" rev-parse HEAD 2>/dev/null)
    output=$(git -C "$dir" pull 2>&1)
    if [[ $? -eq 0 ]]; then
      new_head=$(git -C "$dir" rev-parse HEAD 2>/dev/null)
      if [[ "$old_head" == "$new_head" ]]; then
        echo "$slot: up to date"
      else
        commit_count=$(git -C "$dir" rev-list "$old_head..$new_head" --count 2>/dev/null)
        if (( commit_count == 1 )); then
          echo "$slot: ${c_green}pulled${c_reset} ${c_dim}(1 commit)${c_reset}"
        else
          echo "$slot: ${c_green}pulled${c_reset} ${c_dim}($commit_count commits)${c_reset}"
        fi
      fi
      ((pulled++))
    else
      echo "$slot: ${c_red}pull failed${c_reset}"
    fi
  done

}
alias fpull='finform-pull'
alias fp='finform-pull'

# Open finform in browser
# Usage: finform-open [-S|--staging] [-P|--production] [-s|--storybook] [-t|--temporal] [1-12]
finform-open() {
  local -a opt_staging opt_production opt_storybook opt_temporal
  zparseopts -D -E -- \
    S=opt_staging -staging=opt_staging \
    P=opt_production -production=opt_production \
    s=opt_storybook -storybook=opt_storybook \
    t=opt_temporal -temporal=opt_temporal

  if (( ${#opt_production} )); then
    open "https://app.finform.ai"
    return
  fi

  if (( ${#opt_staging} )); then
    open "https://staging.app.finform.ai"
    return
  fi

  # Resolve slot number from argument or environment
  local n
  if [[ -n "$1" ]]; then
    n=$1
    [[ "$n" =~ ^([1-9]|1[0-2])$ ]] || { echo "Slot must be 1-12"; return 1; }
  elif [[ -n "$VITE_PORT" ]]; then
    n=$((VITE_PORT - 5172))
  else
    echo "Usage: finform-open [-S|--staging] [-P|--production] [-s|--storybook] [-t|--temporal] [1-12]"
    return 1
  fi

  if (( ${#opt_temporal} )); then
    local queue=$(printf "finform-worktree-%02d" "$n")
    open "http://localhost:8233/namespaces/default/workflows?query=%60TaskQueue%60%3D%22${queue}%22"
    return
  fi

  if (( ${#opt_storybook} )); then
    open "http://localhost:$((6005 + n))"
    return
  fi

  open "http://localhost:$((5172 + n))"
}
alias fopen='finform-open'
alias fo='finform-open'
