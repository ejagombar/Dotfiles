local lsp = require('lsp-zero').preset({})
local lspConfig = require('lspconfig')
require('mason').setup()
require('mason-lspconfig').setup()
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


local capabilities = require("cmp_nvim_lsp").default_capabilities()

lsp.on_attach(function(client, bufnr)
    lsp.buffer_autoformat()
    lsp.default_keymaps({ buffer = bufnr })
    vim.keymap.set('n', 'gl', vim.diagnostic.open_float, opts)
end)

lspConfig.tsserver.setup({
    capabilities = capabilities,
    on_attach = function(client)
        client.server_capabilities.document_formatting = false
    end,
})

lspConfig.html.setup({
    capabilities = capabilities,
    on_attach = function(client)
        client.server_capabilities.document_formatting = false
    end,
})

-- lsp.skip_server_setup({ 'clangd' })

lsp.set_sign_icons({
    error = '✘',
    warn = '▲',
    hint = '⚑',
    info = '»'
})

lsp.setup()

-- require('clangd_extensions').setup()
