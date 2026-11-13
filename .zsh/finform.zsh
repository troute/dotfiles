# Point a worktree's Claude Code auto-memory dir at the shared finform store, so
# memories written in any slot are visible in all of them. Idempotent; migrates a
# pre-existing real memory dir into the store before replacing it with the symlink.
# Slugs start with '-', so operate via the resolved path, never a bare glob.
finform-link-memory() {
  local root="${1:-$PWD}"; root="${root:a}"  # absolutize but do NOT resolve symlinks (match Claude's literal slug)
  local shared="$HOME/.claude/finform-memory"
  local memdir="$HOME/.claude/projects/${root//\//-}/memory"
  mkdir -p "$shared" "${memdir:h}"
  if [[ -L "$memdir" ]]; then
    [[ "$(readlink "$memdir")" == "$shared" ]] && return 0
    rm "$memdir"
  elif [[ -d "$memdir" ]]; then
    local f
    for f in "$memdir"/*.md(N); do
      [[ "${f:t}" == "MEMORY.md" ]] || cp -n "$f" "$shared/"
    done
    rm -rf "$memdir"
  fi
  ln -s "$shared" "$memdir"
}

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
    tmux_windows=$(tmux list-windows -a -F '#{window_name}' 2>/dev/null)
  fi
}

# Check if worktree N is idle (clean, on staging, no active window/services).
# A `wt-N` tmux window is the sole ownership signal: sessions running in a
# differently-named window are read-only visitors and don't reserve the slot.
# Caller must declare listening, claude_cwds, tmux_windows and call _finform-prefetch.
_finform-is-idle() {
  local n=$1
  local dir="$HOME/dev/finform-worktrees/$n"
  [[ ! -d "$dir/.git" ]] && return 1
  local branch=$(git -C "$dir" rev-parse --abbrev-ref HEAD 2>/dev/null)
  [[ "$branch" != "staging" ]] && return 1
  [[ -n "$(git -C "$dir" status --porcelain 2>/dev/null)" ]] && return 1
  echo "$tmux_windows" | grep -q "^wt-${n}\b" && return 1
  local uvicorn_port=$((7999 + n)) vite_port=$((5172 + n)) storybook_port=$((6005 + n))
  echo "$listening" | grep -q "\.${uvicorn_port} " && return 1
  echo "$listening" | grep -q "\.${vite_port} " && return 1
  echo "$listening" | grep -q "\.${storybook_port} " && return 1
  return 0
}

# Emit one JSON object per worktree (JSONL) with the facts the
# finform-prune-worktrees skill needs to triage each slot. Reuses
# _finform-prefetch for shared state; gathers docker containers once up front.
# Fetches origin/staging in every clone first (parallel, best-effort) so
# divergence is measured against the real remote, not each clone's stale local
# `staging` — clones drift tens of commits behind and badly mislead otherwise.
# NOTE: callers from a non-interactive shell must `source ~/.zsh/finform.zsh`
# first, since compinit strips the private helpers in that context.
_finform-prune-scan() {
  setopt local_options null_glob
  local base=~/dev/finform-worktrees
  local listening claude_cwds tmux_windows
  _finform-prefetch
  local docker_names=$(docker ps --format '{{.Names}}' 2>/dev/null)

  local n dir branch changes dirty dirty_count ahead behind

  # Refresh origin/staging everywhere in parallel (best-effort; skips if offline).
  for n in {1..12}; do
    [[ -d "$base/$n/.git" ]] && \
      git -C "$base/$n" fetch --quiet origin '+refs/heads/staging:refs/remotes/origin/staging' 2>/dev/null &
  done
  wait
  local uvicorn_port vite_port storybook_port hocuspocus_port
  local has_api has_vite has_storybook has_hocus has_socket has_s3 has_uno
  local has_tmux tmux_name has_claude proj live bytes lines

  for n in {1..12}; do
    dir="$base/$n"
    if [[ ! -d "$dir/.git" ]]; then
      printf '{"slot":%d,"exists":false}\n' "$n"
      continue
    fi

    branch=$(git -C "$dir" rev-parse --abbrev-ref HEAD 2>/dev/null)
    changes=$(git -C "$dir" status --porcelain 2>/dev/null)
    if [[ -n "$changes" ]]; then
      dirty=true; dirty_count=$(echo "$changes" | grep -c .)
    else
      dirty=false; dirty_count=0
    fi
    ahead=$(git -C "$dir" rev-list --count origin/staging..HEAD 2>/dev/null); ahead=${ahead:-0}
    behind=$(git -C "$dir" rev-list --count HEAD..origin/staging 2>/dev/null); behind=${behind:-0}

    uvicorn_port=$((7999 + n)); vite_port=$((5172 + n))
    storybook_port=$((6005 + n)); hocuspocus_port=$((4170 + n))
    has_api=false;       echo "$listening" | grep -q "\.${uvicorn_port} " && has_api=true
    has_vite=false;      echo "$listening" | grep -q "\.${vite_port} " && has_vite=true
    has_storybook=false; echo "$listening" | grep -q "\.${storybook_port} " && has_storybook=true
    has_hocus=false;     echo "$listening" | grep -q "\.${hocuspocus_port} " && has_hocus=true
    has_socket=false;    [[ -S "/tmp/process-compose-finform-${n}.sock" ]] && has_socket=true
    has_s3=false;        echo "$docker_names" | grep -qx "s3mock-finform-${n}" && has_s3=true
    has_uno=false;       echo "$docker_names" | grep -qx "unoserver-finform-${n}" && has_uno=true

    has_tmux=false; tmux_name=""
    if [[ -n "$tmux_windows" ]]; then
      tmux_name=$(echo "$tmux_windows" | grep "^wt-${n}\b" | head -1)
      [[ -n "$tmux_name" ]] && has_tmux=true
    fi
    has_claude=false
    echo "$claude_cwds" | grep -qx "$dir" && has_claude=true

    proj="$HOME/.claude/projects/-Users-mtroute-dev-finform-worktrees-${n}"
    local -a transcripts=( "$proj"/*.jsonl )
    live=""; (( ${#transcripts} )) && live=$(ls -t "${transcripts[@]}" | head -1)
    bytes=0; lines=0
    if [[ -n "$live" ]]; then
      bytes=$(wc -c < "$live" 2>/dev/null | tr -d ' ')
      lines=$(wc -l < "$live" 2>/dev/null | tr -d ' ')
    fi

    printf '{"slot":%d,"exists":true,"branch":"%s","dirty":%s,"dirty_count":%d,"ahead":%d,"behind":%d,"services":{"api":%s,"vite":%s,"storybook":%s,"hocuspocus":%s,"pc_socket":%s,"s3mock":%s,"unoserver":%s},"has_tmux":%s,"tmux_name":"%s","has_claude":%s,"live_transcript":"%s","transcript_bytes":%d,"transcript_lines":%d}\n' \
      "$n" "$branch" "$dirty" "$dirty_count" "$ahead" "$behind" \
      "$has_api" "$has_vite" "$has_storybook" "$has_hocus" "$has_socket" "$has_s3" "$has_uno" \
      "$has_tmux" "${tmux_name//\"/}" "$has_claude" "$live" "$bytes" "$lines"
  done
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
# With -s/--slim, process-compose is not booted and the layout is 2-pane:
# Claude (0) on the left, terminal (1) on the right.
#
# Usage: finform-start [-s|--slim] [name]
#   no name: an idle workspace on staging (finform workspace claim), created if none
#   a name:  that workspace, created if it doesn't exist
finform-start() {
  local -a opt_slim
  zparseopts -D -E -- s=opt_slim -slim=opt_slim
  [[ -n "$TMUX" ]] || { echo "Not in a tmux session"; return 1; }

  local dir
  if [[ -z "$1" ]]; then
    dir=$(finform workspace claim) || return 1
  elif [[ -d "$HOME/dev/finform/$1" ]]; then
    dir="$HOME/dev/finform/$1"
  else
    dir=$(finform workspace new --name "$1") || return 1
  fi
  local name=${dir:t}
  echo "Workspace $name"

  finform-link-memory "$dir"
  cd "$dir"
  tmux rename-window "$name"

  # Pane 0: Claude (left)
  # Pane 1: terminal (right; top-right when not slim)
  # Pane 2: the workspace's services (bottom-right; omitted when slim)
  tmux split-window -h -c "$dir"
  if (( ! ${#opt_slim} )); then
    tmux split-window -v -c "$dir" -t 1
    tmux send-keys -t 2 "finform workspace up" Enter
  fi
  tmux select-pane -t 0

  # Uncommitted work means a session was here before; offer to carry on with it.
  local claude_flags
  if [[ -n "$(git -C "$dir" status --porcelain 2>/dev/null)" ]]; then
    echo "Workspace $name has uncommitted changes."
    read -q "?Resume its previous Claude session? [y/N] " && claude_flags="-c"
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
      window_line=$(echo "$tmux_windows" | grep "^wt-${n}\b")
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

# Full teardown of a worktree's running state: process-compose (which also stops
# its per-slot docker s3mock/unoserver via their shutdown hooks), any Claude
# session rooted in the worktree, and the tmux window. The working tree is left
# untouched — uncommitted changes stay on disk. With no arg, self-targets the
# current worktree via $FINFORM_SLOT.
# Usage: finform-kill [1-12]
finform-kill() {
  local n=${1:-$FINFORM_SLOT}
  if [[ -z "$n" ]]; then
    echo "Usage: finform-kill <1-12> (or run inside a worktree to self-target)"
    return 1
  fi
  [[ "$n" =~ ^([1-9]|1[0-2])$ ]] || { echo "Slot must be 1-12"; return 1; }

  local dir="$HOME/dev/finform-worktrees/$n"
  local socket="/tmp/process-compose-finform-${n}.sock"

  # 1. Stop process-compose — also stops its docker containers via shutdown hooks.
  if [[ -S "$socket" ]]; then
    echo "Stopping process-compose (slot $n)..."
    process-compose -u "$socket" down 2>/dev/null
  fi

  # 2. Belt-and-suspenders: stop per-slot docker containers if they linger
  #    (they run with --rm, so stopping removes them).
  docker stop "s3mock-finform-${n}" "unoserver-finform-${n}" 2>/dev/null

  # 3. Kill any Claude session whose cwd is this worktree (covers sessions
  #    not running inside the tmux window). Excludes the daemon and bg workers.
  local pids pid cwd
  pids=$(ps -ax -o pid,command 2>/dev/null | awk '/[c]laude/ && !/--bg-/ && !/daemon run/ {print $1}')
  for pid in ${(f)pids}; do
    cwd=$(lsof -p "$pid" -a -d cwd -Fn 2>/dev/null | grep '^n' | sed 's/^n//')
    [[ "$cwd" == "$dir" ]] && { echo "Killing Claude session (pid $pid)..."; kill "$pid" 2>/dev/null; }
  done

  # 4. Close the tmux window (also kills the Claude pane). Runs last: in a
  #    self-teardown this terminates the calling shell.
  local win
  win=$(tmux list-windows -a -F '#{window_id} #{window_name}' 2>/dev/null \
        | awk -v n="$n" '$2 ~ "^wt-"n"($|[^0-9])" {print $1; exit}')
  if [[ -n "$win" ]]; then
    echo "Closing tmux window $win (slot $n)..."
    tmux kill-window -t "$win"
  fi
}
alias fkill='finform-kill'

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

# Open Finform in the browser: a workspace (by name, or the current one), its Storybook or Temporal UI, its database,
# or staging or production.
# Usage: finform-open [-S|--staging] [-P|--production] [-s|--storybook] [-t|--temporal] [-p|--postgres] [name]
finform-open() {
  local -a opt_staging opt_production opt_storybook opt_postgres opt_temporal
  zparseopts -D -E -- \
    S=opt_staging -staging=opt_staging \
    P=opt_production -production=opt_production \
    s=opt_storybook -storybook=opt_storybook \
    p=opt_postgres -postgres=opt_postgres \
    t=opt_temporal -temporal=opt_temporal

  (( ${#opt_production} )) && { open "https://app.finform.ai"; return; }
  (( ${#opt_staging} )) && { open "https://staging.app.finform.ai"; return; }

  local name=${1:-$WORKSPACE_NAME}
  [[ -n "$name" ]] || { echo "Usage: finform-open [-S|-P|-s|-t|-p] [name] (or run inside a workspace)"; return 1; }
  if (( ${#opt_postgres} )); then
    local url="postgresql://postgres@postgres.finform-$name.orb.local/finform"
    pgcli "$url" || psql "$url"
  elif (( ${#opt_storybook} )); then
    open "https://storybook.$name.finform.local"
  elif (( ${#opt_temporal} )); then
    open "https://temporal.$name.finform.local"
  else
    open "https://$name.finform.local"
  fi
}
alias fopen='finform-open'
alias fo='finform-open'
