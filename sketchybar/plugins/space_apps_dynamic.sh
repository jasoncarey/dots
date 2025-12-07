#!/usr/bin/env bash

# --- binaries (update paths if which says otherwise) ---
YABAI_BIN="$(command -v yabai 2>/dev/null || echo /opt/homebrew/bin/yabai)"
JQ_BIN="$(command -v jq 2>/dev/null || echo /opt/homebrew/bin/jq)"

# --- colors (Material Palenight, ARGB) ---
FG="0xff959dcb"       # normal text
ACCENT="0xffc3e88d"   # focused app text

MAX_ITEMS=12          # max app pills to show

if [ ! -x "$YABAI_BIN" ] || [ ! -x "$JQ_BIN" ]; then
  [ -n "$NAME" ] && sketchybar --set "$NAME" label="(yabai/jq missing)"
  exit 0
fi

# Remove old app items
for i in $(seq 0 $MAX_ITEMS); do
  sketchybar --remove "space_app.$i" 2>/dev/null
done

# app, id, has-focus per *window* on current space
apps="$(
  "$YABAI_BIN" -m query --windows --space 2>/dev/null |
  "$JQ_BIN" -r '.[] | "\(.app)\t\(.id)\t\(.["has-focus"])"'
)"

seen_apps=""
i=0

while IFS=$'\t' read -r app win_id has_focus; do
  [ -z "$app" ] && continue
  [ "$app" = "null" ] && continue

  # skip duplicate apps (Preview Preview → only one Preview)
  case " $seen_apps " in
    *" $app "*) continue;;
  esac

  [ $i -gt $MAX_ITEMS ] && break

  name="space_app.$i"
  sketchybar --add item "$name" center 2>/dev/null

  # shorten long app names for display
  short="$app"
  maxlen=20
  if [ ${#short} -gt $maxlen ]; then
    short="${short:0:$maxlen}…"
  fi

  if [ "$has_focus" = "1" ] || [ "$has_focus" = "true" ]; then
    label="$short"
    color="$ACCENT"
  else
    label="$short"
    color="$FG"
  fi

  sketchybar --set "$name" \
    label="$label" \
    label.color="$color" \
    background.drawing=off \
    icon.drawing=off \
    click_script="$YABAI_BIN -m window --focus $win_id"

  seen_apps="$seen_apps $app"
  i=$((i+1))
done <<< "$apps"