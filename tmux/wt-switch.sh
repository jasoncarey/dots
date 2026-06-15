#!/usr/bin/env bash
# Fuzzy-switch between tmux sessions (the worktree fleet). Bound to prefix+f.
#   enter   -> switch to the highlighted session
#   ctrl-x  -> kill the highlighted session (just the tmux session, NOT the
#              worktree; use `wt rm` to also remove the worktree). List reloads.
sel=$(tmux list-sessions -F '#{session_name}' 2>/dev/null \
    | fzf --reverse --height=100% --prompt='worktree> ' \
        --header 'enter: switch   ctrl-x: kill' \
        --bind 'ctrl-x:execute-silent(tmux kill-session -t {})+reload(tmux list-sessions -F "#{session_name}")')
[ -n "$sel" ] && tmux switch-client -t "$sel"