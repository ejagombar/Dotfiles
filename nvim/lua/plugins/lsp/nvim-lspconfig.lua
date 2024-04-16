-- local config = function()
-- 	-- require("neoconf").setup({})
-- 	local cmp_nvim_lsp = require("cmp_nvim_lsp")
-- 	local lspconfig = require("lspconfig")
-- 	-- local mapkey = require("util.keymapper").mapkey
--
-- 	local diagnostic_signs = { Error = "", Warn = "", Hint = "󰠠", Info = "" }
--
-- 	for type, icon in pairs(diagnostic_signs) do
-- 		local hl = "DiagnosticSign" .. type
-- 		vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
-- 	end
--
-- 	local capabilities = cmp_nvim_lsp.default_capabilities()
--
-- 	local on_attach = function(client, bufnr)
-- 		local opts = { noremap = true, silent = true }
--
-- 		opts.buffer = bufnr
--
-- 		-- set keybinds
--
-- 		opts.desc = "Show LSP references"
-- 		-- keymap.set("n", "gr", "<cmd>Telescope lsp_references<CR>", opts) -- show definition, references
-- 		-- keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts) -- show lsp definitions
-- 		-- keymap.set("n", "gD", "Lspsaga goto_definition", opts) -- go to declaration
-- 		-- keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts) -- show lsp implementations
-- 		-- keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts) -- show lsp type definitions
-- 		-- keymap.set({ "n", "v" }, "<leader>ca", "Lspsaga code_action", opts) -- see available code actions, in visual mode will apply to selection
-- 		-- keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts) -- show  diagnostics for file
-- 		-- keymap.set("n", "<leader>d", "Lspsaga show_cursor_diagnostics", opts) -- show diagnostics for line
-- 		-- keymap.set("n", "[d", "Lspsaga diagnostic_jump_prev", opts) -- jump to previous diagnostic in buffer
-- 		-- keymap.set("n", "]d", "Lspsaga diagnostic_jump_prev", opts) -- jump to next diagnostic in buffer
-- 		-- keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts) -- mapping to restart lsp if necessary
-- 		-- 
-- 		local mapkey = function(keys, func, desc)
-- 			vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
-- 		end
--
-- 		opts.desc = "Smart Rename"
-- 		mapkey("<f2>", "Lspsaga rename", "n", opts) -- smart rename
--
-- 		opts.desc = "IDK update me"
-- 		mapkey("<leader>fd", "Lspsaga finder", "n", opts)
--
-- 		opts.desc = "Show LSP references"
-- 		mapkey("<leader>fd", "<cmd>Telescope lsp_references<CR>", "n", opts) -- show definition, references
--
-- 		-- opts.desc = "Highlight all appearances of that word"
-- 		-- mapkey("<leader>hl", "Lspsaga peek_definition", "n", opts)
--
-- 		opts.desc = "Code actions"
-- 		mapkey("<leader>ca", "Lspsaga code_action", "n", opts) -- see available code actions
--
-- 		opts.desc = "Show line diagnostics"
-- 		mapkey("gl", "Lspsaga show_line_diagnostics", "n", opts) -- show  diagnostics for line
--
-- 		opts.desc = "Go to the previous diagnostic"
-- 		mapkey("<leader>pd", "Lspsaga diagnostic_jump_prev", "n", opts) -- jump to prev diagnostic in buffer
--
-- 		opts.desc = "Go to the next diagnostic"
-- 		mapkey("<leader>nd", "Lspsaga diagnostic_jump_next", "n", opts) -- jump to next diagnostic in buffer
--
-- 		opts.desc = "show documentation for what is under the cursor"
-- 		mapkey("K", "Lspsaga hover_doc", "n", opts) -- show documentation for what is under cursor
--
-- 		opts.desc = "Restart LSP"
-- 		mapkey("<leader>rs", ":LspRestart<CR>", "n", opts) -- mapping to restart lsp if necessary
--
-- 		if client.name == "pyright" then
-- 			mapkey("<Leader>oi", "PyrightOrganizeImports", "n", opts)
-- 		end
-- 	end
--
-- 	-- lua
-- 	lspconfig.lua_ls.setup({
-- 		capabilities = capabilities,
-- 		on_attach = on_attach,
-- 		settings = { -- custom settings for lua
-- 			Lua = {
-- 				-- make the language server recognize "vim" global
-- 				diagnostics = {
-- 					globals = { "vim" },
-- 				},
-- 				workspace = {
-- 					-- make language server aware of runtime files
-- 					library = {
-- 						[vim.fn.expand("$VIMRUNTIME/lua")] = true,
-- 						[vim.fn.stdpath("config") .. "/lua"] = true,
-- 					},
-- 				},
-- 			},
-- 		},
-- 	})
--
-- 	-- Go
-- 	lspconfig.gopls.setup({
-- 		capabilities = capabilities,
-- 		on_attach = on_attach,
-- 		filetypes = { "go" },
-- 	})
--
-- 	-- json
-- 	lspconfig.jsonls.setup({
-- 		capabilities = capabilities,
-- 		on_attach = on_attach,
-- 		filetypes = { "json", "jsonc" },
-- 	})
--
-- 	-- python
-- 	lspconfig.pyright.setup({
-- 		capabilities = capabilities,
-- 		on_attach = on_attach,
-- 		settings = {
-- 			pyright = {
-- 				disableOrganizeImports = false,
-- 				analysis = {
-- 					useLibraryCodeForTypes = true,
-- 					autoSearchPaths = true,
-- 					diagnosticMode = "workspace",
-- 					autoImportCompletions = true,
-- 				},
-- 			},
-- 		},
-- 	})
--
-- 	-- typescript
-- 	lspconfig.tsserver.setup({
-- 		on_attach = on_attach,
-- 		capabilities = capabilities,
-- 		filetypes = {
-- 			"typescript",
-- 			"typescriptreact",
-- 		},
-- 		root_dir = lspconfig.util.root_pattern("package.json", "tsconfig.json", ".git"),
-- 	})
--
-- 	-- bash
-- 	lspconfig.bashls.setup({
-- 		capabilities = capabilities,
-- 		on_attach = on_attach,
-- 		filetypes = { "sh", "aliasrc" },
-- 	})
--
-- 	-- solidity
-- 	lspconfig.solidity.setup({
-- 		capabilities = capabilities,
-- 		on_attach = on_attach,
-- 		filetypes = { "solidity" },
-- 	})
--
-- 	-- typescriptreact, javascriptreact, css, sass, scss, less, svelte, vue
-- 	lspconfig.emmet_ls.setup({
-- 		capabilities = capabilities,
-- 		on_attach = on_attach,
-- 		filetypes = {
-- 			"css",
-- 			"sass",
-- 			"scss",
-- 			"less",
-- 			"svelte",
-- 			"vue",
-- 			"html",
-- 		},
-- 	})
--
-- 	-- docker
-- 	lspconfig.dockerls.setup({
-- 		capabilities = capabilities,
-- 		on_attach = on_attach,
-- 	})
--
-- 	-- -- C/C++
-- 	-- lspconfig.clangd.setup({
-- 	-- 	capabilities = capabilities,
-- 	-- 	on_attach = on_attach,
-- 	-- 	cmd = {
-- 	-- 		"clangd",
-- 	-- 		'--offset-encoding=utf-16 --style="{IndentWidth: 8}"',
-- 	-- 	},
-- 	-- 	root_dir = lspconfig.util.root_pattern(".git"),
-- 	-- })
--
-- 	local luacheck = require("efmls-configs.linters.luacheck")
-- 	local gofumpt = require("efmls-configs.formatters.gofumpt")
-- 	local stylua = require("efmls-configs.formatters.stylua")
-- 	local eslint_d = require("efmls-configs.linters.eslint_d")
-- 	local prettier_d = require("efmls-configs.formatters.prettier_d")
-- 	local fixjson = require("efmls-configs.formatters.fixjson")
-- 	local shellcheck = require("efmls-configs.linters.shellcheck")
-- 	local shfmt = require("efmls-configs.formatters.shfmt")
-- 	local hadolint = require("efmls-configs.linters.hadolint")
-- 	local solhint = require("efmls-configs.linters.solhint")
-- 	local cpplint = require("efmls-configs.linters.cpplint")
-- 	local clangformat = require("efmls-configs.formatters.clang_format")
--
-- 	-- configure efm server
-- 	lspconfig.efm.setup({
-- 		filetypes = {
-- 			"lua",
-- 			"json",
-- 			"jsonc",
-- 			"sh",
-- 			"javascript",
-- 			"javascriptreact",
-- 			"typescript",
-- 			"typescriptreact",
-- 			"markdown",
-- 			"docker",
-- 			"solidity",
-- 			"html",
-- 			"css",
-- 			"c",
-- 			"cpp",
-- 			"go",
-- 		},
-- 		init_options = {
-- 			documentFormatting = true,
-- 			documentRangeFormatting = true,
-- 			hover = true,
-- 			documentSymbol = true,
-- 			codeAction = true,
-- 			completion = true,
-- 		},
-- 		settings = {
-- 			languages = {
-- 				lua = { luacheck, stylua },
-- 				typescript = { eslint_d, prettier_d },
-- 				json = { eslint_d, fixjson },
-- 				jsonc = { eslint_d, fixjson },
-- 				sh = { shellcheck, shfmt },
-- 				javascript = { eslint_d, prettier_d },
-- 				javascriptreact = { eslint_d, prettier_d },
-- 				typescriptreact = { eslint_d, prettier_d },
-- 				markdown = { prettier_d },
-- 				docker = { hadolint, prettier_d },
-- 				solidity = { solhint },
-- 				html = { prettier_d },
-- 				css = { prettier_d },
-- 				c = { clangformat, cpplint },
-- 				cpp = { clangformat, cpplint },
-- 				go = { gofumpt },
-- 			},
-- 		},
-- 	})
--
-- 	local lsp_fmt_group = vim.api.nvim_create_augroup("LspFormattingGroup", {})
-- 	vim.api.nvim_create_autocmd("BufWritePost", {
-- 		group = lsp_fmt_group,
-- 		callback = function()
-- 			local efm = vim.lsp.get_active_clients({ name = "efm" })
--
-- 			if vim.tbl_isempty(efm) then
-- 				return
-- 			end
--
-- 			vim.lsp.buf.format({ name = "efm" })
-- 		end,
-- 	})
-- end
--
-- return {
-- 	"neovim/nvim-lspconfig",
-- 	config = config,
-- 	lazy = false,
-- 	dependencies = {
-- 		"windwp/nvim-autopairs",
-- 		"williamboman/mason.nvim",
-- 		"hrsh7th/nvim-cmp",
-- 		"hrsh7th/cmp-buffer",
-- 		"hrsh7th/cmp-nvim-lsp",
-- 		"creativenull/efmls-configs-nvim",
-- 	},
-- }
--
return { -- LSP Configuration & Plugins
	"neovim/nvim-lspconfig",
	dependencies = {
		-- Automatically install LSPs and related tools to stdpath for Neovim
		"williamboman/mason.nvim",
		"williamboman/mason-lspconfig.nvim",
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		"hrsh7th/cmp-nvim-lsp",

		-- Useful status updates for LSP.
		-- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
		{ "j-hui/fidget.nvim", opts = {} },

		-- `neodev` configures Lua LSP for your Neovim config, runtime and plugins
		-- used for completion, annotations and signatures of Neovim apis
		{ "folke/neodev.nvim", opts = {} },
	},
	config = function()
		-- Brief aside: **What is LSP?**
		--
		-- LSP is an initialism you've probably heard, but might not understand what it is.
		--
		-- LSP stands for Language Server Protocol. It's a protocol that helps editors
		-- and language tooling communicate in a standardized fashion.
		--
		-- In general, you have a "server" which is some tool built to understand a particular
		-- language (such as `gopls`, `lua_ls`, `rust_analyzer`, etc.). These Language Servers
		-- (sometimes called LSP servers, but that's kind of like ATM Machine) are standalone
		-- processes that communicate with some "client" - in this case, Neovim!
		--
		-- LSP provides Neovim with features like:
		--  - Go to definition
		--  - Find references
		--  - Autocompletion
		--  - Symbol Search
		--  - and more!
		--
		-- Thus, Language Servers are external tools that must be installed separately from
		-- Neovim. This is where `mason` and related plugins come into play.
		--
		-- If you're wondering about lsp vs treesitter, you can check out the wonderfully
		-- and elegantly composed help section, `:help lsp-vs-treesitter`

		--  This function gets run when an LSP attaches to a particular buffer.
		--    That is to say, every time a new file is opened that is associated with
		--    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
		--    function will be executed to configure the current buffer
		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
			callback = function(event)
				-- NOTE: Remember that Lua is a real programming language, and as such it is possible
				-- to define small helper and utility functions so you don't have to repeat yourself.
				--
				-- In this case, we create a function that lets us more easily define mappings specific
				-- for LSP related items. It sets the mode, buffer and description for us each time.
				local map = function(keys, func, desc)
					vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
				end

				-- Jump to the definition of the word under your cursor.
				--  This is where a variable was first declared, or where a function is defined, etc.
				--  To jump back, press <C-t>.
				map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")

				-- Find references for the word under your cursor.
				map("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")

				-- Jump to the implementation of the word under your cursor.
				--  Useful when your language has ways of declaring types without an actual implementation.
				map("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")

				-- Jump to the type of the word under your cursor.
				--  Useful when you're not sure what type a variable is and you want to see
				--  the definition of its *type*, not where it was *defined*.
				map("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")

				-- Fuzzy find all the symbols in your current document.
				--  Symbols are things like variables, functions, types, etc.
				map("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")

				-- Fuzzy find all the symbols in your current workspace.
				--  Similar to document symbols, except searches over your entire project.
				map("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")

				-- Rename the variable under your cursor.
				--  Most Language Servers support renaming across files, etc.
				map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")

				-- Execute a code action, usually your cursor needs to be on top of an error
				-- or a suggestion from your LSP for this to activate.
				map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")

				-- Opens a popup that displays documentation about the word under your cursor
				--  See `:help K` for why this keymap.
				map("K", vim.lsp.buf.hover, "Hover Documentation")

				-- WARN: This is not Goto Definition, this is Goto Declaration.
				--  For example, in C this would take you to the header.
				map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

				-- The following two autocommands are used to highlight references of the
				-- word under your cursor when your cursor rests there for a little while.
				--    See `:help CursorHold` for information about when this is executed
				--
				-- When you move your cursor, the highlights will be cleared (the second autocommand).
				local client = vim.lsp.get_client_by_id(event.data.client_id)
				if client and client.server_capabilities.documentHighlightProvider then
					vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
						buffer = event.buf,
						callback = vim.lsp.buf.document_highlight,
					})

					vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
						buffer = event.buf,
						callback = vim.lsp.buf.clear_references,
					})
				end
			end,
		})

		-- LSP servers and clients are able to communicate to each other what features they support.
		--  By default, Neovim doesn't support everything that is in the LSP specification.
		--  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
		--  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
		local capabilities = vim.lsp.protocol.make_client_capabilities()
		capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

		-- Enable the following language servers
		--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
		--
		--  Add any additional override configuration in the following tables. Available keys are:
		--  - cmd (table): Override the default command used to start the server
		--  - filetypes (table): Override the default list of associated filetypes for the server
		--  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
		--  - settings (table): Override the default settings passed when initializing the server.
		--        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
		local servers = {
			-- clangd = {},
			-- gopls = {},
			-- pyright = {},
			-- rust_analyzer = {},
			-- ... etc. See `:help lspconfig-all` for a list of all the pre-configured LSPs
			--
			-- Some languages (like typescript) have entire language plugins that can be useful:
			--    https://github.com/pmizio/typescript-tools.nvim
			--
			-- But for many setups, the LSP (`tsserver`) will work just fine
			-- tsserver = {},
			--

			lua_ls = {
				-- cmd = {...},
				-- filetypes = { ...},
				-- capabilities = {},
				settings = {
					Lua = {
						completion = {
							callSnippet = "Replace",
						},
						-- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
						diagnostics = { disable = { "missing-fields" } },
					},
				},
			},
		}

		require("mason").setup()

		-- You can add other tools here that you want Mason to install
		-- for you, so that they are available from within Neovim.
		local ensure_installed = vim.tbl_keys(servers or {})
		vim.list_extend(ensure_installed, {
			"stylua", -- Used to format Lua code
		})
		require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

		require("mason-lspconfig").setup({
			handlers = {
				function(server_name)
					local server = servers[server_name] or {}
					-- This handles overriding only values explicitly passed
					-- by the server configuration above. Useful when disabling
					-- certain features of an LSP (for example, turning off formatting for tsserver)
					server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
					require("lspconfig")[server_name].setup(server)
				end,
			},
		})
	end,
}
