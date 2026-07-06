# Completions for the `wt` worktree-fleet function.

# Subcommands (only as the first argument).
complete -c wt -f -n __fish_use_subcommand -a ls -d 'List worktree sessions'
complete -c wt -f -n __fish_use_subcommand -a rm -d 'Remove a worktree + its session'

# Branch names: as the first arg (spawn/switch) and after `rm`.
complete -c wt -f -n __fish_use_subcommand \
    -a "(git for-each-ref --format='%(refname:short)' refs/heads 2>/dev/null)" -d branch
complete -c wt -f -n "__fish_seen_subcommand_from rm" \
    -a "(git for-each-ref --format='%(refname:short)' refs/heads 2>/dev/null)" -d branch
