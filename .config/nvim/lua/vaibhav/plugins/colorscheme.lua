return {
	"rebelot/kanagawa.nvim",
	lazy = false,
	priority = 1000,
	config = function()
		require("kanagawa").setup({
			compile = false, -- enable compiling the colorscheme
			undercurl = false, -- enable undercurls
			commentStyle = {
				italic = false,
			},
			functionStyle = {
				italic = false,
			},
			keywordStyle = {
				italic = false,
			},
			statementStyle = {
				italic = false,
			},
			typeStyle = {},
			transparent = false, -- do not set background color
			dimInactive = false, -- dim inactive window `:h hl-NormalNC`
			terminalColors = true, -- define vim.g.terminal_color_{0,17}
			colors = {
				palette = {},
				theme = {
					all = {
						ui = {
							bg_gutter = "none",
						},
					},
				},
			},
			overrides = function(colors)
				local theme = colors.theme
				return {}
			end,
			theme = "dragon",
		})
		require("kanagawa").load("dragon")
		-- vim.cmd([[colorscheme kanagawa-dragon]])
	end,
}
