# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

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
SPACESHIP_PROMPT_ASYNC=true
SPACESHIP_ASYNC_SHOW_COUNT=true

#enable vim commands
bindkey -v
export KEYTIMEOUT=1
export VI_MODE_SET_CURSOR=true
# disable zsh vim command mode
bindkey -a -r ':'
# CASE_SENSITIVE="true"
# HYPHEN_INSENSITIVE="true"
(( ${+ZSH_HIGHLIGHT_STYLES} )) || typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[path]=none
ZSH_HIGHLIGHT_STYLES[path_prefix]=none

# Enable aliases to be sudo’ed
#   http://askubuntu.com/questions/22037/aliases-not-available-when-using-sudo
alias sudo='sudo '

# Go to the /home/$USER (~) directory and clears window of your terminal
alias q="~ && clear"

alias dl='cd ~/Downloads'
alias rp='cd ~/Projects/Repos'

alias vzrc="nvim ~/.zshrc"
alias szrc="source ~/.zshrc"

alias vim="nvim"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
HIST_STAMPS="dd/mm/yyyy"

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
	git
	zsh-autosuggestions
    vi-mode
    tmux
)

source $ZSH/oh-my-zsh.sh

# alias ls="exa"
alias cat="bat"

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# For a full list of active aliases, run `alias`.

source ~/Projects/Forks/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
