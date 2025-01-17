return {
	"echasnovski/mini.files",

	config = function()
		require("mini.files").setup({
			mappings = {
				synchronize = "w",
			},
		})

		vim.keymap.set("n", "<leader>ov", function()
			local current_file = vim.api.nvim_buf_get_name(0)
			require("mini.files").open(current_file, false)
		end)

		vim.api.nvim_create_autocmd("User", {
			pattern = "MiniFilesBufferCreate",
			callback = function(args)
				local buf_id = args.data.buf_id
				-- Tweak left-hand side of mapping to your liking
				vim.keymap.set("n", "q", require("mini.files").close, { buffer = buf_id })
				-- vim.keymap.set("n", "o", gio_open, { buffer = buf_id })
			end,
		})
	end,

	lazy = false,
}
