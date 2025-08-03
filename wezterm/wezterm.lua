local wezterm = require("wezterm")

require("wezterm").on("format-window-title", function()
	return "Terminal"
end)

return {
	color_scheme = "One Dark (Gogh)",
	enable_tab_bar = false,
	font = wezterm.font("FiraCode Nerd Font"),
	keys = {
		{ key = "d", mods = "CTRL|SHIFT", action = wezterm.action.DisableDefaultAssignment },
		{ key = "%", mods = "CTRL|SHIFT", action = wezterm.action.DisableDefaultAssignment },
		{ key = "F11", action = wezterm.action.ToggleFullScreen },
	},
	window_padding = {
		left = 0,
		right = 0,
		top = 0,
		bottom = 0,
	},
}
