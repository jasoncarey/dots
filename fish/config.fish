if status is-interactive
    # Commands to run in interactive sessions can go here
end

function __nvm_auto_use --on-variable PWD
    if test -f .nvmrc
        set node_version (string trim (cat .nvmrc))
        if test -n "$node_version"
            nvm install $node_version >/dev/null
            nvm use $node_version >/dev/null
        end
    end
end

starship init fish | source
