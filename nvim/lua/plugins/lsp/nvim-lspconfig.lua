return {
	"neovim/nvim-lspconfig",
	dependencies = {
		"williamboman/mason.nvim",
		"williamboman/mason-lspconfig.nvim",
		"hrsh7th/cmp-nvim-lsp",
		{ "j-hui/fidget.nvim", opts = {} },
		{ "folke/lazydev.nvim", ft = "lua", opts = {} },
	},
	config = function()
		local diagnostic_signs = { Error = "", Warn = "", Hint = "󰠠", Info = "" }
		for type, icon in pairs(diagnostic_signs) do
			vim.fn.sign_define("DiagnosticSign" .. type, { text = icon, texthl = "DiagnosticSign" .. type })
		end

		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
			callback = function(event)
				local map = function(keys, func)
					vim.keymap.set("n", keys, func, { buffer = event.buf })
				end

				map("gd", require("telescope.builtin").lsp_definitions)
				map("gr", require("telescope.builtin").lsp_references)
				map("gi", require("telescope.builtin").lsp_implementations)
				map("<leader>D", require("telescope.builtin").lsp_type_definitions)
				map("<leader>ds", require("telescope.builtin").lsp_document_symbols)
				map("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols)
				map("<leader>rn", vim.lsp.buf.rename)
				map("<leader>ca", vim.lsp.buf.code_action)
				map("K", vim.lsp.buf.hover)
				map("gD", vim.lsp.buf.declaration)
			end,
		})

		vim.filetype.add({
			extension = {
				vert = "vert",
				frag = "frag",
				geom = "geom",
			},
		})

		local capabilities = vim.tbl_deep_extend(
			"force",
			vim.lsp.protocol.make_client_capabilities(),
			require("cmp_nvim_lsp").default_capabilities()
		)

		--  Add any additional override configuration in the following tables. Available keys are:
		--  - cmd (table): Override the default command used to start the server
		--  - filetypes (table): Override the default list of associated filetypes for the server
		--  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
		--  - settings (table): Override the default settings passed when initializing the server.
		local servers = {
			clangd = {
				cmd = {
					"clangd",
				},
				init_options = {
					usePlaceholders = true,
					completeUnimported = true,
					clangdFileStatus = true,
					semanticHighlighting = true,
				},
				filetypes = { "cpp", "c", "hpp", "cc", "cxx", "hxx", "h" },
			},
			gopls = {},
			bash = {},
			pyright = {},
			glsl_analyzer = {},
			lua_ls = {
				settings = {
					Lua = {
						completion = {
							callSnippet = "Replace",
						},
						diagnostics = { disable = { "missing-fields" } },
					},
				},
			},
		}

		require("mason-lspconfig").setup_handlers({
			function(server_name)
				local server = servers[server_name] or {}
				server.capabilities = vim.tbl_deep_extend("force", capabilities, server.capabilities or {})
				require("lspconfig")[server_name].setup(server)
			end,
		})
	end,
}
