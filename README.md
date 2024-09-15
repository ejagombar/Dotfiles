# Dotfiles
#### My configurations for: `Neovim` `Tmux` `Zsh`


## Installation instructions

```
git clone https://github.com/ejagombar/Dotfiles && cd Dotfiles
chmod +x ./install.sh
./install.sh
```

`./install.sh` flags:
- `--extra` Installs extra packages: `bat` `eza` `luarocks` `gh` `fd-find`
- `--latest` Installs neovim from github latest archive, as opposed to using package manager

## Dependencies

- `neovim`
    - `lazy.nvim`
    - `Comment.nvim`
    - `vim-fugitive`
    - `gitsigns.nvim`
    - `nvim-ts-autotag`
    - `todo-comments.nvim`
    - `undotree`
    - `nvim-web-devicons`
    - `conform.nvim`
    - `nvim-dap`
        - `nvim-dap-ui`
        - `nvim-nio`
        - `mason-nvim-dap.nvim`
        - `nvim-dap-go`
    - `harpoon`
    - `indent-blankline.nvim`
    - `lualine.nvim`
    - `markdown-preview.nvim`
    - `mini.files`
    - `nvim-treesitter`
    - `onedark.nvim`
    - `telescope.nvim`
        - `plenary.nvim`
        - `telescope-fzf-native.nvim`
        - `telescope-ui-select.nvim`
    - `tmux.nvim`
    - `trouble.nvim`
- `tmux`
    - `tpm`
    - `tmux-onedark-theme`
    - `tmux-resurrect`
    - `tmux.nvim`
- `zsh`
    - `zinit`
        - `zsh-syntax-highlighting`
        - `zsh-completions`
        - `zsh-autosuggestions`
        - `fzf-tab`
        - `OMZP::git`
        - `OMZP::vi-mode`
        - `OMZP::command-not-found`
    - `starship`
- `ripgrep`
- `fzf`
- `curl`
- `zoxide`
- `git`
- `bat`
- `eza`
- `luarocks`
- `gh`
- `fd-find`
