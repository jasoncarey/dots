function nb --description 'New branch off fresh origin/<default> in the current worktree'
    if test (count $argv) -ne 1
        echo "usage: nb <branch>" >&2
        return 1
    end

    # Default branch from origin/HEAD (e.g. origin/main); fall back to main.
    set -l base (git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null)
    or set base origin/main

    git fetch origin (string replace 'origin/' '' $base)
    and git switch -c $argv[1] --no-track $base
end
