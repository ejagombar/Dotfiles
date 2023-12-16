return {
    'navarasu/onedark.nvim',
    opts= {style = 'darker'},
    priority=1000,
    config = function(_, opts)
        require("onedark").setup(opts)
        vim.cmd [[colorscheme onedark]]
    end,
}
