#!/usr/bin/env bash
# Fuzzy-switch between tmux sessions (the worktree fleet). Bound to prefix+f.
#   enter   -> switch to the highlighted session
#   ctrl-x  -> kill the highlighted session (just the tmux session, NOT the
#              worktree; use `wt rm` to also remove the worktree). List reloads.
#   ctrl-r  -> rename the highlighted session (default name stays until you do).
# Each row shows the session name plus the git branch of its directory, so you
# can tell which branch you're on without renaming.

self="${BASH_SOURCE[0]}"

# `--list` mode: emit "<name>\t<aligned display>" rows. Field 1 is the clean
# session name (returned on accept); field 2 is the padded name + branch shown
# in the list. Called by fzf for the initial load and after each reload.
if [ "$1" = "--list" ]; then
    names=() paths=() width=0
    while IFS=$'\t' read -r name path; do
        names+=("$name") paths+=("$path")
        [ "${#name}" -gt "$width" ] && width=${#name}
    done < <(tmux list-sessions -F '#{session_name}	#{session_path}' 2>/dev/null)

    for i in "${!names[@]}"; do
        branch=$(git -C "${paths[$i]}" symbolic-ref --short -q HEAD 2>/dev/null)
        printf '%s\t%-*s  ⎇ %s\n' "${names[$i]}" "$width" "${names[$i]}" "${branch:-—}"
    done
    exit 0
fi

sel=$("$self" --list \
    | fzf --reverse --height=100% --prompt='worktree> ' \
        --delimiter='\t' --with-nth=2 --nth=2 --accept-nth=1 \
        --header 'enter: switch   ctrl-x: kill   ctrl-r: rename' \
        --bind "ctrl-x:execute-silent(tmux kill-session -t {1})+reload($self --list)" \
        --bind "ctrl-r:execute(read -r -p 'rename {1} to: ' new </dev/tty && [ -n \"\$new\" ] && tmux rename-session -t {1} \"\$new\")+reload($self --list)")
[ -n "$sel" ] && tmux switch-client -t "$sel"
