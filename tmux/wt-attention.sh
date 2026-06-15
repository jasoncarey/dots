#!/usr/bin/env bash
# Emit "● <session>" chips for every session flagged @attention.
# Used by status-right so a waiting agent in ANY session is visible everywhere.
tmux list-sessions -F '#{?@attention,● #{session_name},}' 2>/dev/null \
    | grep -v '^$' \
    | paste -sd '  ' -
