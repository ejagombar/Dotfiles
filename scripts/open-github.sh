#!/usr/bin/env bash

# Get the remote URL
url=$(git remote get-url origin)

# Convert SSH to HTTPS if necessary
if [[ $url == git@github.com:* ]]; then
  # Example: git@github.com:ejagombar/Dotfiles.git
  # Convert to: https://github.com/ejagombar/Dotfiles
  url="https://github.com/${url#git@github.com:}"
  url="${url%.git}"
fi

# Strips .git
if [[ $url == https://github.com/* ]]; then
  url="${url%.git}"
fi

# Check if the repository is on GitHub
if [[ $url == *"github.com"* ]]; then
  echo "Opening: $url"
  xdg-open $url
else
  echo "This repository is not hosted on GitHub"
fi
