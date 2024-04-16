local config = function()
	local telescope = require("telescope")
	local builtin = require("telescope.builtin")
	local fb_actions = require("telescope").extensions.file_browser.actions

	pcall(telescope.load_extension, "fzf")
	pcall(telescope.load_extension("file_browser"))

	telescope.setup({
		defaults = {
			file_ignore_patterns = {
				"node_modules",
				"build",
				".git/",
				"venv",
				".venv",
			},
		},
		extensions = {
			file_browser = {
				respect_gitignore = false,
				hidden = true,
				grouped = true,
				initial_mode = "normal",
				-- disables netrw and use telescope-file-browser in its place
				hijack_netrw = true,
				mappings = {
					["n"] = {
						["%"] = fb_actions.create,
						["-"] = fb_actions.goto_parent_dir,
					},
				},
			},
		},
	})

	-- vim.keymap.set("n", "<leader>pf", function()
	-- 	builtin.find_files({
	-- 		no_ignore = false,
	-- 		hidden = true,
	-- 	})
	-- end)
	--
	-- vim.keymap.set("n", "<leader>ps", function()
	-- 	builtin.live_grep()
	-- end)
	--
	-- vim.keymap.set("n", "<leader>pg", function()
	-- 	builtin.git_files()
	-- end)
	--
	-- vim.keymap.set("n", "<leader>pb", function()
	-- 	builtin.buffers()
	-- end)
	--
	-- vim.keymap.set("n", "gd", function()
	-- 	builtin.lsp_definitions()
	-- end)
	--
	-- vim.keymap.set("n", "gr", function()
	-- 	builtin.lsp_references()
	-- end)

	vim.keymap.set("n", "<leader>oh", builtin.help_tags)
	vim.keymap.set("n", "<leader>of", builtin.find_files)
	vim.keymap.set("n", "<leader>ow", builtin.grep_string)
	vim.keymap.set("n", "<leader>os", builtin.live_grep)
	vim.keymap.set("n", "<leader>od", builtin.diagnostics)
	vim.keymap.set("n", "<leader>or", builtin.resume)
	vim.keymap.set("n", "<leader><leader>", builtin.buffers)

	vim.keymap.set("n", "<leader>ov", function()
		telescope.extensions.file_browser.file_browser({
			path = "%:p:h",
			cwd = vim.fn.expand("%:p:h"),
			-- respect_gitignore = false,
			hidden = true,
			grouped = true,
			initial_mode = "normal",
			-- layout_config = { height = 40, width = 160 }
			--[[  ]]
		})
	end)

	vim.keymap.set("n", "<leader>vh", function()
		builtin.help_tags()
	end)
end

return {
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.x",
		lazy = false,
		config = config,
		dependencies = {
			"nvim-lua/plenary.nvim",
			{
				"nvim-telescope/telescope-fzf-native.nvim",
				build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build",
			},
			{ "nvim-telescope/telescope-ui-select.nvim" },

			{ "nvim-tree/nvim-web-devicons", enabled = true },
		},
	},
	{
		"nvim-telescope/telescope-file-browser.nvim",
		dependencies = {
			"nvim-telescope/telescope.nvim",
			"nvim-lua/plenary.nvim",
		},
	},
}
