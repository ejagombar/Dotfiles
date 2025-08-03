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

-- vim.opt.termguicolors = false
vim.g.have_nerd_font = false

vim.opt.scrolloff = 10

vim.opt.updatetime = 50

vim.opt.timeoutlen = 450

vim.opt.signcolumn = "yes"

vim.o.cursorline = true

vim.o.showmode = false

vim.opt.swapfile = false

--  Schedule the setting after `UiEnter` because it can increase startup-time.
vim.schedule(function()
	vim.o.clipboard = "unnamedplus"
end)

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

vim.api.nvim_create_autocmd("BufEnter", {
	callback = function()
		vim.opt_local.formatoptions:remove({ "c", "r", "o" })
		vim.api.nvim_set_hl(0, "CursorLineNr", { bg = "bg", fg = "#CCCCCC" })
		vim.api.nvim_set_hl(0, "CursorLine", { ctermbg = "NONE", ctermfg = "NONE", bg = "NONE", fg = "NONE" })
	end,
})

local function check_and_clean_buffer(buf)
	if not vim.api.nvim_buf_is_loaded(buf) or not vim.bo[buf].modified then
		return
	end

	if vim.api.nvim_buf_get_name(buf) ~= "" then
		return
	end

	local non_empty_lines = 0
	for _, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
		if line:match("%S") then
			non_empty_lines = non_empty_lines + 1
		end
	end

	if non_empty_lines > 2 then
		return
	end

	vim.bo[buf].modified = false
end

vim.api.nvim_create_autocmd("QuitPre", {
	callback = function()
		for _, buf in ipairs(vim.api.nvim_list_bufs()) do
			check_and_clean_buffer(buf)
		end
	end,
})

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	pattern = "*.library",
	callback = function()
		vim.bo.filetype = "library"
	end,
})

-- require("qs_lint").setup({
-- 	cmd = "/home/ejago/Repos/Work/QS-Lint/qs_lint",
-- 	filetypes = { "library", "module" },
-- 	debounce_time = 300,
-- 	use_json = true,
-- 	auto_save = true,
-- })
