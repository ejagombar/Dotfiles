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
