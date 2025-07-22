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
vim.opt.undofile = true

vim.opt.hlsearch = true
vim.opt.incsearch = true

vim.opt.termguicolors = false

vim.opt.scrolloff = 10

vim.opt.updatetime = 50

-- vim.opt.timeoutlen = 450

vim.opt.signcolumn = "yes"

vim.o.cursorline = true

vim.opt.swapfile = false

vim.opt.clipboard = "unnamedplus"

vim.g.loaded_perl_provider = false -- disable warning in :checkhealth

vim.opt.inccommand = "split"

vim.opt.textwidth = 0

vim.filetype.add({
	extension = {
		vert = "vert",
		frag = "frag",
		geom = "geom",
		library = "library",
	},
})

vim.cmd("autocmd BufEnter * set formatoptions-=cro")
vim.cmd("autocmd BufEnter * setlocal formatoptions-=cro")

vim.cmd([[
augroup CursorLineNrHighlight
  autocmd!
  autocmd VimEnter * highlight CursorLineNr guibg=bg guifg=#CCCCCC
  autocmd VimEnter * highlight CursorLine ctermbg=NONE ctermfg=NONE guibg=NONE guifg=NONE
augroup END
]])

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	pattern = "*.library",
	callback = function()
		vim.bo.filetype = "library"
	end,
})

require("qs_lint").setup({
	cmd = "/home/ejago/Repos/Work/QS-Lint/qs_lint",
	filetypes = { "library", "module" },
	debounce_time = 300,
	use_json = true,
	auto_save = true,
})
