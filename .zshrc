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

# Claude Code usage (a little nasty, but whatevs)
alias ccusage='(cd ~/dev/finform/frontend && npx ccusage)'

# Dense ccusage display with sparklines
ccusage-dense() {
  (cd ~/dev/finform/frontend && npx ccusage daily --json | jq -r '
  .daily as $all_daily |
  ($all_daily[0].date | strptime("%Y-%m-%d") | mktime) as $first_date |
  ($all_daily[-1].date | strptime("%Y-%m-%d") | mktime) as $last_date |
  (($last_date - $first_date) / 86400 + 1 | floor) as $calendar_days |
  ($all_daily | map({key: .date, value: .totalCost}) | from_entries) as $costs |
  ([range($calendar_days | floor)] | map(($first_date + (. * 86400)) | strftime("%Y-%m-%d"))) as $all_dates |

  ($all_dates | map($costs[.] // 0) | max) as $max_cost |

  # Helper function to get color based on cost level (green = high, red = low)
  def get_color($cost; $max):
    if $cost == 0 then "\u001b[90m"
    elif ($cost / $max) > 0.6 then "\u001b[32m"
    elif ($cost / $max) > 0.3 then "\u001b[33m"
    else "\u001b[31m"
    end;

  # Output daily data
  ($all_dates[] |
    (. | strptime("%Y-%m-%d") | strftime("%A")[0:1]) as $day |
    ($costs[.] // 0) as $cost |
    (if $cost == 0 then 0 else (($cost / $max_cost * 7) | floor | if . > 7 then 7 else . end) end) as $bar_idx |
    (["▁","▂","▃","▄","▅","▆","▇","█"][$bar_idx]) as $bar |
    if $cost == 0 then
      "\u001b[90m\($day) \(.) \($bar)      -\u001b[0m"
    else
      "\($day) \(.) " + get_color($cost; $max_cost) + "\($bar)\u001b[0m $\($cost | . * 100 | round / 100)"
    end
  ),
  "─────────────────────",

  # Calculate aggregates
  ($all_dates[-7:] | map($costs[.] // 0)) as $last7 |
  ((if ($all_dates | length) >= 30 then $all_dates[-30:] else $all_dates end) | map($costs[.] // 0)) as $last30 |
  (if ($all_dates | length) >= 30 then 30 else ($all_dates | length) end) as $n |

  (($last30 | add) / $n) as $avg30 |
  (($last7 | add) / 7) as $avg7 |
  ($costs[$all_dates[-1]] // 0) as $today |

  # Get sparkline for averages
  (if $avg30 == 0 then 0 else (($avg30 / $max_cost * 7) | floor | if . > 7 then 7 else . end) end) as $bar30_idx |
  (if $avg7 == 0 then 0 else (($avg7 / $max_cost * 7) | floor | if . > 7 then 7 else . end) end) as $bar7_idx |
  (if $today == 0 then 0 else (($today / $max_cost * 7) | floor | if . > 7 then 7 else . end) end) as $bar_today_idx |

  (["▁","▂","▃","▄","▅","▆","▇","█"][$bar30_idx]) as $bar30 |
  (["▁","▂","▃","▄","▅","▆","▇","█"][$bar7_idx]) as $bar7 |
  (["▁","▂","▃","▄","▅","▆","▇","█"][$bar_today_idx]) as $bar_today |

  "Avg (\($n)d):   " + get_color($avg30; $max_cost) + "\($bar30)\u001b[0m $\($avg30 | . * 100 | round / 100)/day",
  "Total (\($n)d):   $\(($last30 | add) | . * 100 | round / 100)",
  "─────────────────────",
  "Avg (7d):    " + get_color($avg7; $max_cost) + "\($bar7)\u001b[0m $\($avg7 | . * 100 | round / 100)/day",
  "Total (7d):    $\(($last7 | add) | . * 100 | round / 100)",
  "─────────────────────",
  "Today:       " + get_color($today; $max_cost) + "\($bar_today)\u001b[0m $\($today | . * 100 | round / 100)"
')
}

# Watch version of dense ccusage display
watch-ccusage-dense() {
  while true; do
    clear
    ccusage-dense
    sleep ${1:-60}
  done
}

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
