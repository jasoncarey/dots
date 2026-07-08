function theme --description 'Switch look (solarized | default) across fish, tmux, starship, ghostty'
    set -l mode $argv[1]

    switch "$mode"
        case solarized osaka solarized-osaka
            set mode solarized
            set -l fishtheme "Solarized Osaka"
            set -l tmuxfile solarized-osaka
            set -l ghosttytheme solarized-osaka
            set -l starship_on true
            __theme_apply solarized "$fishtheme" $tmuxfile $ghosttytheme $starship_on
        case default tokyonight tokyo cyberpunk
            set mode default
            set -l fishtheme "TokyoNight Night"
            set -l tmuxfile cyberpunk
            set -l ghosttytheme tokyo-night-default
            set -l starship_on false
            __theme_apply default "$fishtheme" $tmuxfile $ghosttytheme $starship_on
        case ''
            echo "usage: theme solarized | theme default"
            return 0
        case '*'
            echo "theme: unknown '$mode' (use: solarized | default)" >&2
            return 1
    end
end

function __theme_apply --description 'internal: apply a theme across all tools'
    set -l mode $argv[1]
    set -l fishtheme $argv[2]
    set -l tmuxfile $argv[3]
    set -l ghosttytheme $argv[4]
    set -l starship_on $argv[5]

    # 1) fish syntax-highlight colors — universal vars propagate to every shell.
    printf 'y\n' | fish_config theme save "$fishtheme" >/dev/null 2>&1

    # 2) tmux — rewrite the sourced theme path, then live-reload running servers.
    sed -i '' -E "s|^source-file .*tmux/themes/.*|source-file ~/dev/dots/tmux/themes/$tmuxfile.conf|" ~/dev/dots/tmux/tmux.conf
    if tmux info >/dev/null 2>&1
        tmux source-file ~/.tmux.conf >/dev/null 2>&1
    end

    # 3) starship — comment/uncomment the palette line (re-read on next prompt).
    # Edit the real dots file, not the ~/.config symlink: `sed -i` renames, which
    # would replace the symlink with a plain file.
    set -l starshiptoml ~/dev/dots/starship/starship.toml
    if test "$starship_on" = true
        sed -i '' -E 's|^#[[:space:]]*palette = "solarized_osaka"|palette = "solarized_osaka"|' $starshiptoml
    else
        sed -i '' -E 's|^palette = "solarized_osaka"|# palette = "solarized_osaka"|' $starshiptoml
    end

    # 4) ghostty — rewrite the active theme line (needs a manual reload).
    sed -i '' -E "s|^theme = .*|theme = $ghosttytheme|" ~/.config/ghostty/config

    set -l pstate off
    test "$starship_on" = true; and set pstate on
    echo "theme → $mode"
    echo "  fish     ✓ $fishtheme"
    echo "  tmux     ✓ $tmuxfile.conf"
    echo "  starship ✓ palette $pstate"
    echo "  ghostty  → reload with cmd+shift+, (theme = $ghosttytheme)"
end
