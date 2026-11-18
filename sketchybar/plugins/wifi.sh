#!/bin/bash
# Shows only whether Wi-Fi is connected: macOS hides the network name from apps
# without Location access. en0 is the Wi-Fi interface on this Mac.

source "$CONFIG_DIR/colors.sh"

if ipconfig getifaddr en0 >/dev/null; then
  COLOR=$FG
else
  COLOR=$RED
fi

sketchybar --set "$NAME" icon=$'\xef\x87\xab' icon.color=$COLOR # wifi
