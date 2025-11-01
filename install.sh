#!/usr/bin/env bash

BLUE="\033[1;34m"
GREEN="\033[32m"
BOLD_GREEN="\e[1;32m"
BOLD="\033[1m" 
NC="\033[0m"

set -euo pipefail

########### Privilege / Environment Setup ###########

# Detect sudo
if command -v sudo >/dev/null 2>&1; then
  USE_SUDO="sudo"
else
  echo "sudo is required but not found. Please install it first."
  exit 1
fi

# Verify we can escalate; prompt once
echo -e "\n${BOLD_GREEN}Requesting sudo privileges (for system installs)...${NC}"
if ! $USE_SUDO -v; then
  echo "You need sudo privileges to run this installer."
  exit 1
fi

# Keep sudo alive for the duration of the script
keep_sudo_alive() {
  while true; do
    $USE_SUDO -n true 2>/dev/null || true
    sleep 60
  done &
  SUDO_KEEPALIVE_PID=$!
  trap 'kill $SUDO_KEEPALIVE_PID 2>/dev/null || true' EXIT
}
keep_sudo_alive

# Detect the original invoking user and their home directory
ORIG_USER="${SUDO_USER:-$USER}"
ORIG_HOME="$(getent passwd "$ORIG_USER" | cut -d: -f6 || echo "/home/$ORIG_USER")"

# Helper to ensure commands run as the non-root user
as_user() {
  if [ "$(id -u)" -eq 0 ]; then
    $USE_SUDO -u "$ORIG_USER" -- "$@"
  else
    "$@"
  fi
}

########### System Detection ###########

detectPackageManager() {
  if command -v apt-get >/dev/null; then
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
    INSTALL_CMD="apk add -y"
  else
    echo "No supported package manager found!"
    exit 1
  fi
}

detectArch() {
  ARCH=$(uname -m)
  case "$ARCH" in
    x86_64|amd64) ARCH="x86_64" ;;
    aarch64|arm64) ARCH="aarch64" ;;
    *) echo "Unsupported architecture: $ARCH"; exit 1 ;;
  esac
}

########### CLI ###########

printHelp() {
  echo -e "\n${BLUE}===== HELP =====${NC}"
  echo -e "\n${BOLD}Full Install:${NC}"
  echo -e " neovim\n tmux\n zsh\n ripgrep\n fzf\n curl\n git\n eza\n gh\n fd-find\n"
  echo -e "${BOLD}Bare Install:${NC}"
  echo -e " neovim\n tmux\n zsh\n"
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
  echo -e "${BOLD}Pkg Manager:${NC} ${PKG_MANAGER}, ${BOLD}Arch:${NC} ${ARCH}"
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

install_neovim() {
  echo "Installing Neovim"
  case "$ARCH" in
    x86_64) NVIM_URL="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz" ;;
    aarch64) NVIM_URL="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-arm64.tar.gz" ;;
  esac

  TMP_FILE="/tmp/$(basename "$NVIM_URL")"
  curl -fLo "$TMP_FILE" "$NVIM_URL" || { echo "Download failed"; exit 1; }

  $USE_SUDO rm -rf /opt/nvim
  $USE_SUDO tar -C /opt -xzf "$TMP_FILE"
  $USE_SUDO ln -sf /opt/nvim-linux*/bin/nvim /usr/bin/nvim
  rm -f "$TMP_FILE"
}

prepareDotfiles() {
  echo -e "${BOLD_GREEN}Preparing dotfiles...${NC}"
  REPO_URL="https://github.com/ejagombar/Dotfiles.git"
  REPO_PATH="./Dotfiles"

  if [ -d "${REPO_PATH}/.git" ]; then
    cd "$REPO_PATH" || exit 1
    CURRENT_REMOTE=$(git config --get remote.origin.url)
    if [[ "$CURRENT_REMOTE" == "$REPO_URL" ]]; then
      echo -e "${GREEN}Dotfiles repo already exists. Pulling latest...${NC}"
      as_user git pull --rebase
    else
      echo -e "${BLUE}Existing directory is not the expected repo. Backing up...${NC}"
      mv "$REPO_PATH" "${REPO_PATH}_backup_$(date +%s)"
      as_user git clone "$REPO_URL" "$REPO_PATH"
    fi
  else
    echo -e "${GREEN}Cloning dotfiles repo...${NC}"
    as_user git clone "$REPO_URL" "$REPO_PATH"
  fi
  DOTFILES_PATH="$REPO_PATH"
}

setupSymlinks() {
  echo -e "${BOLD_GREEN}Setting symlinks...${NC}"
  local cwd="$DOTFILES_PATH"

  mkdir -p "$ORIG_HOME/.config"

  ln -sf "$cwd/tmux/.tmux.conf" "$ORIG_HOME/.tmux.conf"
  ln -sf "$cwd/zsh/.zshrc" "$ORIG_HOME/.zshrc"
  ln -sf "$cwd/nvim" "$ORIG_HOME/.config/nvim"
  ln -sf "$cwd/.gitconfig" "$ORIG_HOME/.gitconfig"
  ln -sf "$cwd/.prettierrc" "$ORIG_HOME/.prettierrc"

  mkdir -p "$ORIG_HOME/bin"
  ln -sf "$cwd/scripts/tmux-sessioniser.sh" "$ORIG_HOME/bin/tmux-sessioniser"
  ln -sf "$cwd/scripts/open-github.sh" "$ORIG_HOME/bin/github"
}

setZshAsDefault() {
  ZSH_PATH=$(command -v zsh)
  if ! grep -q "$ZSH_PATH" /etc/shells; then
    echo "$ZSH_PATH" | $USE_SUDO tee -a /etc/shells >/dev/null
  fi

  echo -e "${BOLD_GREEN}Setting default shell to zsh for ${ORIG_USER}${NC}"

  if [ "$(id -u)" -eq 0 ]; then
    chsh -s "$ZSH_PATH" "$ORIG_USER"
  else
    $USE_SUDO chsh -s "$ZSH_PATH" "$ORIG_USER"
  fi
}


########### Installation Types ###########

installBare() {
  prepareDotfiles
  echo -e "${BOLD_GREEN}Installing essential tools...${NC}"
  ESSENTIALS="tmux zsh curl git"

  if [[ ${PKG_MANAGER} == "apt-get" || ${PKG_MANAGER} == "yum" ]]; then
    install_neovim
    $USE_SUDO $INSTALL_CMD $ESSENTIALS
  else
    $USE_SUDO $INSTALL_CMD $ESSENTIALS neovim
  fi

  setupSymlinks
  setZshAsDefault
  echo -e "${BOLD_GREEN}Bare installation complete!${NC}"
}

installFull() {
  installBare
  echo -e "${BOLD_GREEN}Installing additional tools...${NC}"
  ADDITIONAL_PACKAGES="ripgrep fzf unzip fontconfig gh fd-find luarocks make cmake"
  $USE_SUDO $INSTALL_CMD $ADDITIONAL_PACKAGES

  echo -e "${BOLD_GREEN}Installing Oh My Zsh & plugins${NC}"
  as_user sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  as_user git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$ORIG_HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
  as_user git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$ORIG_HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
  as_user git clone https://github.com/spaceship-prompt/spaceship-prompt.git ${ZSH_CUSTOM:-$ORIG_HOME/.oh-my-zsh/custom}/themes/spaceship-prompt --depth=1

  echo -e "${BOLD_GREEN}Installing Tmux TPM${NC}"
  as_user git clone https://github.com/tmux-plugins/tpm $ORIG_HOME/.tmux/plugins/tpm

  font_name="FiraCode"
  echo -e "${BOLD_GREEN}Installing ${font_name} Nerd Font${NC}"
  TMP_FONT="/tmp/${font_name}.zip"

  curl -fL -o "$TMP_FONT" "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${font_name}.zip" || {
    echo "Failed to download ${font_name} font"
    exit 1
  }

  mkdir -p "$ORIG_HOME/.local/share/fonts/${font_name}/"
  unzip -o "$TMP_FONT" -d "$ORIG_HOME/.local/share/fonts/${font_name}/"
  fc-cache -f

  rm -f "$TMP_FONT"
  echo -e "${BOLD_GREEN}Full installation complete!${NC}"
}

########### Main ###########

performCommands() {
  OPTION=""
  while [[ ! ( "$OPTION" == "bare" || "$OPTION" == "full" ) ]]; do
    promptUserInput
    case "$OPTION" in
      help) printHelp ;;
      bare) installBare ;;
      full) installFull ;;
    esac
  done
  echo -e "\n${GREEN}Exiting.${NC}"
}

main() {
  detectPackageManager
  detectArch
  printBanner
  performCommands
}

main "$@"

