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
    INSTALL_CMD="pacman -Sy"
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
    x86_64|amd64)
      ARCH="x86_64"
      ;;
    aarch64|arm64)
      ARCH="aarch64"
      ;;
    *)
      echo "Unsupported architecture: $ARCH"
      exit 1
      ;;
  esac
}

########### CLI ###########

printHelp() {
    echo -e "\n${BLUE}===== HELP =====${NC}"
    echo -e "\n${BOLD}Full Install:${NC}"
    echo -e " neovim\n tmux\n zsh\n ripgrep\n fzf\n curl\n zoxide\n git\n eza\n gh\n fd-find\n"
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
    echo -e "${BLUE}╚═════╝  ╚═════╝    ╚═╝   ${GREEN}╚═╝     ╚═╝╚══════╝╚══════╝╚══════╝"
    echo -e "${NC}"
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
        b|B)
          OPTION="bare"
          ;;
        f|F)
          OPTION="full"
          ;;
        h|H)
          OPTION="help"
          ;;
        *)
          echo "Invalid choice."
          OPTION=""
          ;;
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

########### Install Scripts ###########

install_neovim() {
  echo "Installing Neovim"

  case "$ARCH" in
    x86_64)
      NVIM_URL="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz"
      ;;
    aarch64)
      NVIM_URL="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-arm64.tar.gz"
      ;;
    *)
      echo "No prebuilt Neovim for $ARCH"
      exit 1
      ;;
  esac

  curl -LO "$NVIM_URL"

  $USE_SUDO rm -rf /opt/nvim
  $USE_SUDO tar -C /opt -xzf "$(basename "$NVIM_URL")"

  $USE_SUDO rm -f /usr/bin/nvim
  $USE_SUDO ln -s /opt/nvim-linux*/bin/nvim /usr/bin/nvim

  rm -f "$(basename "$NVIM_URL")"
}


installFull() {
    promptForSudo

    FULL_PACKAGES="tmux zsh ripgrep fzf zoxide unzip fontconfig gh fd-find eza luarocks git make cmake nodejs npm"

    echo -e "${BOLD_GREEN}Installing tools...${NC}"

    if [[ ${PKG_MANAGER} == "apt-get" || ${PKG_MANAGER} == "yum" ]]; then # Slow to get new updates
        install_neovim
        $INSTALL_CMD $FULL_PACKAGES
    else 
        $USE_SUDO $INSTALL_CMD $FULL_PACKAGES "neovim"
    fi

    echo -e "${BOLD_GREEN}Cloning dotfiles repository...${NC}"
    git clone https://github.com/ejagombar/Dotfiles.git

    echo -e "${BOLD_GREEN}Installing OMZ${NC}"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

    echo -e "${BOLD_GREEN}Installing zsh autosuggestions${NC}"
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

    echo -e "${BOLD_GREEN}Installing zsh syntax highlighting${NC}"
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

    echo -e "${BOLD_GREEN}Installing Spaceship prompt${NC}"
    git clone https://github.com/spaceship-prompt/spaceship-prompt.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/spaceship-prompt --depth=1

    echo -e "${BOLD_GREEN}Installing Tmux TPM${NC}"
    git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm

    ################################################################################

    echo -e "${BOLD_GREEN}Setting symlinks...${NC}"
    cwd="$(pwd)/Dotfiles"

    if [ ! -d "$HOME/.config" ]; then
        mkdir "$HOME/.config" 
    fi

    echo -e "${GREEN}Setting tmux symlink${NC}"
    rm -f "$HOME/.tmux.conf"
    ln -sf "$cwd/tmux/.tmux.conf" "$HOME/.tmux.conf"

    echo -e "${GREEN}Setting zsh symlink${NC}"
    rm -f "$HOME/.zshrc"
    ln -sf "$cwd/zsh/.zshrc" "$HOME/.zshrc"

    echo -e "${GREEN}Setting nvim symlink${NC}"
    rm -rf "$HOME/.config/nvim"
    ln -sf "$cwd/nvim" "$HOME/.config/nvim"

    echo -e ${GREEN}"Setting starship symlink${NC}"
    rm -f "$HOME/.config/starship.toml"
    ln -sf "$cwd/zsh/starship.toml" "$HOME/.config/starship.toml"

    echo -e "${GREEN}Setting gitconfig symlink${NC}"
    rm -f "$HOME/.gitconfig"
    ln -sf "$cwd/.gitconfig" "$HOME/.gitconfig"

    echo -e "${GREEN}Setting prettier symlink${NC}\n"
    rm -f "$HOME/.prettierrc"
    ln -sf "$cwd/.prettierrc" "$HOME/.prettierrc"

    echo -e "${BOLD_GREEN}Setting up scripts...${NC}"
    if [ ! -d "$HOME/bin" ]; then
        mkdir "$HOME/bin" 
    fi

    rm -f "$HOME/bin/tmux-sessioniser"
    ln -sf "$cwd/scripts/tmux-sessioniser.sh" "$HOME/bin/tmux-sessioniser"

    rm -f "$HOME/bin/github"
    ln -sf "$cwd/scripts/open-github.sh" "$HOME/bin/github"
    
    ############################################################################

    font_name="FiraCode"
    echo -e ${BOLD_GREEN}"Installing Fira Code Nerd Font${NC}"
    curl -OL "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${font_name}.zip"
    echo "creating fonts folder: ${HOME}/.fonts"
    mkdir -p  "$HOME/.local/share/fonts/"
    echo -e "${GREEN}Unzipping the ${font_name}.zip${NC}"
    unzip "${font_name}.zip" -d "$HOME/.local/share/fonts/${font_name}/"
    fc-cache -f

    ZSH_PATH=$(command -v zsh)
    if ! grep -q "$ZSH_PATH" /etc/shells; then
        echo "$ZSH_PATH" | $USE_SUDO tee -a /etc/shells
    fi

    echo -e "${BOLD_GREEN}Setting shell to zsh${NC}"
    chsh -s "$ZSH_PATH"
    zsh

    echo -e "${BOLD_GREEN}Finished!${NC}"
}

########### Main Program ###########

performCommands() {
    OPTION=""

    while [[ ! ( "$OPTION" == "bare" || "$OPTION" == "full" ) ]]; do
    promptUserInput

        case "$OPTION" in
        help)
            printHelp
          ;;
        small)
            echo "Performing small installation..."
          ;;
        full)
            installFull
          ;;
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
