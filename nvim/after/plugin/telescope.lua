local status, telescope = pcall(require, "telescope")
if (not status) then return end
local actions = require('telescope.actions')
local builtin = require("telescope.builtin")
local fb_actions = require "telescope".extensions.file_browser.actions

local function telescope_buffer_dir()
    return vim.fn.expand('%:p:h')
end

vim.keymap.set('n', '<leader>pf', function()
    builtin.find_files({
        no_ignore = false,
        hidden = true
    })
end)

vim.keymap.set('n', '<leader>ps', function()
    builtin.live_grep()
end)
vim.keymap.set('n', '<leader>ps', function()
    telescope.grep_string({ search = vim.fn.input("Grep > ") });
end)

vim.keymap.set('n', '<leader>pg', function()
    builtin.git_files()
end)

vim.keymap.set('n', '<leader>pb', function()
    builtin.buffers()
end)

vim.keymap.set("n", "<leader>pv", function()
    telescope.extensions.file_browser.file_browser({
        path = "%:p:h",
        cwd = telescope_buffer_dir(),
        respect_gitignore = false,
        hidden = true,
        grouped = true,
        initial_mode = "normal",
        -- layout_config = { height = 40, width = 160 }
        --[[  ]] })
end)


telescope.setup {
    extensions = {
        file_browser = {
            respect_gitignore = false,
            hidden = true,
            grouped = true,
            initial_mode = "normal",
            -- disables netrw and use telescope-file-browser in its place
            hijack_netrw = true,
            mappings = {
                ["n"] = {
                    ["%"] = fb_actions.create,
                    ["-"] = fb_actions.goto_parent_dir,
                },
            },
        },
    },
}

telescope.load_extension("file_browser")
