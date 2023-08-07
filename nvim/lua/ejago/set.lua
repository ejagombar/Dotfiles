vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = true

vim.opt.wrap = true

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8

vim.opt.updatetime = 50

vim.o.cursorline = true

vim.cmd([[
augroup CursorLineNrHighlight
  autocmd!
  autocmd VimEnter * highlight CursorLineNr guibg=bg guifg=#CCCCCC
  autocmd VimEnter * highlight CursorLine ctermbg=NONE ctermfg=NONE guibg=NONE guifg=NONE
augroup END
]])

vim.opt.clipboard = "unnamedplus"
