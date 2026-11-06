#!/usr/bin/env bash

# open-url TEXT...: open the first web link found in TEXT. tmux's click-to-open
# bindings pass the OSC 8 hyperlink under the mouse, then the word under it, so
# a click away from a link does nothing.

# Only the characters URLs are written with, so quotes, angle brackets and
# box-drawing borders around a link aren't taken as part of it
url=$(printf '%s\n' "$@" | LC_ALL=C grep -o -E "https?://[][A-Za-z0-9._~:/?#@!\$&'()*+,;=%-]+" | head -n 1)
[[ -z $url ]] && exit 0

# Drop punctuation from the surrounding prose, but keep a closing bracket the
# URL opened itself, as in https://en.wikipedia.org/wiki/Bash_(Unix_shell)
while :; do
  case $url in
    *[.,:\;!?\'*]) ;;
    *\)) opened=${url//[^(]/} closed=${url//[^)]/}; (( ${#opened} < ${#closed} )) || break ;;
    *\]) opened=${url//[^[]/} closed=${url//[^]]/}; (( ${#opened} < ${#closed} )) || break ;;
    *) break ;;
  esac
  url=${url%?}
done

# Pick the right opener for the current OS
if [[ $OSTYPE == darwin* ]]; then
  opener=open
elif grep -qi microsoft /proc/version 2>/dev/null; then
  # wslview comes with wslu; explorer.exe opens links in the Windows browser too
  opener=$(command -v wslview || echo explorer.exe)
elif [[ -n $DISPLAY || -n $WAYLAND_DISPLAY ]]; then
  opener=xdg-open
fi

if [[ -n $opener ]] && command -v "$opener" >/dev/null 2>&1; then
  # Detached and silent, as tmux shows anything a run-shell job prints
  nohup "$opener" "$url" >/dev/null 2>&1 &
else
  # No browser on this machine, e.g. over SSH, so copy the link to the local
  # clipboard instead (set-clipboard sends it on to the terminal)
  tmux set-buffer -w -- "$url"
  tmux display-message "No browser here, copied ${url//#/##}"
fi
