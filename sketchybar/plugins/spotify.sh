#!/bin/bash
# Shows the current track while Spotify is playing (green) or paused, and hides otherwise.
# On spotify_change, $INFO is the notification's details as JSON. On first load there's no
# notification, so ask Spotify directly, but only if it's running so the bar never launches it.

source "$CONFIG_DIR/colors.sh"

if [ "$SENDER" = "spotify_change" ]; then
  STATE="$(echo "$INFO" | jq -r '.["Player State"] // empty')"
  TRACK="$(echo "$INFO" | jq -r '.Name // empty')"
  ARTIST="$(echo "$INFO" | jq -r '.Artist // empty')"
elif pgrep -xq Spotify; then
  {
    read -r STATE
    read -r TRACK
    read -r ARTIST
  } <<<"$(osascript -e 'tell application "Spotify" to return (player state as string) & linefeed & name of current track & linefeed & artist of current track')"
fi

case "$STATE" in
  Playing|playing) COLOR=$GREEN ;;
  Paused|paused) COLOR=$FG ;;
  *)
    sketchybar --set "$NAME" drawing=off
    exit 0
    ;;
esac

sketchybar --set "$NAME" drawing=on icon.color=$COLOR label.color=$COLOR label="$ARTIST - $TRACK"
