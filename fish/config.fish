set -g fish_greeting
if status is-interactive
    # Commands to run in interactive sessions can go here
    abbr -a lg lazygit
end

# Corporate CA bundle (Cloudflare Gateway TLS inspection). The managed setup only
# exports these in /etc/zshenv, which fish never reads — without them node/yarn
# (e.g. grpc-tools' binary download), curl, aws and python fail with
# "self-signed certificate in certificate chain".
set -l ca_bundle "/Library/Application Support/Kingside/certs/combined-ca-bundle.pem"
if test -f $ca_bundle
    for var in NODE_EXTRA_CA_CERTS CURL_CA_BUNDLE AWS_CA_BUNDLE SSL_CERT_FILE REQUESTS_CA_BUNDLE
        set -gx $var $ca_bundle
    end
end

# pipx (used by uv as well)
fish_add_path -g "$HOME/.local/bin"

# pnpm
set -gx PNPM_HOME "$HOME/Library/pnpm"
fish_add_path -g "$PNPM_HOME"

# bun
set -gx BUN_INSTALL "$HOME/.bun"
fish_add_path -g "$BUN_INSTALL/bin"

# jojo-scripts
test -f "$HOME/dev/jojo-scripts/entrypoint.fish" && source "$HOME/dev/jojo-scripts/entrypoint.fish"

function __nvm_auto_use --on-variable PWD
    if test -f .nvmrc
        set node_version (string trim (cat .nvmrc))
        if test -n "$node_version"
            # Switch if installed (no network); only install when missing.
            nvm use --silent $node_version 2>/dev/null
            or nvm install --silent $node_version
            # Globals are per Node version, so a newly installed one has no yarn.
            # (Not nvm_default_packages: nvm.fish reinstalls those on every switch.)
            type -q yarn; or npm install --global --silent yarn
        end
    else if test -n "$nvm_default_version"
        nvm use $nvm_default_version >/dev/null 2>&1
    end
end

# Auto-activate hermit on directory change
function __hermit_activate --on-variable PWD
    if test -f $PWD/bin/activate-hermit.fish
        source $PWD/bin/activate-hermit.fish
    end
end

starship init fish | source
zoxide init fish | source
