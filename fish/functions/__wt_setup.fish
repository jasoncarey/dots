function __wt_setup --description 'Prepare a fresh worktree: link gitignored env files; print the deps install command' --argument-names mainroot wtpath
    # 1. Symlink untracked .env* files from the main checkout (e.g. .env), so
    #    every worktree shares one local config. Tracked ones (e.g. .env.test)
    #    are already in the checkout and are skipped. Messages go to stderr —
    #    stdout is reserved for the install command below.
    for f in $mainroot/.env $mainroot/.env.*
        test -f $f; or continue
        set -l name (basename $f)
        git -C $mainroot ls-files --error-unmatch -- $name >/dev/null 2>&1; and continue
        test -e $wtpath/$name; and continue
        ln -s $f $wtpath/$name
        echo "wt: linked $name" >&2
    end

    # 2. Print (don't run) the deps install for whichever lockfile the repo uses.
    #    `wt` types it into the new session's shell window, so a 30-90s install
    #    never blocks the caller (e.g. the prefix+f popup).
    set -l cmd
    if test -f $wtpath/pnpm-lock.yaml
        set cmd "pnpm install --frozen-lockfile --prefer-offline"
    else if test -f $wtpath/yarn.lock
        set cmd "yarn install --frozen-lockfile --prefer-offline"
    else if test -f $wtpath/bun.lock; or test -f $wtpath/bun.lockb
        set cmd "bun install --frozen-lockfile"
    else if test -f $wtpath/package-lock.json
        set cmd "npm ci --prefer-offline"
    end

    # 3. Husky (v9) hooks: core.hooksPath (.husky/_) is shared via the common
    #    git config, but .husky/_ itself is generated + gitignored, so it only
    #    exists where `husky` has run. Without it git silently skips the hooks.
    #    Repos with a "prepare": "husky" script get this from the install anyway.
    if test -n "$cmd"; and test -d $wtpath/.husky
        set cmd "$cmd && npx --no husky"
    end

    test -n "$cmd"; and echo $cmd
end
