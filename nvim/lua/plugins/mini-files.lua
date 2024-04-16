return {
	"echasnovski/mini.files",

	config = function()
		require("mini.files").setup({
			mappings = {
				synchronize = "w",
			},
		})

		vim.api.nvim_create_autocmd("User", {
			pattern = "MiniFilesBufferCreate",
			callback = function(args)
				local buf_id = args.data.buf_id
				-- Tweak left-hand side of mapping to your liking
				vim.keymap.set("n", "-", require("mini.files").close, { buffer = buf_id })
				-- vim.keymap.set("n", "o", gio_open, { buffer = buf_id })
			end,
		})
	end,

	lazy = false,
}
