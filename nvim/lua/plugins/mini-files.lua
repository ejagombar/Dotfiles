return {
	"echasnovski/mini.files",
	lazy = false,
	config = function()
		local minifiles = require("mini.files")

		minifiles.setup({
			mappings = {
				synchronize = "w",
			},
			windows = {
				preview = true,
				width_focus = 30,
				width_preview = 30,
			},
		})

		vim.keymap.set("n", "<leader>ov", function()
			if pcall(function()
				require("mini.files").open(vim.api.nvim_buf_get_name(0))
			end) == false then
				require("mini.files").open(MiniFiles.get_latest_path())
			end
		end)

		vim.api.nvim_create_autocmd("User", {
			pattern = "MiniFilesBufferCreate",
			callback = function(args)
				vim.keymap.set("n", "q", minifiles.close, { buffer = args.data.buf_id })
			end,
		})

		vim.api.nvim_create_autocmd("User", {
			pattern = "MiniFilesBufferCreate", -- fires right after the float is made
			callback = function(args)
				local win = args.data.win_id
				-- window-local override: map its FloatBorder → NormalFloat
				vim.api.nvim_set_option_value(
					"winhighlight",
					"Normal:NormalFloat,FloatBorder:NormalFloat",
					{ win = win }
				)
			end,
			desc = "Make mini.files border bg match NormalFloat",
		})
	end,
}
