#!/usr/bin/env bash

BLUE="\033[1;34m"
GREEN="\033[32m"
BOLD_GREEN="\e[1;32m"
BOLD="\033[1m" 
NC="\033[0m"

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

promptForSudo() {
  USE_SUDO=""
  if [ "$(id -u)" -ne 0 ]; then
    if command -v sudo >/dev/null; then
      USE_SUDO="sudo"
    else
      echo "Failed to get sudo access. Exiting."
      exit 1
    fi
  fi
}

########### Core Install Helpers ###########

install_neovim() {
  echo "Installing Neovim"
  case "$ARCH" in
    x86_64) NVIM_URL="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz" ;;
    aarch64) NVIM_URL="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-arm64.tar.gz" ;;
    *) echo "No prebuilt Neovim for $ARCH"; exit 1 ;;
  esac

  curl -LO "$NVIM_URL"
  $USE_SUDO rm -rf /opt/nvim
  $USE_SUDO tar -C /opt -xzf "$(basename "$NVIM_URL")"
  $USE_SUDO ln -sf /opt/nvim-linux*/bin/nvim /usr/bin/nvim
  rm -f "$(basename "$NVIM_URL")"
}

prepareDotfiles() {
  echo -e "${BOLD_GREEN}Preparing dotfiles...${NC}"
  REPO_URL="https://github.com/ejagombar/Dotfiles.git"
  REPO_DIR="Dotfiles"
  BASE_DIR="$(pwd)"
  REPO_PATH="${BASE_DIR}/${REPO_DIR}"
  REPO_PATH=$(realpath -m "$REPO_PATH" 2>/dev/null || echo "$REPO_PATH")

  if [ -d "${REPO_PATH}/.git" ]; then
    cd "$REPO_PATH" || exit 1
    CURRENT_REMOTE=$(git config --get remote.origin.url)
    if [[ "$CURRENT_REMOTE" == "$REPO_URL" ]]; then
      echo -e "${GREEN}Dotfiles repo already exists and is valid. Pulling latest...${NC}"
      git pull --rebase
    else
      echo -e "${BLUE}Existing directory '$REPO_DIR' is not the expected repo. Backing up...${NC}"
      cd "$BASE_DIR" || exit 1
      mv "$REPO_DIR" "${REPO_DIR}_backup_$(date +%s)"
      git clone "$REPO_URL" "$REPO_PATH"
    fi
  else
    echo -e "${GREEN}Cloning dotfiles repo...${NC}"
    git clone "$REPO_URL" "$REPO_PATH"
  fi

  cd "$BASE_DIR" || exit 1
  DOTFILES_PATH="$REPO_PATH"
}

setupSymlinks() {
  echo -e "${BOLD_GREEN}Setting symlinks...${NC}"
  local cwd="$DOTFILES_PATH"

  mkdir -p "$HOME/.config"

  echo -e "${GREEN}Setting tmux symlink${NC}"
  ln -sf "$cwd/tmux/.tmux.conf" "$HOME/.tmux.conf"

  echo -e "${GREEN}Setting zsh symlink${NC}"
  ln -sf "$cwd/zsh/.zshrc" "$HOME/.zshrc"

  echo -e "${GREEN}Setting nvim symlink${NC}"
  ln -sf "$cwd/nvim" "$HOME/.config/nvim"

  echo -e "${GREEN}Setting gitconfig symlink${NC}"
  ln -sf "$cwd/.gitconfig" "$HOME/.gitconfig"

  echo -e "${GREEN}Setting prettier symlink${NC}"
  ln -sf "$cwd/.prettierrc" "$HOME/.prettierrc"

  echo -e "${BOLD_GREEN}Setting up scripts...${NC}"
  mkdir -p "$HOME/bin"
  ln -sf "$cwd/scripts/tmux-sessioniser.sh" "$HOME/bin/tmux-sessioniser"
  ln -sf "$cwd/scripts/open-github.sh" "$HOME/bin/github"
}

setZshAsDefault() {
  ZSH_PATH=$(command -v zsh)
  if ! grep -q "$ZSH_PATH" /etc/shells; then
    echo "$ZSH_PATH" | $USE_SUDO tee -a /etc/shells
  fi
  echo -e "${BOLD_GREEN}Setting shell to zsh${NC}"
  chsh -s "$ZSH_PATH"
}

########### Installation Types ###########

installBare() {
  promptForSudo
  prepareDotfiles

  echo -e "${BOLD_GREEN}Installing bear necessities...${NC}"
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

  echo -e "${BOLD_GREEN}Installing additional tools for full setup...${NC}"
  ADDITIONAL_PACKAGES="ripgrep fzf unzip fontconfig gh fd-find luarocks make cmake"

  $USE_SUDO $INSTALL_CMD $ADDITIONAL_PACKAGES

  echo -e "${BOLD_GREEN}Installing Oh My Zsh & plugins${NC}"
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
  git clone https://github.com/spaceship-prompt/spaceship-prompt.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/spaceship-prompt --depth=1

  echo -e "${BOLD_GREEN}Installing Tmux TPM${NC}"
  git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm

  echo -e "${BOLD_GREEN}Installing Fira Code Nerd Font${NC}"
  font_name="FiraCode"
  curl -OL "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${font_name}.zip"
  mkdir -p "$HOME/.local/share/fonts/"
  unzip -o "${font_name}.zip" -d "$HOME/.local/share/fonts/${font_name}/"
  fc-cache -f

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

