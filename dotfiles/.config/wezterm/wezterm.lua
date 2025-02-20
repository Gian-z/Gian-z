local wezterm = require("wezterm")
local config = wezterm.config_builder()
local launch_menu = require("launch-menu")

config.launch_menu = launch_menu.launch_menu
config.default_prog = { "powershell.exe", "-NoLogo" }
config.color_scheme = "Batman"
config.font = wezterm.font("JetBrains Mono", { weight = "Bold", italic = false })
config.window_background_opacity = 0.9
config.inactive_pane_hsb = {
	saturation = 0.9,
	brightness = 0.8,
}

return config
