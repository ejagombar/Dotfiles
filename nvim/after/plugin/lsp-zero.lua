local lsp_status_ok, lsp = pcall(require, "lsp-zero")
if not lsp_status_ok then
    print('lsp not found')
    return
end

local lspConfig_status_ok, lspConfig = pcall(require, "lspConfig")
if lspConfig_status_ok then
    print('lspConfig not found')
    return
end

require('mason').setup()
require('mason-lspconfig').setup()

local capabilities = require("cmp_nvim_lsp").default_capabilities()

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

lsp.on_attach(function(client, bufnr)
    if client.name == "tsserver" then
        client.server_capabilities.document_formatting = false
    end

    lsp.buffer_autoformat()
    lsp.default_keymaps({ buffer = bufnr })
    vim.keymap.set('n', 'gl', vim.diagnostic.open_float)
end)

-- lspConfig.html.setup({
--     capabilities = capabilities,
--     on_attach = function(client)
--         client.server_capabilities.document_formatting = false
--     end,
-- })

-- lsp.skip_server_setup({ 'clangd' })

lsp.set_sign_icons({
    error = '✘',
    warn = '▲',
    hint = '⚑',
    info = '»'
})

lsp.setup()
