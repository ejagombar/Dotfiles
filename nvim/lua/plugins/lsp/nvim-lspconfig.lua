local config = function()
	-- require("neoconf").setup({})
	local cmp_nvim_lsp = require("cmp_nvim_lsp")
	local lspconfig = require("lspconfig")
	-- local mapkey = require("util.keymapper").mapkey

	local diagnostic_signs = { Error = "", Warn = "", Hint = "󰠠", Info = "" }

	for type, icon in pairs(diagnostic_signs) do
		local hl = "DiagnosticSign" .. type
		vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
	end

	local capabilities = cmp_nvim_lsp.default_capabilities()

	local on_attach = function(client, bufnr)
		local opts = { noremap = true, silent = true }

		opts.buffer = bufnr

		-- set keybinds

		opts.desc = "Show LSP references"
		-- keymap.set("n", "gr", "<cmd>Telescope lsp_references<CR>", opts) -- show definition, references
		-- keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts) -- show lsp definitions
		-- keymap.set("n", "gD", "Lspsaga goto_definition", opts) -- go to declaration
		-- keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts) -- show lsp implementations
		-- keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts) -- show lsp type definitions
		-- keymap.set({ "n", "v" }, "<leader>ca", "Lspsaga code_action", opts) -- see available code actions, in visual mode will apply to selection
		-- keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts) -- show  diagnostics for file
		-- keymap.set("n", "<leader>d", "Lspsaga show_cursor_diagnostics", opts) -- show diagnostics for line
		-- keymap.set("n", "[d", "Lspsaga diagnostic_jump_prev", opts) -- jump to previous diagnostic in buffer
		-- keymap.set("n", "]d", "Lspsaga diagnostic_jump_prev", opts) -- jump to next diagnostic in buffer
		-- keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts) -- mapping to restart lsp if necessary
		-- 
		local mapkey = function(keys, func, desc)
			vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
		end

		opts.desc = "Smart Rename"
		mapkey("<f2>", "Lspsaga rename", "n", opts) -- smart rename

		opts.desc = "IDK update me"
		mapkey("<leader>fd", "Lspsaga finder", "n", opts)

		opts.desc = "Show LSP references"
		mapkey("<leader>fd", "<cmd>Telescope lsp_references<CR>", "n", opts) -- show definition, references

		-- opts.desc = "Highlight all appearances of that word"
		-- mapkey("<leader>hl", "Lspsaga peek_definition", "n", opts)

		opts.desc = "Code actions"
		mapkey("<leader>ca", "Lspsaga code_action", "n", opts) -- see available code actions

		opts.desc = "Show line diagnostics"
		mapkey("gl", "Lspsaga show_line_diagnostics", "n", opts) -- show  diagnostics for line

		opts.desc = "Go to the previous diagnostic"
		mapkey("<leader>pd", "Lspsaga diagnostic_jump_prev", "n", opts) -- jump to prev diagnostic in buffer

		opts.desc = "Go to the next diagnostic"
		mapkey("<leader>nd", "Lspsaga diagnostic_jump_next", "n", opts) -- jump to next diagnostic in buffer

		opts.desc = "show documentation for what is under the cursor"
		mapkey("K", "Lspsaga hover_doc", "n", opts) -- show documentation for what is under cursor

		opts.desc = "Restart LSP"
		mapkey("<leader>rs", ":LspRestart<CR>", "n", opts) -- mapping to restart lsp if necessary

		if client.name == "pyright" then
			mapkey("<Leader>oi", "PyrightOrganizeImports", "n", opts)
		end
	end

	-- lua
	lspconfig.lua_ls.setup({
		capabilities = capabilities,
		on_attach = on_attach,
		settings = { -- custom settings for lua
			Lua = {
				-- make the language server recognize "vim" global
				diagnostics = {
					globals = { "vim" },
				},
				workspace = {
					-- make language server aware of runtime files
					library = {
						[vim.fn.expand("$VIMRUNTIME/lua")] = true,
						[vim.fn.stdpath("config") .. "/lua"] = true,
					},
				},
			},
		},
	})

	-- Go
	lspconfig.gopls.setup({
		capabilities = capabilities,
		on_attach = on_attach,
		filetypes = { "go" },
	})

	-- json
	lspconfig.jsonls.setup({
		capabilities = capabilities,
		on_attach = on_attach,
		filetypes = { "json", "jsonc" },
	})

	-- python
	lspconfig.pyright.setup({
		capabilities = capabilities,
		on_attach = on_attach,
		settings = {
			pyright = {
				disableOrganizeImports = false,
				analysis = {
					useLibraryCodeForTypes = true,
					autoSearchPaths = true,
					diagnosticMode = "workspace",
					autoImportCompletions = true,
				},
			},
		},
	})

	-- typescript
	lspconfig.tsserver.setup({
		on_attach = on_attach,
		capabilities = capabilities,
		filetypes = {
			"typescript",
			"typescriptreact",
		},
		root_dir = lspconfig.util.root_pattern("package.json", "tsconfig.json", ".git"),
	})

	-- bash
	lspconfig.bashls.setup({
		capabilities = capabilities,
		on_attach = on_attach,
		filetypes = { "sh", "aliasrc" },
	})

	-- solidity
	lspconfig.solidity.setup({
		capabilities = capabilities,
		on_attach = on_attach,
		filetypes = { "solidity" },
	})

	-- typescriptreact, javascriptreact, css, sass, scss, less, svelte, vue
	lspconfig.emmet_ls.setup({
		capabilities = capabilities,
		on_attach = on_attach,
		filetypes = {
			"css",
			"sass",
			"scss",
			"less",
			"svelte",
			"vue",
			"html",
		},
	})

	-- docker
	lspconfig.dockerls.setup({
		capabilities = capabilities,
		on_attach = on_attach,
	})

	-- -- C/C++
	-- lspconfig.clangd.setup({
	-- 	capabilities = capabilities,
	-- 	on_attach = on_attach,
	-- 	cmd = {
	-- 		"clangd",
	-- 		'--offset-encoding=utf-16 --style="{IndentWidth: 8}"',
	-- 	},
	-- 	root_dir = lspconfig.util.root_pattern(".git"),
	-- })

	local luacheck = require("efmls-configs.linters.luacheck")
	local gofumpt = require("efmls-configs.formatters.gofumpt")
	local stylua = require("efmls-configs.formatters.stylua")
	local eslint_d = require("efmls-configs.linters.eslint_d")
	local prettier_d = require("efmls-configs.formatters.prettier_d")
	local fixjson = require("efmls-configs.formatters.fixjson")
	local shellcheck = require("efmls-configs.linters.shellcheck")
	local shfmt = require("efmls-configs.formatters.shfmt")
	local hadolint = require("efmls-configs.linters.hadolint")
	local solhint = require("efmls-configs.linters.solhint")
	local cpplint = require("efmls-configs.linters.cpplint")
	local clangformat = require("efmls-configs.formatters.clang_format")

	-- configure efm server
	lspconfig.efm.setup({
		filetypes = {
			"lua",
			"json",
			"jsonc",
			"sh",
			"javascript",
			"javascriptreact",
			"typescript",
			"typescriptreact",
			"markdown",
			"docker",
			"solidity",
			"html",
			"css",
			"c",
			"cpp",
			"go",
		},
		init_options = {
			documentFormatting = true,
			documentRangeFormatting = true,
			hover = true,
			documentSymbol = true,
			codeAction = true,
			completion = true,
		},
		settings = {
			languages = {
				lua = { luacheck, stylua },
				typescript = { eslint_d, prettier_d },
				json = { eslint_d, fixjson },
				jsonc = { eslint_d, fixjson },
				sh = { shellcheck, shfmt },
				javascript = { eslint_d, prettier_d },
				javascriptreact = { eslint_d, prettier_d },
				typescriptreact = { eslint_d, prettier_d },
				markdown = { prettier_d },
				docker = { hadolint, prettier_d },
				solidity = { solhint },
				html = { prettier_d },
				css = { prettier_d },
				c = { clangformat, cpplint },
				cpp = { clangformat, cpplint },
				go = { gofumpt },
			},
		},
	})

	local lsp_fmt_group = vim.api.nvim_create_augroup("LspFormattingGroup", {})
	vim.api.nvim_create_autocmd("BufWritePost", {
		group = lsp_fmt_group,
		callback = function()
			local efm = vim.lsp.get_active_clients({ name = "efm" })

			if vim.tbl_isempty(efm) then
				return
			end

			vim.lsp.buf.format({ name = "efm" })
		end,
	})
end

return {
	"neovim/nvim-lspconfig",
	config = config,
	lazy = false,
	dependencies = {
		"windwp/nvim-autopairs",
		"williamboman/mason.nvim",
		"hrsh7th/nvim-cmp",
		"hrsh7th/cmp-buffer",
		"hrsh7th/cmp-nvim-lsp",
		"creativenull/efmls-configs-nvim",
	},
}
