-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

-- For example, changing the color scheme:
config.color_scheme = "Kanagawa Dragon (Gogh)"
config.font = wezterm.font("JetBrainsMono Nerd Font")
config.font_size = 11

config.enable_tab_bar = false

config.window_decorations = "RESIZE"
config.window_background_opacity = 0.80
config.macos_window_background_blur = 60

config.native_macos_fullscreen_mode = true

config.initial_rows = 200
config.initial_cols = 200

config.exit_behavior = "Close"
config.window_close_confirmation = "AlwaysPrompt"

config.window_padding = {
	left = "1cell",
	right = "1cell",
	top = "0.5cell",
	bottom = "0.5cell",
}

-- and finally, return the configuration to wezterm
return config
