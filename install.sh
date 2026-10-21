#!/usr/bin/env bash
# Installs tools and symlinks the dotfiles into place.
#
#   curl -sL dots.eagombar.uk | bash
#
# To run without any prompts (e.g. in a container), pass options after "bash -s --":
#
#   curl -sL dots.eagombar.uk | bash -s -- --yes --full
#
# Run with --help to list the options.
#
# Works on macOS (Homebrew), Linux and WSL (apt-get, dnf, yum, pacman, apk)
# and Windows (Git Bash, with winget). Kept compatible with bash 3.2, the
# version macOS ships with.

set -euo pipefail

BLUE="\033[1;34m"
GREEN="\033[32m"
BOLD_GREEN="\033[1;32m"
YELLOW="\033[1;33m"
RED="\033[1;31m"
BOLD="\033[1m"
NC="\033[0m"

REPO_URL="https://github.com/ejagombar/Dotfiles.git"
REPO_SLUG="ejagombar/Dotfiles"

# Set from the command line in parseArgs
ASSUME_YES=false
OPTION=""

warn() { echo -e "${YELLOW}Warning:${NC} $*"; }
die() { echo -e "${RED}Error:${NC} $*" >&2; exit 1; }

########### OS Detection ###########

OS="$(uname -s)"
case "$OS" in
  Darwin) OS="macos" ;;
  Linux) OS="linux" ;;
  MINGW*|MSYS*|CYGWIN*) OS="windows" ;;
  *) die "Unsupported operating system: $OS" ;;
esac

IS_WSL=false
if [ "$OS" = "linux" ] && grep -qi microsoft /proc/version 2>/dev/null; then
  IS_WSL=true
fi

if [ "$OS" = "windows" ]; then
  # Make ln create real Windows symlinks, and fail rather than silently copy
  export MSYS="winsymlinks:nativestrict"
  export CYGWIN="winsymlinks:nativestrict"
fi

########### User / Privilege Setup ###########

USE_SUDO=""

# Detect the original invoking user and their home directory
ORIG_USER="${SUDO_USER:-${USER:-$(id -un)}}"

get_home_dir() {
  local user="$1" home=""
  if [ "$OS" = "windows" ]; then
    echo "$HOME"
    return 0
  fi
  if command -v getent >/dev/null 2>&1; then
    home="$(getent passwd "$user" | cut -d: -f6 || true)"
  elif command -v dscl >/dev/null 2>&1; then
    # macOS has no getent; read the home directory from Directory Services
    home="$(dscl . -read "/Users/$user" NFSHomeDirectory 2>/dev/null | awk '{print $2}' || true)"
  fi
  if [ -z "$home" ]; then
    if [ "$OS" = "macos" ]; then home="/Users/$user"; else home="/home/$user"; fi
  fi
  echo "$home"
}
ORIG_HOME="$(get_home_dir "$ORIG_USER")"

# Helper to ensure commands run as the non-root user
as_user() {
  if [ "$(id -u)" -eq 0 ] && [ "$ORIG_USER" != "root" ]; then
    sudo -u "$ORIG_USER" -H -- "$@"
  else
    "$@"
  fi
}

# Keep sudo alive for the duration of the script
keep_sudo_alive() {
  while true; do
    sudo -n true 2>/dev/null || true
    sleep 60
  done &
  SUDO_KEEPALIVE_PID=$!
  trap 'kill $SUDO_KEEPALIVE_PID 2>/dev/null || true' EXIT
}

# Windows has no sudo, and root (e.g. in a container) doesn't need it
setupPrivileges() {
  if [ "$OS" = "windows" ] || [ "$(id -u)" -eq 0 ]; then
    return 0
  fi
  command -v sudo >/dev/null 2>&1 || die "sudo is required but not found. Please install it first."

  echo -e "\n${BOLD_GREEN}Requesting sudo privileges (for system installs)...${NC}"
  sudo -v || die "You need sudo privileges to run this installer."
  USE_SUDO="sudo"
  keep_sudo_alive
}

# Clone a repo only if the target folder does not exist yet (safe to re-run)
clone_if_missing() {
  local dest="${*: -1}"
  if [ -d "$dest" ]; then
    echo "Already present, skipping: $dest"
  else
    as_user git clone "$@"
  fi
}

########### System Detection ###########

load_brew_env() {
  if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"   # Apple silicon
  elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"      # Intel
  fi
}

detectPackageManager() {
  if [ "$OS" = "macos" ]; then
    PKG_MANAGER="brew"
  elif [ "$OS" = "windows" ]; then
    if command -v winget >/dev/null 2>&1; then PKG_MANAGER="winget"; else PKG_MANAGER="none"; fi
  elif command -v apt-get >/dev/null; then
    PKG_MANAGER="apt-get"
    INSTALL_CMD="apt-get install -y"
  elif command -v dnf >/dev/null; then
    PKG_MANAGER="dnf"
    INSTALL_CMD="dnf install -y"
  elif command -v yum >/dev/null; then
    PKG_MANAGER="yum"
    INSTALL_CMD="yum install -y"
  elif command -v pacman >/dev/null; then
    PKG_MANAGER="pacman"
    INSTALL_CMD="pacman -Sy --noconfirm"
  elif command -v apk >/dev/null; then
    PKG_MANAGER="apk"
    INSTALL_CMD="apk add"
  else
    die "No supported package manager found!"
  fi
}

ensureBrew() {
  [ "$PKG_MANAGER" = "brew" ] || return 0
  load_brew_env
  if ! command -v brew >/dev/null 2>&1; then
    echo -e "${BOLD_GREEN}Homebrew not found. Installing Homebrew...${NC}"
    as_user /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    load_brew_env
  fi
}

detectArch() {
  ARCH=$(uname -m)
  case "$ARCH" in
    x86_64|amd64) ARCH="x86_64" ;;
    aarch64|arm64) ARCH="aarch64" ;;
    *) die "Unsupported architecture: $ARCH" ;;
  esac
}

# Map a generic package name to the name used by the current package manager
pkg_name() {
  case "$PKG_MANAGER:$1" in
    apt-get:fd|dnf:fd|yum:fd) echo "fd-find" ;;
    brew:wezterm) echo "--cask wezterm" ;;
    brew:delta|apt-get:delta|dnf:delta|yum:delta|pacman:delta) echo "git-delta" ;;
    winget:lazygit) echo "JesseDuffield.lazygit" ;;
    winget:delta) echo "dandavison.delta" ;;
    winget:difftastic) echo "Wilfred.difftastic" ;;
    winget:neovim) echo "Neovim.Neovim" ;;
    winget:ripgrep) echo "BurntSushi.ripgrep.MSVC" ;;
    winget:fzf) echo "junegunn.fzf" ;;
    winget:fd) echo "sharkdp.fd" ;;
    winget:gh) echo "GitHub.cli" ;;
    winget:eza) echo "eza-community.eza" ;;
    winget:wezterm) echo "wez.wezterm" ;;
    winget:starship) echo "Starship.Starship" ;;
    *) echo "$1" ;;
  esac
}

# Install packages with the right tool.
# Homebrew must run as the normal user, never with sudo.
pkg_install() {
  case "$PKG_MANAGER" in
    brew) as_user brew install "$@" ;;
    winget)
      local id
      for id in "$@"; do
        # winget errors when asked to install something already installed
        if winget list --id "$id" -e >/dev/null 2>&1; then
          echo "Already installed, skipping: $id"
        else
          winget install --id "$id" -e --accept-source-agreements --accept-package-agreements
        fi
      done
      ;;
    none) return 1 ;;
    # shellcheck disable=SC2086
    *) $USE_SUDO $INSTALL_CMD "$@" ;;
  esac
}

# Install packages one at a time, carrying on past any that aren't available
FAILED_PKGS=""
pkg_try() {
  local p
  for p in "$@"; do
    # shellcheck disable=SC2046
    if ! pkg_install $(pkg_name "$p"); then
      warn "Could not install $p, skipping."
      FAILED_PKGS="$FAILED_PKGS $p"
    fi
  done
}

########### Dotfiles Location ###########

is_dotfiles_repo() {
  [ -f "$1/.git/config" ] && grep -qi "$REPO_SLUG" "$1/.git/config"
}

# Work out where the repo lives:
#   local   - this script is being run from a checkout (or from inside one)
#   update  - ./Dotfiles is already a checkout, so pull it
#   clone   - ./Dotfiles doesn't exist yet
#   replace - ./Dotfiles exists but isn't the repo, so back it up and clone
resolveDotfilesPath() {
  local script_dir=""
  if [ -n "${BASH_SOURCE[0]:-}" ] && [ -f "${BASH_SOURCE[0]}" ]; then
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  fi

  if [ -n "$script_dir" ] && is_dotfiles_repo "$script_dir"; then
    DOTFILES_PATH="$script_dir"; REPO_MODE="local"
  elif is_dotfiles_repo "$(pwd)"; then
    DOTFILES_PATH="$(pwd)"; REPO_MODE="local"
  else
    # Absolute path, so the symlinks created later point to the right place
    DOTFILES_PATH="$(pwd)/Dotfiles"
    if is_dotfiles_repo "$DOTFILES_PATH"; then
      REPO_MODE="update"
    elif [ -e "$DOTFILES_PATH" ]; then
      REPO_MODE="replace"
    else
      REPO_MODE="clone"
    fi
  fi
}

confirmLocation() {
  echo -e "${BOLD}Dotfiles location${NC}"
  case "$REPO_MODE" in
    local) echo "  Using the dotfiles repo this script was run from:" ;;
    update) echo "  The dotfiles repo already exists in the current directory and will be updated:" ;;
    clone) echo "  The dotfiles repo will be cloned into the current directory:" ;;
    replace)
      echo "  The dotfiles repo will be cloned into the current directory."
      echo "  Something else already exists at this path and will be moved to a backup first:"
      ;;
  esac
  echo -e "    ${BOLD}${DOTFILES_PATH}${NC}"
  echo ""
  echo "  Your config files will be symlinked into this folder, so don't move or"
  echo "  delete it afterwards."
  if [ "$REPO_MODE" != "local" ]; then
    echo "  To use a different location, cd there and run this script again."
    [ -w "$(pwd)" ] || die "The current directory isn't writable: $(pwd)"
  fi
  echo ""

  if [ "$ASSUME_YES" = true ]; then
    return 0
  fi

  local answer=""
  read -rp "Continue? [y/N] " answer </dev/tty
  case "$answer" in
    y|Y|yes|YES) echo "" ;;
    *) echo "Cancelled. Nothing was changed."; exit 0 ;;
  esac
}

# Windows only allows symlinks with Developer Mode on, or from an admin shell
checkSymlinkSupport() {
  [ "$OS" = "windows" ] || return 0
  local tmp
  tmp="$(mktemp -d)"
  touch "$tmp/target"
  if ! ln -s "$tmp/target" "$tmp/link" 2>/dev/null || [ ! -L "$tmp/link" ]; then
    rm -rf "$tmp"
    die "Windows didn't allow this shell to create a symlink.
  Turn on Developer Mode (Settings > System > For developers),
  or run Git Bash as administrator, then run this script again."
  fi
  rm -rf "$tmp"
}

########### CLI ###########

printUsage() {
  echo "Usage: install.sh [--yes] [--bare | --full]"
  echo ""
  echo "  -y, --yes   Don't ask before using the dotfiles location"
  echo "  --bare      Bare install, without asking"
  echo "  --full      Full install, without asking"
  echo "  -h, --help  Show this help"
  echo ""
  echo "With no options, the script asks for each choice."
}

parseArgs() {
  while [ $# -gt 0 ]; do
    case "$1" in
      -y|--yes) ASSUME_YES=true ;;
      --bare) OPTION="bare" ;;
      --full) OPTION="full" ;;
      -h|--help) printUsage; printHelp; exit 0 ;;
      *) die "Unknown option: $1 (see --help)" ;;
    esac
    shift
  done
}

printHelp() {
  echo -e "\n${BLUE}===== HELP =====${NC}"
  echo -e "\n${BOLD}Bare Install:${NC}"
  if [ "$OS" = "windows" ]; then
    echo -e " neovim\n"
  else
    echo -e " neovim\n tmux\n zsh (made the default shell)\n curl\n git\n"
  fi
  echo -e "${BOLD}Full Install:${NC} everything in Bare, plus"
  case "$OS" in
    macos) echo -e " ripgrep\n fzf\n gh\n fd\n eza\n lazygit\n delta\n difftastic\n luarocks\n cmake\n wezterm\n tmux plugin manager (tpm)\n FiraCode Nerd Font\n" ;;
    linux) echo -e " ripgrep\n fzf\n gh\n fd\n eza\n lazygit\n delta\n difftastic\n luarocks\n make\n cmake\n unzip\n fontconfig\n tmux plugin manager (tpm)\n FiraCode Nerd Font\n" ;;
    windows) echo -e " ripgrep\n fzf\n gh\n fd\n eza\n lazygit\n delta\n difftastic\n wezterm\n starship\n" ;;
  esac
  echo -e "${BOLD}Both link these configs:${NC}"
  echo -e " neovim, zsh, starship, wezterm, tmux, git, lazygit, prettier, ~/bin scripts\n"
}

printBanner() {
  echo ""
  echo -e "${BLUE}██████╗  ██████╗ ████████╗${GREEN}███████╗██╗██╗     ███████╗███████╗"
  echo -e "${BLUE}██╔══██╗██╔═══██╗╚══██╔══╝${GREEN}██╔════╝██║██║     ██╔════╝██╔════╝"
  echo -e "${BLUE}██║  ██║██║   ██║   ██║   ${GREEN}█████╗  ██║██║     █████╗  ███████╗"
  echo -e "${BLUE}██║  ██║██║   ██║   ██║   ${GREEN}██╔══╝  ██║██║     ██╔══╝  ╚════██║"
  echo -e "${BLUE}██████╔╝╚██████╔╝   ██║   ${GREEN}██║     ██║███████╗███████╗███████║"
  echo -e "${BLUE}╚═════╝  ╚═════╝    ╚═╝   ${GREEN}╚═╝     ╚═╝╚══════╝╚══════╝╚══════╝${NC}"
  echo ""
  echo -e "Install and configure useful tools\n"
  echo -e "${BOLD}OS:${NC} ${OS}, ${BOLD}Pkg Manager:${NC} ${PKG_MANAGER}, ${BOLD}Arch:${NC} ${ARCH}"
  echo ""
}

promptUserInput() {
  echo "Select option:"
  echo -e " ${BOLD}[b]${NC} Bare Install - Essential tools only"
  echo -e " ${BOLD}[f]${NC} Full Install - Complete install"
  echo -e " ${BOLD}[h]${NC} Help - List the tools and plugins"
  echo ""

  OPTION=""
  while [[ "$OPTION" == "" ]]; do
    read -rp "Enter choice (b/f/h): " choice </dev/tty
    case "$choice" in
      b|B) OPTION="bare" ;;
      f|F) OPTION="full" ;;
      h|H) OPTION="help" ;;
      *) echo "Invalid choice."; OPTION="" ;;
    esac
  done
}

########### Core Install Helpers ###########

refresh_package_index() {
  case "$PKG_MANAGER" in
    brew) as_user brew update ;;
    apt-get) $USE_SUDO apt-get update ;;
    apk) $USE_SUDO apk update ;;
  esac
}

# Linux only: apt/yum often ship an old Neovim, so use the official release
install_neovim_linux() {
  echo "Installing Neovim"
  case "$ARCH" in
    x86_64) NVIM_URL="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz" ;;
    aarch64) NVIM_URL="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-arm64.tar.gz" ;;
  esac

  TMP_FILE="/tmp/$(basename "$NVIM_URL")"
  curl -fLo "$TMP_FILE" "$NVIM_URL" || die "Neovim download failed"

  $USE_SUDO rm -rf /opt/nvim /opt/nvim-linux*
  $USE_SUDO tar -C /opt -xzf "$TMP_FILE"
  $USE_SUDO ln -sf /opt/nvim-linux*/bin/nvim /usr/bin/nvim
  rm -f "$TMP_FILE"
}

# Linux only: many distros don't package lazygit (Ubuntu 24.04 for one), so use the official release
install_lazygit_linux() {
  echo "Installing lazygit"
  local lg_arch latest version tmp status
  case "$ARCH" in
    x86_64) lg_arch="x86_64" ;;
    aarch64) lg_arch="arm64" ;;
  esac

  # releases/latest redirects to the newest tag, e.g. .../releases/tag/v0.66.2
  latest="$(curl -fsSLI -o /dev/null -w '%{url_effective}' https://github.com/jesseduffield/lazygit/releases/latest)" || return 1
  version="${latest##*/v}"

  tmp="$(mktemp -d)"
  curl -fL "https://github.com/jesseduffield/lazygit/releases/download/v${version}/lazygit_${version}_Linux_${lg_arch}.tar.gz" |
    tar -xz -C "$tmp" lazygit &&
    $USE_SUDO install -m 755 "$tmp/lazygit" /usr/local/bin/lazygit
  status=$?
  rm -rf "$tmp"
  return $status
}

clone_dotfiles() {
  echo -e "${GREEN}Cloning dotfiles repo...${NC}"
  # Keep LF line endings on Windows, otherwise the scripts and .zshrc break
  as_user git clone -c core.autocrlf=false "$REPO_URL" "$DOTFILES_PATH"
}

prepareDotfiles() {
  echo -e "${BOLD_GREEN}Preparing dotfiles...${NC}"
  case "$REPO_MODE" in
    local) echo "Using dotfiles at $DOTFILES_PATH" ;;
    update)
      echo -e "${GREEN}Dotfiles repo already exists. Pulling latest...${NC}"
      as_user git -C "$DOTFILES_PATH" pull --rebase ||
        warn "Could not pull the latest changes. Carrying on with the current checkout."
      ;;
    replace)
      local backup
      backup="${DOTFILES_PATH}_backup_$(date +%Y%m%d%H%M%S)"
      echo -e "${BLUE}Existing ${DOTFILES_PATH} is not the dotfiles repo. Moving it to ${backup}${NC}"
      mv "$DOTFILES_PATH" "$backup"
      clone_dotfiles
      ;;
    clone) clone_dotfiles ;;
  esac
}

# Show paths under the home directory as ~/...
pretty_path() {
  local tilde="~"
  echo "${1/#$ORIG_HOME/$tilde}"
}

# Point $2 at $1. Anything already at $2 that isn't a symlink is moved to a
# timestamped backup rather than overwritten. Each link is checked afterwards.
LINK_FAILURES=0
link() {
  local src="$1" dest="$2" backup
  if [ ! -e "$src" ]; then
    echo -e "  ${RED}missing${NC} $(pretty_path "$src") is not in the repo"
    LINK_FAILURES=$((LINK_FAILURES + 1))
    return 0
  fi

  as_user mkdir -p "$(dirname "$dest")"

  if [ -L "$dest" ]; then
    if [ "$dest" -ef "$src" ]; then
      echo -e "  ${GREEN}ok${NC}      $(pretty_path "$dest")"
      return 0
    fi
    as_user rm -f "$dest"
  elif [ -e "$dest" ]; then
    backup="$dest.backup.$(date +%Y%m%d%H%M%S)"
    as_user mv "$dest" "$backup"
    echo -e "  ${YELLOW}backup${NC}  $(pretty_path "$dest") moved to $(pretty_path "$backup")"
  fi

  if as_user ln -s "$src" "$dest" && [ -L "$dest" ] && [ "$dest" -ef "$src" ]; then
    echo -e "  ${GREEN}linked${NC}  $(pretty_path "$dest") -> $(pretty_path "$src")"
  else
    echo -e "  ${RED}failed${NC}  $(pretty_path "$dest") -> $(pretty_path "$src")"
    LINK_FAILURES=$((LINK_FAILURES + 1))
  fi
}

setupSymlinks() {
  echo -e "${BOLD_GREEN}Setting symlinks...${NC}"
  local repo="$DOTFILES_PATH" config="$ORIG_HOME/.config" nvim_dir lazygit_dir

  # Neovim reads %LOCALAPPDATA%\nvim on Windows and ~/.config/nvim elsewhere.
  # Lazygit reads %APPDATA%\lazygit on Windows and ~/Library/Application Support on macOS.
  # WezTerm and starship read ~/.config on every OS.
  case "$OS" in
    windows)
      nvim_dir="$(cygpath -u "${LOCALAPPDATA:-$ORIG_HOME/AppData/Local}")/nvim"
      lazygit_dir="$(cygpath -u "${APPDATA:-$ORIG_HOME/AppData/Roaming}")/lazygit"
      ;;
    macos)
      nvim_dir="$config/nvim"
      lazygit_dir="$ORIG_HOME/Library/Application Support/lazygit"
      ;;
    *)
      nvim_dir="$config/nvim"
      lazygit_dir="$config/lazygit"
      ;;
  esac

  link "$repo/nvim" "$nvim_dir"
  link "$repo/lazygit/config.yml" "$lazygit_dir/config.yml"
  link "$repo/zsh/.zshrc" "$ORIG_HOME/.zshrc"
  link "$repo/zsh/starship.toml" "$config/starship.toml"
  link "$repo/wezterm/wezterm.lua" "$config/wezterm/wezterm.lua"
  link "$repo/tmux/.tmux.conf" "$ORIG_HOME/.tmux.conf"
  link "$repo/.gitconfig" "$ORIG_HOME/.gitconfig"
  link "$repo/.prettierrc" "$ORIG_HOME/.prettierrc"
  link "$repo/scripts/tmux-sessioniser.sh" "$ORIG_HOME/bin/tmux-sessioniser"
  link "$repo/scripts/open-github.sh" "$ORIG_HOME/bin/github"

  if [ -e "$ORIG_HOME/.wezterm.lua" ]; then
    warn "~/.wezterm.lua exists and may be loaded instead of ~/.config/wezterm/wezterm.lua. Remove it to use the dotfiles config."
  fi

  if [ "$LINK_FAILURES" -gt 0 ]; then
    if [ "$OS" = "windows" ]; then
      die "$LINK_FAILURES symlink(s) failed. Check Developer Mode is on (Settings > System > For developers)."
    fi
    die "$LINK_FAILURES symlink(s) failed."
  fi
}

setZshAsDefault() {
  local zsh_path
  zsh_path="$(command -v zsh || true)"
  if [ -z "$zsh_path" ] || ! command -v chsh >/dev/null 2>&1; then
    warn "zsh or chsh not found, so the default shell was not changed."
    return 0
  fi

  if ! grep -qx "$zsh_path" /etc/shells; then
    echo "$zsh_path" | $USE_SUDO tee -a /etc/shells >/dev/null
  fi

  echo -e "${BOLD_GREEN}Setting default shell to zsh for ${ORIG_USER}${NC}"
  $USE_SUDO chsh -s "$zsh_path" "$ORIG_USER" ||
    warn "Could not change the default shell. Run: chsh -s $zsh_path"
}

installFont() {
  font_name="FiraCode"
  echo -e "${BOLD_GREEN}Installing ${font_name} Nerd Font${NC}"

  if [ "$OS" = "macos" ]; then
    FONT_DIR="$ORIG_HOME/Library/Fonts/${font_name}"
  else
    FONT_DIR="$ORIG_HOME/.local/share/fonts/${font_name}"
  fi

  TMP_FONT="/tmp/${font_name}.zip"
  curl -fL -o "$TMP_FONT" "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${font_name}.zip" ||
    die "Failed to download ${font_name} font"

  as_user mkdir -p "$FONT_DIR"
  as_user unzip -o "$TMP_FONT" -d "$FONT_DIR"
  rm -f "$TMP_FONT"

  # macOS picks up fonts in ~/Library/Fonts on its own; Linux needs a cache refresh
  if [ "$OS" = "linux" ] && command -v fc-cache >/dev/null 2>&1; then
    fc-cache -f
  fi
}

printNotes() {
  echo ""
  echo -e "${BOLD}Next steps${NC}"
  if [ "$OS" = "windows" ]; then
    echo " - zsh and tmux don't run natively on Windows. Run this script inside WSL for those."
    echo " - Install \"FiraCode Nerd Font\" (https://www.nerdfonts.com/font-downloads) for the WezTerm config."
    echo " - starship reads ~/.config/starship.toml, but your shell still needs to run 'starship init'."
  else
    echo " - Open a new terminal. zinit installs the zsh plugins and starship the first time zsh starts."
    echo " - In tmux, press prefix + I to install the tmux plugins."
  fi
  if [ "$OS" = "linux" ]; then
    if [ "$IS_WSL" = true ]; then
      echo " - WezTerm runs on the Windows side, so run this script in Git Bash too to link its config."
    else
      echo " - WezTerm isn't in most distro repos. See https://wezterm.org/install/linux.html"
    fi
  fi
  if [ -n "$FAILED_PKGS" ]; then
    echo -e " - ${YELLOW}These packages could not be installed:${NC}${FAILED_PKGS}"
  fi
  if [ "$PKG_MANAGER" = "none" ]; then
    echo -e " - ${YELLOW}winget was not found, so no packages were installed.${NC}"
  fi
}

########### Installation Types ###########

installBare() {
  echo -e "${BOLD_GREEN}Installing essential tools...${NC}"
  if [ "$OS" = "windows" ]; then
    # Git Bash already comes with git and curl
    pkg_try neovim
  else
    refresh_package_index
    ESSENTIALS="tmux zsh curl git"

    # shellcheck disable=SC2086
    if [[ ${PKG_MANAGER} == "apt-get" || ${PKG_MANAGER} == "yum" ]]; then
      pkg_install $ESSENTIALS
      install_neovim_linux
    else
      pkg_install $ESSENTIALS neovim
    fi
  fi

  prepareDotfiles
  setupSymlinks
  if [ "$OS" != "windows" ]; then
    setZshAsDefault
  fi
  echo -e "${BOLD_GREEN}Bare installation complete!${NC}"
}

installFull() {
  installBare
  echo -e "${BOLD_GREEN}Installing additional tools...${NC}"

  case "$OS" in
    # unzip and make come with macOS / Xcode Command Line Tools; fontconfig is not needed
    macos) ADDITIONAL_PACKAGES="ripgrep fzf gh fd eza lazygit delta difftastic luarocks cmake wezterm" ;;
    linux) ADDITIONAL_PACKAGES="ripgrep fzf gh fd eza delta difftastic luarocks make cmake unzip fontconfig" ;;
    windows) ADDITIONAL_PACKAGES="ripgrep fzf gh fd eza lazygit delta difftastic wezterm starship" ;;
  esac
  # shellcheck disable=SC2086
  pkg_try $ADDITIONAL_PACKAGES

  if [ "$OS" = "linux" ] && ! install_lazygit_linux; then
    warn "Could not install lazygit, skipping."
    FAILED_PKGS="$FAILED_PKGS lazygit"
  fi

  if [ "$OS" != "windows" ]; then
    echo -e "${BOLD_GREEN}Installing Tmux TPM${NC}"
    clone_if_missing https://github.com/tmux-plugins/tpm "$ORIG_HOME/.tmux/plugins/tpm"
    installFont
  fi

  echo -e "${BOLD_GREEN}Full installation complete!${NC}"
}

########### Main ###########

performCommands() {
  # --bare or --full chose already; otherwise ask until we get one of them
  while [[ ! ( "$OPTION" == "bare" || "$OPTION" == "full" ) ]]; do
    promptUserInput
    if [ "$OPTION" = "help" ]; then printHelp; fi
  done

  setupPrivileges
  ensureBrew
  if [ "$OPTION" = "bare" ]; then installBare; else installFull; fi
  printNotes
  echo -e "\n${GREEN}Exiting.${NC}"
}

main() {
  parseArgs "$@"
  detectArch
  detectPackageManager
  resolveDotfilesPath
  printBanner
  confirmLocation
  checkSymlinkSupport
  performCommands
}

main "$@"
