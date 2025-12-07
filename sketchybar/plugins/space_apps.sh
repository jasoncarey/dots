#!/usr/bin/env bash

YABAI_BIN="$(command -v yabai 2>/dev/null || echo /opt/homebrew/bin/yabai)"
JQ_BIN="$(command -v jq 2>/dev/null || echo /opt/homebrew/bin/jq)"

if [ ! -x "$YABAI_BIN" ] || [ ! -x "$JQ_BIN" ]; then
  [ -n "$NAME" ] && sketchybar --set "$NAME" label="(yabai/jq missing)"
  exit 0
fi

# All windows on the current space
json="$("$YABAI_BIN" -m query --windows --space 2>/dev/null)"

# Focused app name (may be empty if no focused window)
focused_app="$(echo "$json" | "$JQ_BIN" -r '.[] | select(.focused == 1) | .app' | head -n1)"
all_apps="$(echo "$json" | "$JQ_BIN" -r '.[].app' | sort -u)"

apps="$("$YABAI_BIN" -m query --windows --space 2>/dev/null | \
        "$JQ_BIN" -r '.[].app' 2>/dev/null | sort -u)"

label=""
while IFS= read -r app; do
  [ -z "$app" ] && continue

  if [ "$app" = "$focused_app" ]; then
    label="$label  [$app]"
  else
    label="$label  $app"
  fi
done <<< "$apps"

# Trim leading spaces
label="${label#"${label%%[![:space:]]*}"}"

[ -n "$NAME" ] && sketchybar --set "$NAME" label="$label"