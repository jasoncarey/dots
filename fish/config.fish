set -g fish_greeting
if status is-interactive
    # Commands to run in interactive sessions can go here
end

# pipx (used by uv as well)
fish_add_path -g "$HOME/.local/bin"

# pnpm
set -gx PNPM_HOME "$HOME/Library/pnpm"
fish_add_path -g "$PNPM_HOME"

# bun
set -gx BUN_INSTALL "$HOME/.bun"
fish_add_path -g "$BUN_INSTALL/bin"

function __nvm_auto_use --on-variable PWD
    if test -f .nvmrc
        set node_version (string trim (cat .nvmrc))
        if test -n "$node_version"
            nvm install $node_version >/dev/null
            nvm use $node_version >/dev/null
        end
    else if test -n "$nvm_default_version"
        nvm use $nvm_default_version >/dev/null 2>&1
    end
end

starship init fish | source
zoxide init fish | source
