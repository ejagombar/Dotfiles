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

BASE_PACKAGES="tmux zsh ripgrep fzf curl zoxide"
EXTRA_PACKAGES="bat eza luarocks gh fd-find"

echo -e "${BOLD_GREEN}Installing dependencies...${RESET}"

if [[ $LATEST_FLAG -eq 1 ]]; then
    $INSTALL_CMD $BASE_PACKAGES

    curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
    sudo rm -rf /opt/nvim
    sudo tar -C /opt -xzf nvim-linux64.tar.gz

    ln -s "/usr/bin" "/opt/nvim-linux64"
else 
    $INSTALL_CMD $BASE_PACKAGES "neovim"
fi

if [[ $EXTRA_FLAG -eq 1 ]]; then
    $INSTALL_CMD $EXTRA_PACKAGES
    curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash

    mkdir -p ~/.local/bin
    ln -s /usr/bin/batcat ~/.local/bin/bat
fi

echo -e "${BOLD_GREEN}Cloning repos...${RESET}"

echo -e "${BOLD_GREEN}Installing OMZ${RESET}"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

echo -e "${BOLD_GREEN}Installing zsh autosuggestions${RESET}"
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

echo -e "${BOLD_GREEN}Installing zsh syntax highlighting${RESET}"
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

echo -e "${BOLD_GREEN}Installing Spaceship prompt${RESET}"
git clone https://github.com/spaceship-prompt/spaceship-prompt.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/spaceship-prompt --depth=1

echo -e "${BOLD_GREEN}Installing Tmux TPM${RESET}"
git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm

echo -e "${BOLD_GREEN}Setting symlinks...${RESET}"
cwd=$(pwd)

echo "Setting tmux symlink"
rm -f "$HOME/.tmux.conf"
ln -sf "$cwd/tmux/.tmux.conf" "$HOME/.tmux.conf"

echo "Setting zsh symlink"
rm -f "$HOME/.zshrc"
ln -sf "$cwd/zsh/.zshrc" "$HOME/.zshrc"

echo "Setting nvim symlink"
rm -rf "$HOME/.config/nvim"
ln -sf "$cwd/nvim" "$HOME/.config/nvim"

echo "Setting starship symlink"
rm -f "$HOME/.config/starship.toml"
ln -sf "$cwd/zsh/starship.toml" "$HOME/.config/starship.toml"

echo "Setting gitconfig symlink"
rm -f "$HOME/.gitconfig"
ln -sf "$cwd/.gitconfig" "$HOME/.gitconfig"

echo "Setting prettier symlink"
rm -f "$HOME/.prettierrc"
ln -sf "$cwd/.prettierrc" "$HOME/.prettierrc"

echo -e "${BOLD_GREEN}Adding zsh syntax highlighting path to .zshrc${RESET}"
echo "source ${(q-)PWD}/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ${ZDOTDIR:-$HOME}/.zshrc

font_name="FiraCode"
echo -e ${BOLD_GREEN}"Installing Fira Code Nerd Font${RESET}"
curl -OL "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${font_name}.zip"
echo "creating fonts folder: ${HOME}/.fonts"
mkdir -p  "$HOME/.fonts"
echo "unzip the ${font_name}.zip"
unzip "${font_name}.zip" -d "$HOME/.fonts/${font_name}/"
fc-cache -fv

echo -e "${BOLD_GREEN}Setting shell to zsh${RESET}"

chsh -s $(which zsh)
zsh

echo -e "${BOLD_GREEN}Finished!${RESET}"
