local lsp = require('lsp-zero').preset({})

lsp.preset("recommended")

lsp.ensure_installed({
    'gopls',
    'clangd',
    'lua_ls',
    'tsserver',
    'html',
    'cssls',
})

-- Fix Undefined global 'vim'
lsp.configure('lua_ls', {
    cmd = { 'lua-language-server' },
    settings = {
        Lua = {
            runtime = {
                version = 'LuaJIT',
                path = vim.split(package.path, ';'),
            },
            diagnostics = {
                globals = { 'vim' },
            },
            workspace = {
                library = {
                    [vim.fn.expand('$VIMRUNTIME/lua')] = true,
                    [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true,
                },
            },
        },
    },
})


-- local augroup = vim.api.nvim_create_augroup('LspFormatting', {})
-- local lsp_format_on_save = function(bufnr)
--     vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
--     vim.api.nvim_create_autocmd('BufWritePre', {
--         group = augroup,
--         buffer = bufnr,
--         callback = function()
--             vim.lsp.buf.format()
--             filter = function(client)
--                 return client.name == "null-ls"
--             end
--         end,
--     })
-- end


lsp.on_attach(function(client, bufnr)
    lsp.buffer_autoformat()
    lsp.default_keymaps({ buffer = bufnr })
    vim.keymap.set('n', 'gl', vim.diagnostic.open_float, opts)
end)

require('lspconfig').tsserver.setup({
    on_init = function(client)
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentFormattingRangeProvider = false
    end,
})

require('mason').setup()
require('mason-lspconfig').setup()

-- lsp.skip_server_setup({ 'clangd' })

lsp.set_sign_icons({
    error = '✘',
    warn = '▲',
    hint = '⚑',
    info = '»'
})

lsp.setup()

-- require('clangd_extensions').setup()
