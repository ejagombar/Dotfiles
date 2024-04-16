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
-- vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = true
vim.opt.incsearch = true

vim.opt.termguicolors = false

vim.opt.scrolloff = 10

vim.opt.updatetime = 50

vim.opt.timeoutlen = 300

vim.opt.signcolumn = "yes"

vim.o.cursorline = true

vim.opt.swapfile = false

vim.opt.clipboard = "unnamedplus"

vim.g.loaded_perl_provider = false -- disable warning in :checkhealth

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Preview substitutions live, as you type!
vim.opt.inccommand = "split"

-- vim.cmd([[
--   augroup AutoSaveReadGroup
--     autocmd!
--     autocmd TextChanged,TextChangedI * :lua AutoSaveRead()
--   augroup END
-- ]])
--
-- -- Function to automatically save and read the file
-- function AutoSaveRead()
-- 	vim.cmd("silent! write")
-- 	vim.cmd("checktime")
-- end

-- Autosave
-- vim.api.nvim_set_keymap('i', '<Esc>', '<Esc>:update<CR>', { noremap = true, silent = true })

vim.cmd([[
augroup CursorLineNrHighlight
  autocmd!
  autocmd VimEnter * highlight CursorLineNr guibg=bg guifg=#CCCCCC
  autocmd VimEnter * highlight CursorLine ctermbg=NONE ctermfg=NONE guibg=NONE guifg=NONE
augroup END
]])
