function wt --description 'Worktree fleet: spawn/switch/remove worktree tmux sessions'
    if not git rev-parse --git-dir >/dev/null 2>&1
        echo "wt: not inside a git repository" >&2
        return 1
    end

    # Stable repo name across worktrees: derive from the shared (common) git dir,
    # so every linked worktree resolves to the same repo name.
    set -l common (git rev-parse --path-format=absolute --git-common-dir 2>/dev/null)
    if test -z "$common"
        set common (realpath (git rev-parse --git-common-dir))
    end
    set -l repo (basename (dirname $common))
    set -l base "$HOME/dev/wt/$repo"

    set -l cmd $argv[1]
    switch "$cmd"
        case ''
            # No arg: fzf-pick one of THIS repo's existing worktrees and open it.
            set -l sel (git worktree list | fzf --reverse --height=40% --prompt='worktree> ')
            or return 0
            test -n "$sel"; or return 0
            set -l wtpath (string split -n ' ' -- $sel)[1]
            __fleet_session (__fleet_name $wtpath) $wtpath
            return 0

        case ls
            # List this repo's open worktree sessions.
            tmux list-sessions -F '#{session_name}' 2>/dev/null | string match -- "$repo/*"
            return 0

        case rm
            set -l branch $argv[2]
            if test -z "$branch"
                echo "wt rm: usage: wt rm <branch>" >&2
                return 1
            end
            set -l session "$repo/$branch"
            set -l wtpath "$base/$branch"
            tmux kill-session -t "=$session" 2>/dev/null
            if not git worktree remove $wtpath 2>/dev/null
                echo "wt: could not remove $wtpath (uncommitted changes?)." >&2
                echo "    force with: git worktree remove --force $wtpath" >&2
                return 1
            end
            echo "wt: removed $session"
            return 0

        case '*'
            set -l branch $argv[1]
            set -l session "$repo/$branch"
            set -l wtpath "$base/$branch"

            # Create the worktree if it does not exist yet. Existing branch -> check
            # it out; new branch -> create it from the current HEAD.
            if not test -d $wtpath
                if git show-ref --verify --quiet "refs/heads/$branch"
                    git worktree add $wtpath $branch; or return 1
                else
                    git worktree add -b $branch $wtpath; or return 1
                end
            end

            # Open (or attach to) the worktree's fleet session.
            __fleet_session $session $wtpath
    end
end
