local null_ls_status_ok, null_ls = pcall(require, "null-ls")
if not null_ls_status_ok then
    print("null_ls not found")
    return
end

-- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/formatting
local formatting = null_ls.builtins.formatting
-- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/diagnostics
-- local diagnostics = null_ls.builtins.diagnostics
vim.env.PRETTIERD_DEFAULT_CONFIG = vim.fn.expand('~/.prettierrc')


null_ls.setup({
    debug = false,
    sources = {
        formatting.prettierd -- .with({extra_args = { "--tab-width", 2, "--no-semi", "--single-quote" } }),
    },
})
