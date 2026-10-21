#!/usr/bin/env bash

# github pr: open the current branch's pull request
if [[ $1 == pr ]]; then
  if ! command -v gh >/dev/null 2>&1; then
    echo "gh is not installed: brew install gh"
    exit 1
  fi
  # drop GH_TOKEN as the gh() wrapper in .zshrc does: a script cannot see that zsh function
  exec env -u GH_TOKEN gh pr view --web
fi

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

# Pick the right opener for the current OS
if [[ "$OSTYPE" == darwin* ]]; then
  opener="open"
else
  opener="xdg-open"
fi

# Check if the repository is on GitHub
if [[ $url == *"github.com"* ]]; then
  echo "Opening: $url"
  "$opener" "$url"
else
  echo "This repository is not hosted on GitHub"
fi
