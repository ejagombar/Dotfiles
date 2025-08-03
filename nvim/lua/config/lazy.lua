local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end

vim.opt.rtp:prepend(lazypath)

local plugins = {
	{
		"ejagombar/onedark.nvim",
		name = "onedark",
		priority = 1000,
		opts = {
			style = "darker",

			colors = {

				-- bg0 = "#1f2329",
				-- bg1 = "#1f2329",
				-- bg2 = "#1f2329",
			},
		},
		init = function()
			require("onedark").load()
		end,
	},

	{ import = "plugins" },
	{ import = "plugins.lsp" },
}

local opts = {
	defaults = {
		lazy = false,
	},
	install = {
		colorscheme = { "onedark" },
	},
	rtp = {
		disabled_plugins = {
			"gzip",
			"matchit",
			"matchparen",
			"netrw",
			"netrwPlugin",
			"tarPlugin",
			"tohtml",
			"tutor",
			"zipPlugin",
		},
	},
	change_detection = {
		notify = false,
	},
}

require("lazy").setup(plugins, opts)
