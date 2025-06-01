return {
	"navarasu/onedark.nvim",
	name = "onedark",
	opts = {
		style = "darker",
		lualine = {
			transparent = true, -- lualine center bar transparency
		},
		colors = {

			bg0 = "#1f2329",
			bg1 = "#1f2329",
			bg2 = "#1f2329",
		},
	},

	priority = 1000,
	config = function(_, opts)
		require("onedark").setup(opts)
		vim.cmd("colorscheme onedark")
		-- vim.api.nvim_set_hl(0, "NormalFloat", { bg = "NONE" })
		-- vim.api.nvim_set_hl(0, "FloatBorder", { bg = "NONE" })
		vim.cmd([[hi TelescopeSelection guibg=#282c34]])
	end,
}
