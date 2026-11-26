#!/usr/bin/env bash
# Fleet picker (prefix+f): open tmux sessions AND git worktrees that don't have
# a session yet, so you can see every worktree + its branch and jump into it.
#
#   ● row  -> an open tmux session          enter: switch to it
#   ○ row  -> a worktree with no session    enter: create its fleet session
#                                                  (nvim/claude/shell) and switch
#   ctrl-n -> new worktree: prompts for a branch, runs `wt <branch>` in the
#             highlighted row's repo (worktree + .env link + deps + session)
#   ctrl-d -> delete the highlighted worktree (kills its session, removes the
#             worktree, keeps the branch). Asks first; offers --force if dirty.
#   ctrl-x -> kill the highlighted session (session only, NOT the worktree)
#   ctrl-r -> rename the highlighted session
#
# Worktrees are discovered from every repo that has an open session, plus the
# repo of the pane you opened the picker from — so they show up wherever they
# live on disk (~/dev/wt/..., <repo>/wt/..., sibling dirs, ...).
#
# Written for macOS /bin/bash 3.2 (no associative arrays).

self="${BASH_SOURCE[0]}"

# Main checkout root for a dir (dirname of the shared git dir), or nothing.
repo_root() {
    local common
    common=$(git -C "$1" rev-parse --path-format=absolute --git-common-dir 2>/dev/null) || return 1
    dirname "$common"
}

branch_of() {
    local sha
    git -C "$1" symbolic-ref --short -q HEAD 2>/dev/null && return
    sha=$(git -C "$1" rev-parse --short HEAD 2>/dev/null) && { echo "detached@$sha"; return; }
    echo "—"
}

# Path for a picker key (s:<session> or w:<path>).
key_path() {
    case "$1" in
        s:*) tmux display-message -p -t "=${1#s:}:" '#{session_path}' 2>/dev/null ;;
        w:*) echo "${1#w:}" ;;
    esac
}

case "$1" in
--list)
    sessions=$(tmux list-sessions -F '#{session_name}	#{session_path}' 2>/dev/null)
    origin=${2:-$PWD}

    # Repos to scan: those of open sessions + the pane the picker was opened from.
    roots=$( { printf '%s\n' "$sessions" | cut -f2; echo "$origin"; } \
        | while IFS= read -r p; do [ -n "$p" ] && repo_root "$p"; done | sort -u)

    rows=""      # kind \t key \t name \t branch
    matched=""   # session names already represented by a worktree row

    while IFS= read -r root; do
        [ -n "$root" ] || continue
        repo=$(basename "$root")
        while IFS= read -r wt; do
            [ -d "$wt" ] || continue
            if [ "$wt" = "$root" ]; then name="$repo"; else name="$repo/$(basename "$wt")"; fi
            branch=$(branch_of "$wt")
            # Match a session by path first (survives renames), then by fleet name.
            sess=$(printf '%s\n' "$sessions" | awk -F'\t' -v p="$wt" '$2==p {print $1; exit}')
            [ -z "$sess" ] && sess=$(printf '%s\n' "$sessions" | awk -F'\t' -v n="$name" '$1==n {print $1; exit}')
            if [ -n "$sess" ]; then
                rows+="open	s:$sess	$sess	$branch"$'\n'
                matched+="$sess"$'\n'
            else
                rows+="closed	w:$wt	$name	$branch"$'\n'
            fi
        done < <(git -C "$root" worktree list --porcelain 2>/dev/null | sed -n 's/^worktree //p')
    done <<< "$roots"

    # Sessions that aren't a worktree of a scanned repo (plain folders, etc.).
    while IFS=$'\t' read -r name path; do
        [ -n "$name" ] || continue
        printf '%s' "$matched" | grep -Fxq -- "$name" && continue
        rows="open	s:$name	$name	$(branch_of "$path")"$'\n'"$rows"
    done <<< "$sessions"

    # Open sessions first, then worktrees without a session; align columns.
    printf '%s' "$rows" | awk -F'\t' '
        NF { kind[NR]=$1; key[NR]=$2; name[NR]=$3; br[NR]=$4
             if (length($3) > w) w = length($3); n = NR }
        END {
            for (pass = 0; pass < 2; pass++)
                for (i = 1; i <= n; i++) {
                    if (!(i in kind)) continue
                    if (pass == 0 && kind[i] != "open") continue
                    if (pass == 1 && kind[i] != "closed") continue
                    if (kind[i] == "open")
                        printf "%s\t\033[32m●\033[0m %-*s  \033[36m%s\033[0m\n", key[i], w, name[i], br[i]
                    else
                        printf "%s\t\033[2m○ %-*s  %s\033[0m\n", key[i], w, name[i], br[i]
                }
        }'
    exit 0
    ;;
--preview)
    path=$(key_path "$2")
    [ -d "$path" ] || exit 0
    printf '\033[2m%s\033[0m\n\n' "${path/#$HOME/~}"
    git -C "$path" -c color.status=always status --short --branch 2>/dev/null | head -15
    echo
    git -C "$path" log --color=always --oneline -8 2>/dev/null
    exit 0
    ;;
--new)
    # $2 = highlighted key (may be empty), $3 = origin pane path.
    # Runs via fzf `become`, so stdout would be captured as the selection —
    # send everything to the terminal instead; the popup closes when we exit.
    exec >/dev/tty 2>&1
    root=$(repo_root "$(key_path "$2")") || root=$(repo_root "$3") || {
        read -r -p "not a git repo — highlight a row from the repo you want. [enter] " </dev/tty
        exit 1
    }
    read -r -p "new branch in $(basename "$root"): " br </dev/tty
    [ -n "$br" ] || exit 1
    # wt creates the worktree, links .env, then switches to the new session;
    # the deps install runs in that session's shell window, not here.
    fish -c 'cd $argv[1]; and wt $argv[2]' "$root" "$br" && exit 0
    read -r -p "wt failed (see above). [enter] " </dev/tty
    exit 1
    ;;
--remove)
    # $2 = highlighted key, $3 = current session name
    pause() { read -r -p "$1 [enter] " </dev/tty; exit 0; }
    path=$(key_path "$2")
    root=$(repo_root "$path") || pause "not a git worktree."
    [ "$path" = "$root" ] && pause "that's the main checkout — not removing it."
    sess=""; case "$2" in s:*) sess=${2#s:} ;; esac
    [ -n "$sess" ] && [ "$sess" = "$3" ] && pause "you're in that session — switch away first."
    branch=$(branch_of "$path")
    read -r -p "remove worktree ${path/#$HOME/~} ($branch)? branch is kept. [y/N] " ok </dev/tty
    [ "$ok" = y ] || [ "$ok" = Y ] || exit 0
    if ! git -C "$root" worktree remove "$path"; then
        read -r -p "worktree has changes. force remove (DISCARDS them)? [y/N] " ok </dev/tty
        [ "$ok" = y ] || [ "$ok" = Y ] || exit 0
        git -C "$root" worktree remove --force "$path" || pause "remove failed."
    fi
    [ -n "$sess" ] && tmux kill-session -t "=$sess" 2>/dev/null
    exit 0
    ;;
--kill)
    case "$2" in s:*) tmux kill-session -t "=${2#s:}" ;; esac
    exit 0
    ;;
--rename)
    case "$2" in
        s:*) read -r -p "rename ${2#s:} to: " new </dev/tty
             [ -n "$new" ] && tmux rename-session -t "=${2#s:}" "$new" ;;
    esac
    exit 0
    ;;
esac

origin=$(tmux display-message -p '#{pane_current_path}' 2>/dev/null)
current=$(tmux display-message -p '#{session_name}' 2>/dev/null)

sel=$("$self" --list "$origin" \
    | fzf --reverse --height=100% --ansi --prompt='worktree> ' \
        --delimiter='\t' --with-nth=2 --accept-nth=1 \
        --header $'enter: open/switch   ctrl-n: new worktree   ctrl-d: delete worktree\nctrl-x: kill session   ctrl-r: rename session' \
        --preview "$self --preview {1}" --preview-window 'right,45%,border-left' \
        --bind "ctrl-n:become($self --new {1} '$origin')" \
        --bind "ctrl-d:execute($self --remove {1} '$current')+reload($self --list '$origin')" \
        --bind "ctrl-x:execute-silent($self --kill {1})+reload($self --list '$origin')" \
        --bind "ctrl-r:execute($self --rename {1})+reload($self --list '$origin')")

case "$sel" in
    s:*) tmux switch-client -t "=${sel#s:}" ;;
    w:*) fish -c '__fleet_session (__fleet_name $argv[1]) $argv[1]' "${sel#w:}" ;;
esac
