#!/bin/bash
# Hides the bar while the built-in display is off (lid closed). The external display
# becomes the main one then, and the bar would cover the top of its windows.

if system_profiler SPDisplaysDataType -json |
  jq -e 'any(..; .spdisplays_connection_type? == "spdisplays_internal")' >/dev/null; then
  sketchybar --bar hidden=off
else
  sketchybar --bar hidden=on
fi
