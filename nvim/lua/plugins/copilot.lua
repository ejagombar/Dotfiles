return {
	"github/copilot.vim",
	config = function()
		vim.keymap.set("n", "<leader>gs", vim.cmd.Git)
	end,
}

