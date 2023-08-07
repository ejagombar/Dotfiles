# Path to your oh-my-zsh installation. export ZSH="$HOME/.oh-my-zsh"
export ZSH="$HOME/.oh-my-zsh"
export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin:$GOPATH/bin

ZSH_TMUX_AUTOSTART=true 

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

source $ZSH/oh-my-zsh.sh
source ~/Projects/Forks/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# http://askubuntu.com/questions/22037/aliases-not-available-when-using-sudo
alias sudo='sudo '
alias q="~ && clear"
alias dl='cd ~/Downloads'
alias pr='cd ~/Projects/Repos'
alias pp='cd ~/Projects/Playground'
alias pf='cd ~/Projects/Forks'
alias vzrc="nvim ~/.zshrc"
alias szrc="source ~/.zshrc"
alias v='__v() { if [ $# -eq 0 ]; then nvim .; else nvim "$1"; fi; }; __v'
alias cat="bat"
alias spotlog="nvim ~/Documents/SpotifyNotes.txt"

# For a full list of active aliases, run `alias`.

eval "$(starship init zsh)"
