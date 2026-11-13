# Point a workspace's Claude Code auto-memory dir at the shared finform store, so
# memories written in any workspace are visible in all of them. Idempotent; migrates a
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
