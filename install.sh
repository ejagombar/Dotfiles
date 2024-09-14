#!/bin/bash

BOLD_RED="\e[1;31m"
BOLD_GREEN="\e[1;32m"
RESET="\e[0m"

# Function to show usage
usage() {
    echo -e "${BOLD_RED}Usage: $0 [--extra] [--latest]${RESET}"
    exit 1
}

# Parse arguments
EXTRA_FLAG=0
LATEST_FLAG=0
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --extra) EXTRA_FLAG=1 ;;
        --latest) LATEST_FLAG=1 ;;
        *) usage ;;
    esac
    shift
done

# Confirm running the script
echo "This script will replace any neovim, tmux, zsh configurations already in place. Are you sure? (y/N)"
read -r CONFIRMATION
if [[ $CONFIRMATION != "y" ]]; then
    echo "Script execution cancelled."
    exit 0
fi

APT_CMD=$(which apt)
DNF_CMD=$(which dnf)

if [[ ! -z $APT_CMD ]]; then
    INSTALL_CMD="sudo apt install -y"
elif [[ ! -z $DNF_CMD ]]; then
    INSTALL_CMD="sudo dnf install -y"
else
    echo -e "${BOLD_RED}Error: can't install packages${RESET}"
    exit 1
fi

BASE_PACKAGES="tmux zsh neovim rg fzf"
EXTRA_PACKAGES="bat exa luarocks gh"

echo "Installing dependencies..."

if [[ $LATEST_FLAG -eq 1 ]]; then
    curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
    sudo rm -rf /opt/nvim
    sudo tar -C /opt -xzf nvim-linux64.tar.gz
else 
    $INSTALL_CMD $BASE_PACKAGES
fi

if [[ $EXTRA_FLAG -eq 1 ]]; then
    $INSTALL_CMD $EXTRA_PACKAGES
fi

echo "Cloning repos..."

echo "Installing OMZ"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

echo "Installing zsh autosuggestions"
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

echo "Installing zsh syntax highlighting"
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

echo "Installing Spaceship prompt"
git clone https://github.com/spaceship-prompt/spaceship-prompt.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/spaceship-prompt --depth=1

echo "Installing Tmux TPM"
git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm

echo "Setting symlinks..."
cwd=$(pwd)

echo -e "${BOLD_GREEN}\tSetting tmux symlink${RESET}"
rm -f "$HOME/.tmux.conf"
ln -sf "$cwd/tmux/.tmux.conf" "$HOME/.tmux.conf"

echo -e "${BOLD_GREEN}\tSetting zsh symlink${RESET}"
rm -f "$HOME/.zshrc"
ln -sf "$cwd/zsh/.zshrc" "$HOME/.zshrc"

echo -e "${BOLD_GREEN}\tSetting nvim symlink${RESET}"
rm -rf "$HOME/.config/nvim"
ln -sf "$cwd/nvim" "$HOME/.config/nvim"

echo -e "${BOLD_GREEN}\tSetting starship symlink${RESET}"
rm -f "$HOME/.config/starship.toml"
ln -sf "$cwd/zsh/starship.toml" "$HOME/.config/starship.toml"

echo -e "${BOLD_GREEN}\tSetting gitconfig symlink${RESET}"
rm -f "$HOME/.gitconfig"
ln -sf "$cwd/.gitconfig" "$HOME/.gitconfig"

echo -e "${BOLD_GREEN}\tSetting prettier symlink${RESET}"
rm -f "$HOME/.prettierrc"
ln -sf "$cwd/.prettierrc" "$HOME/.prettierrc"

echo "Adding zsh syntax highlighting path to .zshrc"
echo "source ${(q-)PWD}/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ${ZDOTDIR:-$HOME}/.zshrc

echo -e "${BOLD_GREEN}Finished!${RESET}"
