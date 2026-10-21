### Paths & Environment Variables -----------------------

export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export LC_ALL="en_GB.UTF-8"
export LANG="en_GB.UTF-8"

export GOPATH=~/go
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PATH:/usr/local/go/bin:$GOPATH/bin:$HOME/bin:$HOME/.local/bin:$HOME/.cargo/bin"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"

# Homebrew on macOS (Apple silicon, then Intel)
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# [other machine] Specific to another machine: move these to its ~/.zshrc.local
# [other machine] export LC_ALL="en_IN.UTF-8"  # commented out: would override en_GB above
# [other machine] export LANG="en_IN.UTF-8"
export VCPKG_ROOT="$HOME/Repos/Forks/vcpkg"                          # [other machine]
export PYNT_ROOT="$HOME/.local/lib/python3.12/site-packages"         # [other machine]
export PATH="$PATH:$VCPKG_ROOT:$PYNT_ROOT:/etc/profile.d/modules.sh" # [other machine]
export PATH="$HOME/.npm-global/bin:$PATH"                            # [other machine] Pi

export TERM=xterm-256color

# machine-specific settings and secrets, kept out of this repo
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

### Zinit (Plugin Manager) ----------------------

ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [ ! -d "$ZINIT_HOME" ]; then
  mkdir -p "$(dirname "$ZINIT_HOME")"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"

### Starship prompt
zinit ice as"command" from"gh-r" \
          atclone"./starship init zsh > init.zsh; ./starship completions zsh > _starship" \
          atpull"%atclone" src"init.zsh"
zinit light starship/starship

### Zinit plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

### OMZ snippets
zinit snippet OMZP::git
zinit snippet OMZP::vi-mode
zinit snippet OMZP::command-not-found

### ZSH Settings ----------------------------------------

# vi-mode
ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT
ZVM_LAZY_KEYBINDINGS=false
VI_MODE_SET_CURSOR=true

# Highlighting
typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[path]=none
ZSH_HIGHLIGHT_STYLES[path_prefix]=none

# Completion
autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza --color=always $realpath'

# History
HISTSIZE=5000
SAVEHIST=$HISTSIZE
HISTFILE="$HOME/.zsh_history"
HIST_STAMPS="dd/mm/yyyy"
setopt appendhistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups
setopt sharehistory

### Aliases ----------------------------------------

alias sudo='sudo '

# ls (eza) - bold blue folders, grouped directories first
export EZA_COLORS="di=1;34"
alias ls='eza --group-directories-first --color=always'
alias ll='eza -l --group-directories-first --color=always'
alias la='eza -la --group-directories-first --color=always'
alias lt='eza --tree --group-directories-first --color=always'
alias q="cd ~ && clear"
alias dl='cd ~/Downloads'
alias rp='cd ~/Repos/Projects'
alias rpl='cd ~/Repos/Playground'
alias rf='cd ~/Repos/Forks'
alias rw='cd ~/Repos/Work'

alias vzrc="nvim ~/.zshrc && exec zsh -l"
alias szrc="source ~/.zshrc"

alias v='nvim'
[[ "$OSTYPE" == linux* ]] && alias open='xdg-open'  # macOS has its own open
alias lgit='lazygit'
alias ts='tmux-sessioniser'

# [other machine] Specific to another machine: move these to its ~/.zshrc.local
# [other machine] alias lg='lazygit'  # commented out: would shadow the lg CLI (~/go/bin/lg)
alias build_explorer='cd ~/Repos/Projects/WikiMapper && cmake --build build --parallel && cd build && ./WikiMapperExplorer' # [other machine]
alias build_opengl_tutorial='cd ~/Repos/Projects/OpenGLTutorial && cmake --build build && cd build && ./OpenGLTutorial'   # [other machine]

### Keybindings ------------------------------------------

bindkey -a -r ':'  # Disable vi command mode

fg-widget() {
  BUFFER="fg"
  zle accept-line
}
zle -N fg-widget
bindkey -M vicmd ^f fg-widget
bindkey -M viins ^f fg-widget

### LONGSHOT -------

# 1. The command itself
log() {
    if [ -z "$1" ]; then
        echo "Error: Missing container name."
        echo "Usage: log <container_name>"
        return 1
    fi
    # Added sudo here
    sudo docker logs -f "$1"
}

# 2. The autocomplete logic
_log_autocomplete() {
    # Added sudo here, and 2>/dev/null to prevent password prompts
    # from breaking your terminal visually if you press Tab
    local containers=($(sudo docker ps --format '{{.Names}}' 2>/dev/null))

    compadd -a containers
}

# 3. Bind the autocomplete to the command
compdef _log_autocomplete log

### Conditional Starship Fallback -------------------------------------

type starship_zle-keymap-select >/dev/null || {
  echo "Load starship"
  eval "$(starship init zsh)"
}

### Pyenv Initialization ----------------------------------

if command -v pyenv > /dev/null 2>&1; then
  eval "$(pyenv init -)"
  eval "$(pyenv virtualenv-init -)"
fi
