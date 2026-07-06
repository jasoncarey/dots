function __fleet_session --description 'Ensure a nvim/claude/shell tmux session at a path, then jump to it' --argument-names session path
    if not tmux has-session -t "=$session" 2>/dev/null
        tmux new-session -d -s $session -c $path -n nvim
        tmux send-keys -t "$session:nvim" nvim Enter
        tmux new-window -t $session -c $path -n claude
        tmux send-keys -t "$session:claude" claude Enter
        tmux new-window -t $session -c $path -n shell
        tmux select-window -t "$session:nvim"
    end

    if set -q TMUX
        tmux switch-client -t "=$session"
    else
        tmux attach -t "=$session"
    end
end