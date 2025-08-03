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
		"navarasu/onedark.nvim",
		name = "onedark",
		priority = 1000,
		opts = {
			style = "darker",

			colors = {
				bg0 = "#1e2127",
			},

			highlights = {
				FloatBorder = { fg = "#56b6c2", bg = "#1e2127" },
				NormalFloat = { fg = "#abb2bf", bg = "#1e2127" },
				MiniFilesNormal = { bg = "#1e2127" },
				MiniFilesBorder = { fg = "#56b6c2", bg = "#1e2127" },
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

	ui = {
		border = "single",
	},
}

require("lazy").setup(plugins, opts)
