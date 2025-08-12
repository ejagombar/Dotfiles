vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

vim.keymap.set({ "n", "v" }, "<Leader>e", "%")

vim.keymap.set("n", "cp", "+y")
vim.keymap.set("n", "cv", "+p")
vim.keymap.set("x", "<leader>p", [["_dP]]) -- Replace the current selected item with the string in the copy buffer

-- Dont put deleted items into buffer when using x
vim.keymap.set("n", "x", '"_x')
vim.keymap.set("v", "x", '"_x')

-- next greatest remap ever : asbjornHaland
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]])

vim.keymap.set("n", "q:", "<Nop>", { noremap = true, silent = true })

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("n", "<leader>rp", ":! ./runcommand")

vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })

-- Diagnostic keymaps
vim.keymap.set("n", "[d", function()
	vim.diagnostic.jump({ forward = false })
end)

vim.keymap.set("n", "]d", function()
	vim.diagnostic.jump({ forward = true })
end)

vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float) -- <leader>ca to accept code actions
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist)

require("p4signs").setup({
	auto_update = true,
	update_debounce = 200,
	use_mock = true, -- Set to false when you have p4 installed
})

-- Custom characters and colors
require("p4signs").setup({
	signs = {
		add = { text = "│", hl = "P4SignsAdd" },
		change = { text = "~", hl = "P4SignsChange" },
		delete = { text = "_", hl = "P4SignsDelete" },
	},
	highlights = {
		add = { fg = "#00ff00", bold = true },
		change = { fg = "#ffff00", bold = false },
		delete = { fg = "#ff0000", bold = true, italic = true },
	},
	update_debounce = 500, -- Slower updates
})

require("p4signs").setup({
	highlights = {
		add = { fg = "#587c0c", bg = "NONE", bold = true, ctermfg = 2 },
		change = { fg = "#0c7d9d", bg = "NONE", bold = true, ctermfg = 4 },
		delete = { fg = "#94151b", bg = "NONE", bold = true, ctermfg = 1 },
	},
})
