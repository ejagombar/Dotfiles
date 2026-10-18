return { -- Highlight, edit, and navigate code
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	build = ":TSUpdate",
	lazy = false,

	config = function()
		vim.treesitter.language.register("glsl", { "vert", "frag", "geom" })

		local ts = require("nvim-treesitter")

		local available = {}
		for _, lang in ipairs(ts.get_available()) do
			available[lang] = true
		end

		vim.api.nvim_create_autocmd("FileType", {
			group = vim.api.nvim_create_augroup("treesitter-start", { clear = true }),
			callback = function(args)
				local buf = args.buf
				local lang = vim.treesitter.language.get_lang(vim.bo[buf].filetype)
				if not lang then
					return
				end

				local function start()
					if not vim.api.nvim_buf_is_valid(buf) then
						return
					end
					if not pcall(vim.treesitter.start, buf, lang) then
						return
					end
					if lang == "ruby" then
						vim.bo[buf].syntax = "ON"
					else
						vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
					end
				end

				if vim.list_contains(ts.get_installed(), lang) then
					start()
				elseif available[lang] then
					ts.install(lang):await(function()
						vim.schedule(start)
					end)
				end
			end,
		})

		-- UNCHANGED
		require("nvim-ts-autotag").setup({
			opts = {
				enable_close = true,
				enable_rename = true,
				enable_close_on_slash = false,
			},
			per_filetype = {
				["html"] = {
					enable_close = false,
				},
			},
		})
	end,
}
