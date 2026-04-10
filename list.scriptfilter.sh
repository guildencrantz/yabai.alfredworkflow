#!/usr/bin/env zsh

source common.sh

CURRENT_SPACE=$($_YABAI -m query --spaces --space mouse | $_JQ .index)

$_YABAI -m query --windows | $_JQ --arg CURRENT_SPACE $CURRENT_SPACE '
  {
    "items": [ .[] | 
      select( 
        (.space != ($CURRENT_SPACE | tonumber)) # Summon from  all spaces except the current one
        or ."is-minimized"                      # Always allow summoning minimized windows
      ) |
      {
        "title": .title,
        "subtitle": .app,
        "arg": .id,
        "automomplete": .title,
        "match": "\(.title) \(.app)"
      }
    ]
  }
'
