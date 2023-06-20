vim.g.mapleader = " "

vim.keymap.set("n","<leader>pv", vim.cmd.Ex)

vim.keymap.set("i", "jk", "<Esc>")
vim.keymap.set("i", "kj", "<Esc>")
vim.keymap.set("v", "kj", "<Esc>")
vim.keymap.set("v", "jk", "<Esc>")

vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

vim.keymap.set("n", "<Leader>h", "^")
vim.keymap.set("n", "<Leader>l", "g_")

vim.keymap.set("n", "<Leader>e", "%")
vim.keymap.set("v", "<Leader>e", "%")

vim.keymap.set("n", "cp", "+y")
vim.keymap.set("n", "cv", "+p")
































































































