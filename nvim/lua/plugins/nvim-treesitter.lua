local config = function()
	require("nvim-treesitter.configs").setup({
		build = ":TSUpdate",
		indent = {
			enable = true,
		},
		autotag = {
			enable = true,
		},
		event = {
			"BufReadPre",
			"BufNewFile",
		},

		ensure_installed = {
			"cpp",
			"go",
			"json",
			"python",
			"bash",
			"dockerfile",
			"yaml",
			"c",
			"lua",
			"vim",
			"vimdoc",
			"query",
			"css",
			"html",
			"typescript",
			"javascript",
			"markdown",
			"markdown_inline",
			"gitignore",
		},

		auto_install = true,

		highlight = {
			enable = true,
			additional_vim_regex_highlighting = { "markdown" },
		},
	})
end

return {
	"nvim-treesitter/nvim-treesitter",
	lazy = false,
	config = config,
}
