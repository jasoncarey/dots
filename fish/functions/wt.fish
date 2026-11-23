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
    set -l mainroot (dirname $common)
    set -l repo (basename $mainroot)
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
            set -l wtpath "$base/"(string replace -a / - -- $branch)
            if not test -d $wtpath
                echo "wt: no worktree at $wtpath" >&2
                return 1
            end
            set -l session (__fleet_name $wtpath)
            tmux kill-session -t "=$session" 2>/dev/null
            if not git worktree remove $wtpath 2>/dev/null
                echo "wt: could not remove $wtpath (uncommitted changes?)." >&2
                echo "    force with: git worktree remove --force $wtpath" >&2
                return 1
            end
            echo "wt: removed $session (branch $branch kept)"
            return 0

        case '*'
            set -l branch $argv[1]
            # Flatten slashes so the dir label is unique: feat/x -> feat-x. The
            # session name comes from the label (__fleet_name), matching prefix+f.
            set -l wtpath "$base/"(string replace -a / - -- $branch)
            set -l setup_cmd ""

            if not test -d $wtpath
                # Default branch from origin/HEAD (e.g. origin/main); fall back to main.
                set -l default (git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null)
                or set default origin/main
                git fetch origin --quiet

                mkdir -p $base
                if git show-ref --verify --quiet "refs/heads/$branch"
                    # Existing local branch -> check it out.
                    git worktree add $wtpath $branch; or return 1
                else if git show-ref --verify --quiet "refs/remotes/origin/$branch"
                    # Branch exists on origin (e.g. reviewing a PR) -> track it.
                    git worktree add --track -b $branch $wtpath origin/$branch; or return 1
                else
                    # New branch off fresh origin/<default>, not whatever HEAD is.
                    git worktree add --no-track -b $branch $wtpath $default; or return 1
                end

                # Links .env now; returns the deps install command, which runs in
                # the new session's shell window instead of blocking here.
                set setup_cmd (__wt_setup $mainroot $wtpath)
            end

            # Open (or attach to) the worktree's fleet session.
            __fleet_session (__fleet_name $wtpath) $wtpath "$setup_cmd"
    end
end
