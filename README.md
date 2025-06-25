# Dotfiles
#### My configurations for: `Neovim` `Tmux` `Zsh`

![image](https://github.com/user-attachments/assets/c0ee1f3e-c4dd-4929-81e0-e6ebbf8710b3)

## Installation instructions

```
curl -sL dots.eagombar.uk | bash
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


# Dotfiles - Small
Version of dotfiles with a smaller footprint. Only using very popular extensions.

## Dependencies

- `neovim`
    - `lazy.nvim`
    - `Comment.nvim`
    - `gitsigns.nvim`
    - `nvim-web-devicons`
    - `harpoon`
    - `lualine.nvim`
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
    - `tmux-resurrect`
    - `tmux.nvim`
