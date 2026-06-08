# Create new finform directory with full setup
finform-init() {
  local n=${1:?Usage: finform-init <1-12>}
  [[ "$n" =~ ^([1-9]|1[0-2])$ ]] || { echo "Slot must be 1-12"; return 1; }

  local dir=~/dev/finform-worktrees/$n
  local src=~/dev/finform-worktrees/1
  local uvicorn_port=$((7999 + n))
  local vite_port=$((5172 + n))
  local storybook_port=$((6005 + n))
  local hocuspocus_port=$((4170 + n))
  local unoserver_port=$((2002 + n))
  local s3mock_port=$((9089 + n))
  local temporal_task_queue_prefix="finform_${n}"
  local db_name="finform_${n}"

  [[ -d "$dir" ]] && { echo "$dir exists"; return 1; }

  git clone git@github.com:troute/finform.git "$dir" &&
  cd "$dir" &&
  createdb "$db_name" 2>/dev/null
  cat > .envrc <<EOF
source_up
source .venv/bin/activate
export FINFORM_SLOT=$n
export UVICORN_PORT=$uvicorn_port
export VITE_PORT=$vite_port
export STORYBOOK_PORT=$storybook_port
export PC_PORT_NUM=$((8079 + n))
export PC_SOCKET_PATH="/tmp/process-compose-finform-${n}.sock"
export DATABASE_URL=postgresql://mtroute@localhost/$db_name
export HOCUSPOCUS_PORT=$hocuspocus_port
export UNOSERVER_PORT=$unoserver_port
export S3MOCK_PORT=$s3mock_port
export AWS_ENDPOINT_URL=http://localhost:\${S3MOCK_PORT}
export AWS_S3_BUCKET_NAME=finform-\${FINFORM_SLOT}
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-east-1
EOF
  if [[ -f "$src/.env.local" && "$n" -ne 1 ]]; then
    sed -e "s/localhost:5173/localhost:$vite_port/g" \
        -e "s/localhost:8000/localhost:$uvicorn_port/g" \
        -e "s|^DATABASE_URL=.*|DATABASE_URL=postgresql://mtroute@localhost/$db_name|" \
        -e "s/^TEMPORAL_TASK_QUEUE_PREFIX=.*/TEMPORAL_TASK_QUEUE_PREFIX=$temporal_task_queue_prefix/" \
        -e "s/^UNOSERVER_PORT=.*/UNOSERVER_PORT=$unoserver_port/" \
        "$src/.env.local" > .env.local
  fi
  uv sync &&
  alembic upgrade head &&
  (cd frontend && npm install) &&
  direnv allow &&
  pre-commit install &&
  pre-commit install --hook-type pre-push
}
alias finit='finform-init'

# Prefetch shared state for worktree checks.
# Sets listening, claude_cwds, tmux_windows in caller scope.
_finform-prefetch() {
  listening=$(netstat -an -p tcp 2>/dev/null | grep LISTEN)
  # Only consider user-facing claude CLI sessions; exclude the daemon and its
  # pre-warmed bg-spare PTY workers, which retain cwd from where they were spawned.
  local pids
  pids=$(ps -ax -o pid,command 2>/dev/null | awk '/[c]laude/ && !/--bg-/ && !/daemon run/ {print $1}' | paste -sd, -)
  claude_cwds=""
  [[ -n "$pids" ]] && claude_cwds=$(lsof -p "$pids" -a -d cwd -Fn 2>/dev/null | grep '^n' | sed 's/^n//')
  tmux_windows=""
  if [[ -n "$TMUX" ]]; then
    tmux_windows=$(tmux list-windows -F '#{window_name}' 2>/dev/null)
  fi
}

# Check if worktree N is idle (clean, on staging, no active sessions/services).
# Caller must declare listening, claude_cwds, tmux_windows and call _finform-prefetch.
_finform-is-idle() {
  local n=$1
  local dir="$HOME/dev/finform-worktrees/$n"
  [[ ! -d "$dir/.git" ]] && return 1
  local branch=$(git -C "$dir" rev-parse --abbrev-ref HEAD 2>/dev/null)
  [[ "$branch" != "staging" ]] && return 1
  [[ -n "$(git -C "$dir" status --porcelain 2>/dev/null)" ]] && return 1
  echo "$tmux_windows" | grep -q "^f-${n}\b" && return 1
  echo "$claude_cwds" | grep -q "^${dir}$" && return 1
  local uvicorn_port=$((7999 + n)) vite_port=$((5172 + n)) storybook_port=$((6005 + n))
  echo "$listening" | grep -q "\.${uvicorn_port} " && return 1
  echo "$listening" | grep -q "\.${vite_port} " && return 1
  echo "$listening" | grep -q "\.${storybook_port} " && return 1
  return 0
}

# Finform tmux layout (3-pane, services managed by process-compose):
#
# +------------------+------------------+
# |                  |                  |
# |   Claude (0)     |   terminal (1)   |
# |                  |                  |
# |                  +------------------+
# |                  | process-compose  |
# |                  |     TUI (2)      |
# +------------------+------------------+
#
# Usage: finform-start [1-12]  (no arg = first clean worktree on staging)
finform-start() {
  local n
  if [[ -n "$1" ]]; then
    n=$1
    [[ "$n" =~ ^([1-9]|1[0-2])$ ]] || { echo "Slot must be 1-12"; return 1; }
  else
    local listening claude_cwds tmux_windows
    _finform-prefetch
    for candidate in {1..12}; do
      if _finform-is-idle $candidate; then
        n=$candidate
        break
      fi
    done
    if [[ -z "$n" ]]; then
      echo "No idle worktree found"
      return 1
    fi
    echo "Auto-selected worktree $n"
  fi

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

  tmux rename-window "f-$n [${VITE_PORT:-???}]"

  # Build 3-pane layout: Claude (left), terminal + process-compose (right)
  tmux split-window -h -c "$dir"
  tmux split-window -v -c "$dir" -t 1

  # Pane 0: Claude (left)
  # Pane 1: terminal (top-right)
  # Pane 2: process-compose TUI (bottom-right)

  tmux send-keys -t 2 "process-compose up" Enter

  # Return to left pane and offer resume if orphan
  tmux select-pane -t 0
  if $is_orphan; then
    echo "Worktree $n has uncommitted changes with no active session."
    read -q "?Resume previous Claude session? [y/N] " && local claude_flags="-c"
    echo
  fi
  eval "$(direnv export zsh)"
  claude ${claude_flags:-}
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

  local listening claude_cwds tmux_windows
  _finform-prefetch

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
    if [[ "$branch" == "staging" ]]; then
      branch_display="${c_green}${branch}${c_reset}"
    elif [[ "$branch" == "main" ]]; then
      branch_display="${c_yellow}${branch}${c_reset}"
    else
      branch_display="$branch"
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
  local -a opt_staging opt_production opt_storybook opt_postgres opt_temporal
  zparseopts -D -E -- \
    S=opt_staging -staging=opt_staging \
    P=opt_production -production=opt_production \
    s=opt_storybook -storybook=opt_storybook \
    p=opt_postgres -postgres=opt_postgres \
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

  if (( ${#opt_storybook} )); then
    open "http://localhost:$((6005 + n))"
    return
  fi

  if (( ${#opt_postgres} )); then
    pgcli "finform_${n}" || psql "finform_${n}"
    return
  fi

  if (( ${#opt_temporal} )); then
    local queue="finform_${n}"
    open "http://localhost:8233/namespaces/default/workflows?query=%60TaskQueue%60%3D%22${queue}%22"
    return
  fi

  open "http://localhost:$((5172 + n))"
}
alias fopen='finform-open'
alias fo='finform-open'
