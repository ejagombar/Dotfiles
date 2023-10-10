# Path to your oh-my-zsh installation. export ZSH="$HOME/.oh-my-zsh"
export ZSH="$HOME/.oh-my-zsh"
export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin:$GOPATH/bin:/etc/profile.d/modules.sh

ZSH_TMUX_AUTOSTART=false

# disable zsh vim command mode
bindkey -a -r ':'

# just remind me to update when it's time
zstyle ':omz:update' mode reminder  

# stamp shown in the history command output.
HIST_STAMPS="dd/mm/yyyy"

# Add wisely, as too many plugins slow down shell startup.
plugins=(
	git
	zsh-autosuggestions
    zsh-vi-mode
    tmux
)

function zvm_config() {
  ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT
}

# Remove underline from paths
(( ${+ZSH_HIGHLIGHT_STYLES} )) || typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[path]=none
ZSH_HIGHLIGHT_STYLES[path_prefix]=none

# Source plugins. Must be done after plugins are added
source $ZSH/oh-my-zsh.sh
source ~/Repos/Forks/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Source stuff for OpenMPI
if [[ "$PWD" == *"Module-4115"* ]]; then
    module load mpi/openmpi-x86_64
fi

# http://askubuntu.com/questions/22037/aliases-not-available-when-using-sudo
alias sudo='sudo '
alias q="~ && clear"
alias dl='cd ~/Downloads'
alias rp='cd ~/Repos/Projects'
alias rpl='cd ~/Repos/Playground'
alias rf='cd ~/Repos/Forks'
alias rw='cd ~/Repos/Work'
alias vzrc="nvim ~/.zshrc"
alias szrc="source ~/.zshrc"
alias v='__v() { if [ $# -eq 0 ]; then nvim .; else nvim "$1"; fi; }; __v'
alias cat="bat"
alias spotlog="nvim ~/Documents/SpotifyNotes.txt"

# For a full list of active aliases, run `alias`.

eval "$(starship init zsh)"
