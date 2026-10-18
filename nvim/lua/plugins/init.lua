-- Config for plugins under 5 lines long
return {

	{
		"numToStr/Comment.nvim",
		opts = {},
		lazy = false,
	},

	{
		"tpope/vim-fugitive",
		config = function()
			vim.keymap.set("n", "<leader>gs", vim.cmd.Git)
		end,
	},

	{
		"f-person/git-blame.nvim",
		event = "VeryLazy",
		opts = { enabled = false },
		keys = {
			{ "<leader>gB", "<cmd>GitBlameToggle<cr>", desc = "Toggle git blame" },
		},
	},

	{
		"lewis6991/gitsigns.nvim",
		config = true,
		lazy = false,
	},

	{
		"windwp/nvim-ts-autotag",
		config = true,
		lazy = false,
	},

	{
		"folke/todo-comments.nvim",
		event = "VimEnter",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = { signs = false },
	},

	{
		"mbbill/undotree",
		config = function()
			vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)
		end,
	},

	{
		"nvim-tree/nvim-web-devicons",
		config = true,
		opts = {
			default = true,
		},
	},
}
