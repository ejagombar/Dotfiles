#!/bin/bash
# Runs for both the speaker item and its slider, so it sets them by name rather than $NAME.
# $INFO is the new volume (0-100) on volume_change; on first load, ask macOS.
# Some outputs (e.g. HDMI) have no volume level, so show nothing for those.

# Slides the slider out to $1 points wide, or back in when $1 is 0
slide() {
  local knob=on
  [ "$1" -eq 0 ] && knob=off
  sketchybar --set volume_slider slider.knob.drawing=$knob \
             --animate tanh 15 --set volume_slider slider.width="$1"
}

case "$SENDER" in
  mouse.clicked)
    if [ "$NAME" = "volume_slider" ]; then
      # macOS then sends volume_change, which updates the speaker and slider
      osascript -e "set volume output volume $PERCENTAGE"
    elif [ "$(sketchybar --query volume_slider | jq -r .slider.width)" = "0" ]; then
      slide 100
    else
      slide 0
    fi
    exit 0
    ;;
  mouse.exited.global)
    slide 0
    exit 0
    ;;
esac

VOLUME="${INFO:-$(osascript -e 'output volume of (get volume settings)')}"

if ! [[ "$VOLUME" =~ ^[0-9]+$ ]]; then
  slide 0
  sketchybar --set volume drawing=off
  exit 0
fi

if [ "$VOLUME" -ge 60 ]; then
  ICON=$'\xef\x80\xa8' # volume up
elif [ "$VOLUME" -gt 0 ]; then
  ICON=$'\xef\x80\xa7' # volume down
else
  ICON=$'\xef\x80\xa6' # volume off
fi

sketchybar --set volume drawing=on icon="$ICON" label="$VOLUME%" \
           --set volume_slider slider.percentage="$VOLUME"
