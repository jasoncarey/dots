function work --description 'Jump to a project (zoxide) and open/attach its fleet session (nvim/claude/shell)'
    # Resolve the target dir: a zoxide query if given, else the current dir.
    set -l dir
    if test (count $argv) -gt 0
        set dir (zoxide query -- $argv)
        or begin
            echo "work: no match for '$argv'" >&2
            return 1
        end
    else
        set dir $PWD
    end

    # Session name is worktree-aware: <repo> for a main checkout, <repo>/<label>
    # for a linked worktree, else the folder basename. So `work <label>` opens an
    # existing worktree's session without colliding with its siblings.
    __fleet_session (__fleet_name $dir) $dir
end