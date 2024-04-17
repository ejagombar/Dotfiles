return {
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		config = function()
			require("ibl").setup({
				scope = {
					-- enabled = false,
					show_start = false,
					show_end = false,
				},
			})
			local hooks = require("ibl.hooks")
			hooks.register(hooks.type.ACTIVE, function(bufnr)
				return vim.tbl_contains(
					{ "html", "yaml", "python" },
					vim.api.nvim_get_option_value("filetype", { buf = bufnr })
				)
			end)
		end,
	},
}
