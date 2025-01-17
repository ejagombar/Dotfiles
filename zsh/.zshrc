# Path Stuff
export VCPKG_ROOT=/home/ejago/Repos/Forks/vcpkg
export PYNT_ROOT=/home/ejago/.local/lib/python3.12/site-packages
export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin:$GOPATH/bin:/etc/profile.d/modules.sh:/home/ejago/.local/bin:$VCPKG_ROOT:$PYNT_ROOT

export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"

export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Install Zinit if not installed
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

source "${ZINIT_HOME}/zinit.zsh"

zinit ice as"command" from"gh-r" \
          atclone"./starship init zsh > init.zsh; ./starship completions zsh > _starship" \
          atpull"%atclone" src"init.zsh"
zinit light starship/starship

# Add zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Add OMZ snippets
zinit snippet OMZP::git
zinit snippet OMZP::vi-mode
zinit snippet OMZP::command-not-found

ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT
ZVM_LAZY_KEYBINDINGS=false
VI_MODE_SET_CURSOR=true

# Remove underline from paths
(( ${+ZSH_HIGHLIGHT_STYLES} )) || typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[path]=none
ZSH_HIGHLIGHT_STYLES[path_prefix]=none

# Load completions
autoload -Uz compinit && compinit

# stamp shown in the history command output.
HIST_STAMPS="dd/mm/yyyy"

# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
# setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# Aliases
alias sudo='sudo '
alias q="~ && clear"
alias dl='cd ~/Downloads'
alias rp='cd ~/Repos/Projects'
alias rpl='cd ~/Repos/Playground'
alias rf='cd ~/Repos/Forks'
alias rw='cd ~/Repos/Work'
alias vzrc="nvim ~/.zshrc"
alias szrc="source ~/.zshrc"
alias v='nvim'
alias cd='z'
alias lg='lazygit'
alias cat="bat"
alias build_explorer='cd ~/Repos/Projects/WikiMapper/explorer && cmake --build build && cd ./build && ./WikiMapperExplorer'
alias build_opengl_tutorial='cd ~/Repos/Projects/OpenGLTutorial && cmake --build build && cd ./build && ./OpenGLTutorial'
bindkey -s "^F" '^Qfg^M'
bindkey -a -r ':' #Disable vi command mode

# Remove bindings from esc ^[ so that command mode can be entered instantly
# bindkey -M vicmd '^[' undefined-key
# bindkey -r "^[,"
# bindkey -r "^[/"
# bindkey -r "^[OA"
# bindkey -r "^[OB"
# bindkey -r "^[OC"
# bindkey -r "^[OD"
# bindkey -r "^[[200~"
# bindkey -r "^[[A"
# bindkey -r "^[[B"
# bindkey -r "^[[C"
# bindkey -r "^[[D"
# bindkey -r "^[~"

type starship_zle-keymap-select >/dev/null || \
{
    echo "Load starship"
    eval "$(starship init zsh)"
}

# Check if pyenv is installed before running its initialization commands
if command -v pyenv > /dev/null 2>&1; then
    eval "$(pyenv init -)"
    eval "$(pyenv virtualenv-init -)"
fi

eval "$(zoxide init zsh)"
