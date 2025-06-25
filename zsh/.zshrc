### Paths & Environment Variables -----------------------

export VCPKG_ROOT="$HOME/Repos/Forks/vcpkg"
export PYNT_ROOT="$HOME/.local/lib/python3.12/site-packages"
export PYENV_ROOT="$HOME/.pyenv"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export LC_ALL="en_IN.UTF-8"
export LANG="en_IN.UTF-8"

export PATH="$PATH:/usr/local/go/bin:$HOME/go/bin:$GOPATH/bin:/etc/profile.d/modules.sh"
export PATH="$PATH:$HOME/.local/bin:$VCPKG_ROOT:$PYNT_ROOT:$HOME/.cargo/bin:$HOME/bin"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"

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
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

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
alias q="cd ~ && clear"
alias dl='cd ~/Downloads'
alias rp='cd ~/Repos/Projects'
alias rpl='cd ~/Repos/Playground'
alias rf='cd ~/Repos/Forks'
alias rw='cd ~/Repos/Work'

alias vzrc="nvim ~/.zshrc"
alias szrc="source ~/.zshrc"
alias v='nvim'
alias ls='exa'
alias open='xdg-open'
alias lg='lazygit'

alias build_explorer='cd ~/Repos/Projects/WikiMapper && cmake --build build --parallel && cd build && ./WikiMapperExplorer'
alias build_opengl_tutorial='cd ~/Repos/Projects/OpenGLTutorial && cmake --build build && cd build && ./OpenGLTutorial'

### Keybindings ------------------------------------------

bindkey -s ^f "tmux-sessioniser\n"
bindkey -a -r ':'  # Disable vi command mode

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

### Zoxide -----------------------------------

eval "$(zoxide init zsh)"
