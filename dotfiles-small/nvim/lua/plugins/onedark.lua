return {
	"navarasu/onedark.nvim",
	name = "Onedark",
	opts = { style = "darker" },
	config = function(_, opts)
		require("onedark").setup(opts)
		vim.cmd("colorscheme onedark")
	end,
}

