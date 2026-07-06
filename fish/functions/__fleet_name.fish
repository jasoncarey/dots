function __fleet_name --description 'Fleet session name for a dir: <repo>/<worktree> for a linked worktree, <repo> for the main checkout, else the folder basename' --argument-names dir
    set -l common (git -C $dir rev-parse --path-format=absolute --git-common-dir 2>/dev/null)
    if test -z "$common"
        # Not a git repo — just use the folder name.
        basename $dir
        return
    end

    set -l repo (basename (dirname $common))
    set -l top (git -C $dir rev-parse --show-toplevel 2>/dev/null)
    set -l mainroot (dirname $common)

    if test "$top" = "$mainroot"
        echo $repo
    else
        # Linked worktree: name it by its directory label (decoupled from branch).
        echo "$repo/"(basename $top)
    end
end