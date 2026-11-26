function __wt_setup --description 'Prepare a fresh worktree: set up env files; print the deps install command' --argument-names mainroot wtpath
    # Messages go to stderr — stdout is reserved for the install command below.

    # Env files that package.json scripts generate, e.g. "dev": "cp .env.dev .env"
    # (shufflecom-interface / -admin-interface). Captures "<source> <target>" pairs.
    set -l generated
    set -l gen_source
    if test -f $wtpath/package.json
        for pair in (string match -rag 'cp\s+(\.env[^\s"&;]*)\s+(\.env[^\s"&;]*)' < $wtpath/package.json | paste -d' ' - -)
            set -l src (string split ' ' $pair)[1]
            set -l dst (string split ' ' $pair)[2]
            contains -- $dst $generated; or set -a generated $dst
            # The first copy into it is the default ("dev" comes first in scripts).
            set -q gen_source[1]; or set gen_source $src $dst
        end
    end

    # 1. Symlink untracked .env* files from the main checkout (e.g. .env), so
    #    every worktree shares one local config. Skipped:
    #    - tracked ones (e.g. .env.test) — already in the checkout;
    #    - generated ones — a script's `cp .env.dev .env` would write THROUGH the
    #      symlink and silently change the main checkout's (and every worktree's) env.
    for f in $mainroot/.env $mainroot/.env.*
        test -f $f; or continue
        set -l name (basename $f)
        git -C $mainroot ls-files --error-unmatch -- $name >/dev/null 2>&1; and continue
        contains -- $name $generated; and continue
        test -e $wtpath/$name; and continue
        ln -s $f $wtpath/$name
        echo "wt: linked $name" >&2
    end

    # 2. Generated env: give the worktree its own copy from the default source
    #    now, so tools that read it (nvim, codegen) work before the first
    #    `yarn dev`, which re-copies it anyway.
    if set -q gen_source[1]; and test -f $wtpath/$gen_source[1]; and not test -e $wtpath/$gen_source[2]
        cp $wtpath/$gen_source[1] $wtpath/$gen_source[2]
        echo "wt: copied $gen_source[1] -> $gen_source[2]" >&2
    end

    # 3. Print (don't run) the deps install for whichever lockfile the repo uses.
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

    # 4. Husky (v9) hooks: core.hooksPath (.husky/_) is shared via the common
    #    git config, but .husky/_ itself is generated + gitignored, so it only
    #    exists where `husky` has run. Without it git silently skips the hooks.
    #    Repos with a "prepare": "husky" script get this from the install anyway.
    if test -n "$cmd"; and test -d $wtpath/.husky
        # Skip when the repo's own "prepare" script already runs husky (the
        # install triggers it; husky v8's bare `husky` just prints usage).
        if not grep -qE '"prepare":[^,]*husky' $wtpath/package.json 2>/dev/null
            set cmd "$cmd && npx --no husky"
        end
    end

    test -n "$cmd"; and echo $cmd
end
