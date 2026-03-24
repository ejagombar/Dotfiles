return {
	"navarasu/onedark.nvim",
	name = "Onedark",
	opts = { style = "darker" },
	init = function()
		vim.cmd.colorscheme("onedark")
		
		-- You can configure highlights by doing something like:
		vim.cmd.hi("Comment gui=none")
	end,
}

