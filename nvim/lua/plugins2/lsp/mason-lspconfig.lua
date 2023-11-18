local opts = {
    ensure_installed = {
        "efm",
        "bashls",
        "tsserver",
        "tailwindcss",
        "pyright",
        "lua_ls",
        "jsonls",
        'gopls',
        'clangd',
        'html',
        'cssls',
    },

    automatic_installation = true,
}

return {
    "williamboman/mason-lspconfig.nvim",
    opts = opts,
    event = "BufReadPre",
    dependencies = "williamboman/mason.nvim",
}
