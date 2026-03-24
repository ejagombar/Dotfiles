return {
	"stevearc/oil.nvim",
	config = function()
		require("oil").setup({
			columns = {
				"icon",
				-- "permissions",
				-- "size",
				-- "mtime",
			},
			view_options = {
				-- Show files and directories that start with "."
				show_hidden = true,
			},
		})
		vim.keymap.set("n", "<leader>pe", "<CMD>Oil --float<CR>", { desc = "Open parent directory" })
	end,
}

-- local config = function()
-- 	local oil = require("oil")

-- 	oil.setup({
-- 		use_default_keymaps = true,
-- 		view_options = {
-- 			show_hidden = false,
-- 			is_hidden_file = function(name, bufnr)
-- 				return vim.startswith(name, ".")
-- 			end,
-- 			is_always_hidden = function(name, bufnr)
-- 				return false
-- 			end,
-- 			sort = {
-- 				{ "type", "asc" },
-- 				{ "name", "asc" },
-- 			},j
-- 		},
-- 		float = {
-- 			padding = 1,
-- 			max_width = 60,
-- 			max_height = 16,
-- 			border = "rounded",
-- 			win_options = {
-- 				winblend = 0,
-- 			},
-- 			override = function(conf)
-- 				return conf
-- 			end,
-- 		},

-- 		preview = {
-- 			max_width = 0.9,
-- 			min_width = { 40, 0.4 },
-- 			width = nil,
-- 			max_height = 0.9,
-- 			min_height = { 5, 0.1 },
-- 			height = nil,
-- 			border = "rounded",
-- 			win_options = {
-- 				winblend = 0,
-- 			},
-- 		},

-- 		keymaps = {
-- 			["g?"] = "actions.show_help",
-- 			["<CR>"] = "actions.select",
-- 			["<C-s>"] = "actions.select_vsplit",
-- 			["<C-h>"] = "actions.select_split",
-- 			["<C-t>"] = "actions.select_tab",
-- 			["<C-p>"] = "actions.preview",
-- 			["<C-c>"] = "actions.close",
-- 			["<C-l>"] = "actions.refresh",
-- 			["-"] = "actions.parent",
-- 			["_"] = "actions.open_cwd",
-- 			["`"] = "actions.cd",
-- 			["~"] = "actions.tcd",
-- 			["gs"] = "actions.change_sort",
-- 			["g."] = "actions.toggle_hidden",
-- 		},
-- 	})

-- 	vim.keymap.set("n", "<leader>pp", "Oil --float")
-- end

-- return {
-- 	"stevearc/oil.nvim",
-- 	name = "oil",

-- 	dependencies = {
-- 		"nvim-tree/nvim-web-devicons",
-- 	},
-- 	config = config,
-- }
