#!/bin/bash

BOLD_RED="\e[1;31m"
BOLD_GREEN="\e[1;32m"
RESET="\e[0m"

# Function to show usage
usage() {
    echo "Usage: $0 [--extra]"
    exit 1
}

if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root"
    exit 1
fi

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
    INSTALL_CMD="apt install -y"
elif [[ ! -z $DNF_CMD ]]; then
    INSTALL_CMD="dnf install -y"
else
    echo "Error: can't install packages"
    exit 1
fi

BASE_PACKAGES = "tmux zsh neovim rg fzf"
EXTRA_PACKAGES = "bat exa luarocks gh"

echo "Installing dependencies..."


if [[ $LATEST_FLAG -eq 1 ]]; then
    curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
    rm -rf /opt/nvim
    tar -C /opt -xzf nvim-linux64.tar.gz
else 
    $INSTALL_CMD "neovim"
fi

$INSTALL_CMD $BASE_PACKAGES

if [[ $EXTRA_FLAG -eq 1 ]]; then
    $INSTALL_CMD $EXTRA_PACKAGES
fi


echo "Cloning repos..."

echo "Installing OMZ"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

echo "Installing zsh autosuggestions"
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

echo "Installing zsh syntax highlighting"
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git

echo "Installing Spaceship prompt"
git clone https://github.com/spaceship-prompt/spaceship-prompt.git "$ZSH_CUSTOM/themes/spaceship-prompt" --depth=1

echo "Installing Tmux TPM"
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm


echo "Setting symlinks..."
cwd=$(pwd)

echo "\tSetting tmux symlink"
rm "~/.tmux.conf"
ln -s "$cwd/tmux/.tmux.conf" "~/"

echo "\tSetting zsh symlink"
rm "~/.zshrc"
ln -s "$cwd/zsh/.zshrc" "~/"

echo "\tSetting nvim symlink"
rm -r "~/.config/nvim"
ln -s "$cwd/nvim" "~/.config/"

echo "\tSetting starship symlink"
rm "~/.config/starship.toml"
ln -s "$(cwd)/zsh/starship.toml." "~/.config/"

echo "\tSetting gitconfig symlink"
rm "~/.gitconfig"
ln -s "$(cwd)/.gitconfig" "~/"

echo "\tSetting prettier symlink"
rm "~/.prettierrc"
ln -s "$(cwd)/.prettierrc" "~/"


echo "Adding zsh syntax highlighting path to .zshrc"
echo "source ${(q-)PWD}/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ${ZDOTDIR:-$HOME}/.zshrc

echo "Finished!"
