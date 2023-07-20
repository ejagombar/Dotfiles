# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin

ZSH_TMUX_AUTOSTART=true 

# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="spaceship"

# PROMPT
SPACESHIP_PROMPT_SYMBOL="➜"
SPACESHIP_PROMPT_ADD_NEWLINE=false
SPACESHIP_PROMPT_SEPARATE_LINE=true
SPACESHIP_PROMPT_ASYNC=false
SPACESHIP_ASYNC_SHOW_COUNT=false

#enable vim commands
bindkey -v
export KEYTIMEOUT=1
export VI_MODE_SET_CURSOR=true

# disable zsh vim command mode
bindkey -a -r ':'

# Disable underlining of paths
(( ${+ZSH_HIGHLIGHT_STYLES} )) || typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[path]=none
ZSH_HIGHLIGHT_STYLES[path_prefix]=none

# just remind me to update when it's time
zstyle ':omz:update' mode reminder  

# stamp shown in the history command output.
HIST_STAMPS="dd/mm/yyyy"

# Add wisely, as too many plugins slow down shell startup.
plugins=(
	git
	zsh-autosuggestions
    vi-mode
    tmux
)

source $ZSH/oh-my-zsh.sh

# http://askubuntu.com/questions/22037/aliases-not-available-when-using-sudo
alias sudo='sudo '
alias q="~ && clear"
alias dl='cd ~/Downloads'
alias rp='cd ~/Projects/Repos'
alias vzrc="nvim ~/.zshrc"
alias szrc="source ~/.zshrc"
alias vim="nvim"
alias cat="bat"

# For a full list of active aliases, run `alias`.

source ~/Projects/Forks/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
