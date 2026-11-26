function e2e --description 'Manage the shared e2e containers (docker-compose.e2e.yml) of the main checkout, from anywhere'
    #   e2e up | down | restart | ps | logs [service]
    # Always runs against the MAIN checkout, never a worktree: the containers are
    # shared by every worktree, and compose keys the project on the directory.
    set -l root
    # Inside a repo (or any of its worktrees) with an e2e compose file -> its main checkout.
    set -l common (git rev-parse --path-format=absolute --git-common-dir 2>/dev/null)
    if test -n "$common"; and test -f (dirname $common)/docker-compose.e2e.yml
        set root (dirname $common)
    else
        set root "$HOME/dev/shuffle/shufflecom-api"
    end
    if not test -f $root/docker-compose.e2e.yml
        echo "e2e: no docker-compose.e2e.yml in $root" >&2
        return 1
    end

    # One shared set, always from the base checkout, under a fixed project name.
    # Not the dir name: the main docker-compose.yml already uses `shufflecom-api`
    # (-> "orphan containers" warnings). Don't start e2e via a worktree's
    # `yarn test:e2e:up` — that makes a second project that collides on the
    # services' fixed container_names.
    set -l dc docker compose -p shufflecom-api-e2e --project-directory $root -f $root/docker-compose.e2e.yml
    switch "$argv[1]"
        case up
            $dc up -d $argv[2..]
        case down
            # -v drops their (throwaway) volumes, same as `yarn test:e2e:down`.
            $dc down -v $argv[2..]
        case restart
            $dc down -v; and $dc up -d
        case ps ''
            $dc ps --format 'table {{.Name}}\t{{.Status}}\t{{.Ports}}' $argv[2..]
        case logs
            $dc logs --tail 100 -f $argv[2..]
        case '*'
            echo "usage: e2e [up|down|restart|ps|logs [service]]   (main checkout: $root)" >&2
            return 1
    end
end
