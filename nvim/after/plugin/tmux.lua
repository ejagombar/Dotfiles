require("tmux").setup({
    navigation = {
        cycle_navigation = true,
        persist_zoom = true,
    },
    resize = {
        enable_default_keybindings = true,
        resize_step_x = 4,
        resize_step_y = 4,
    },
})
