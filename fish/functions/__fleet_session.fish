function __fleet_session --description 'Ensure a nvim/claude/shell tmux session at a path, then jump to it' --argument-names session path shell_cmd
    # Optional shell_cmd: typed into the shell window when the session is first
    # created (wt uses it for the deps install, so it runs in the background).
    if not tmux has-session -t "=$session" 2>/dev/null
        tmux new-session -d -s $session -c $path -n nvim
        tmux send-keys -t "$session:nvim" nvim Enter
        tmux new-window -t $session -c $path -n claude
        tmux send-keys -t "$session:claude" claude Enter
        tmux new-window -t $session -c $path -n shell
        if test -n "$shell_cmd"
            tmux send-keys -t "$session:shell" "$shell_cmd" Enter
        end
        tmux select-window -t "$session:nvim"
    end

    if set -q TMUX
        tmux switch-client -t "=$session"
    else
        tmux attach -t "=$session"
    end
end