#!/bin/bash
# Highlights the focused workspace. $1 is the workspace this item shows.
# FOCUSED_WORKSPACE is only set by AeroSpace's trigger, so ask AeroSpace on first load.

source "$CONFIG_DIR/colors.sh"

FOCUSED="${FOCUSED_WORKSPACE:-$(aerospace list-workspaces --focused)}"

if [ "$1" = "$FOCUSED" ]; then
  sketchybar --set "$NAME" background.drawing=on icon.color=$BLUE
else
  sketchybar --set "$NAME" background.drawing=off icon.color=$FG
fi
