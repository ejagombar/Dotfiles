#!/bin/bash
# Shows the focused app's name. $INFO holds it on front_app_switched; on first load, ask AeroSpace.

if [ "$SENDER" = "front_app_switched" ]; then
  APP="$INFO"
else
  APP="$(aerospace list-windows --focused --format '%{app-name}' 2>/dev/null)"
fi

sketchybar --set "$NAME" label="$APP"
