return {
	"selimacerbas/mdkite.nvim",
	dependencies = { "selimacerbas/kitehost.nvim" },
	cmd = "MdKite",
	keys = {
		{ "<leader>md", "<cmd>MdKite toggle<cr>", desc = "Toggle markdown preview" },
	},

	config = function()
		require("mdkite").setup({
			instance_mode = "takeover",
			port = 0,
			open_browser = true,
			debounce_ms = 300,
			custom_css = vim.fn.stdpath("config") .. "/assets/github-markdown.css",
		})
	end,
}
