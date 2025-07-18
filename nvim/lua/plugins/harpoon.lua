return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		local harpoon = require("harpoon")

		harpoon:setup({
			settings = {
				save_on_toggle = true,
				sync_on_ui_close = true,
			},
		})

		local toggle_opts = {
			border = "rounded",
			title_pos = "center",
		}

		vim.keymap.set("n", "<leader>a", function()
			harpoon:list():add()
		end)
		vim.keymap.set("n", "<C-e>", function()
			harpoon.ui:toggle_quick_menu(harpoon:list(), toggle_opts)
		end)
		vim.keymap.set("n", "<leader>h", function()
			harpoon:list():select(1)
		end)
		vim.keymap.set("n", "<leader>j", function()
			harpoon:list():select(2)
		end)
		vim.keymap.set("n", "<leader>k", function()
			harpoon:list():select(3)
		end)
		vim.keymap.set("n", "<leader>l", function()
			harpoon:list():select(4)
		end)
		vim.keymap.set("n", "<C-n>", function()
			harpoon:list():prev()
		end)
		vim.keymap.set("n", "<C-p>", function()
			harpoon:list():next()
		end)
	end,
}
