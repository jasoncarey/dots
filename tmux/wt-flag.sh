#!/usr/bin/env bash
# Claude Code Stop/Notification hook: flag the tmux session that contains this
# Claude session as needing attention. Cleared when you switch into that session
# (see the client-session-changed hook in tmux.conf).
[ -n "$TMUX_PANE" ] || exit 0
sess=$(tmux display-message -p -t "$TMUX_PANE" '#{session_name}' 2>/dev/null) || exit 0
[ -n "$sess" ] && tmux set-option -t "$sess" @attention 1 2>/dev/null
exit 0
