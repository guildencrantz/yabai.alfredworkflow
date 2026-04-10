#!/usr/bin/env zsh

source common.sh

if [[ "$(csrutil status)" == *"enabled"* ]]; then
  WINDOW_DISPLAY=$($_YABAI -m query --windows --window "$1" | $_JQ '.display')
  MOUSE_DISPLAY=$($_YABAI -m query --spaces --space mouse | $_JQ '.display')

  if [[ "$WINDOW_DISPLAY" == "$MOUSE_DISPLAY" ]]; then
    # Without SIP disabled, yabai can only move windows to visible spaces.
    # Moving between non-visible spaces on the same display silently fails.
    # Workaround: bounce the window through a visible space on another display.
    WAYPOINT=$($_YABAI -m query --spaces | $_JQ --arg wd "$WINDOW_DISPLAY" '
      [.[] | select(.display != ($wd | tonumber) and ."is-visible")][0].index
    ')

    if [[ -n "$WAYPOINT" && "$WAYPOINT" != "null" ]]; then
      $_YABAI -m window "$1" --space "$WAYPOINT"
    fi
  fi
fi

$_YABAI -m window "$1" --space mouse

if [[ $($_YABAI -m query --windows --window "$1" | $_JQ '."is-minimized"') == "true" ]]; then
  $_YABAI -m window --deminimize "$1"
fi
