-- return {
-- 	"rebelot/kanagawa.nvim",
-- 	lazy = false,
-- 	priority = 1000,
-- 	config = function()
-- 		require("kanagawa").setup({
-- 			compile = false, -- enable compiling the colorscheme
-- 			undercurl = false, -- enable undercurls
-- 			commentStyle = {
-- 				italic = false,
-- 			},
-- 			functionStyle = {
-- 				italic = false,
-- 			},
-- 			keywordStyle = {
-- 				italic = false,
-- 			},
-- 			statementStyle = {
-- 				bold = false,
-- 				italic = false,
-- 			},
-- 			typeStyle = {},
-- 			transparent = false, -- do not set background color
-- 			dimInactive = false, -- dim inactive window `:h hl-NormalNC`
-- 			terminalColors = true, -- define vim.g.terminal_color_{0,17}
-- 			colors = {
-- 				palette = {},
-- 				theme = {
-- 					all = {
-- 						ui = {
-- 							bg_gutter = "none",
-- 						},
-- 					},
-- 				},
-- 			},
-- 			overrides = function(colors)
-- 				local theme = colors.theme
-- 				return {
-- 					["@variable.builtin"] = {
-- 						bg = "none",
-- 						italic = false,
-- 					},
-- 				}
-- 			end,
-- 			theme = "dragon",
-- 		})
-- 		require("kanagawa").load("dragon")
-- 		-- vim.cmd([[colorscheme kanagawa-dragon]])
-- 	end,
-- }

-- return {
-- 	"nyoom-engineering/oxocarbon.nvim",
-- 	config = function()
-- 		vim.opt.background = "dark"
-- 		vim.cmd("colorscheme oxocarbon")
-- 	end,
-- }

return {
	"catppuccin/nvim",
	priority = 1000,
	name = "catppuccin",
	config = function()
		require("catppuccin").setup({
			flavour = "mocha",
			no_italic = true,
			term_colors = false,
			transparent_background = true,
			styles = {
				comments = {},
				conditionals = {},
				loops = {},
				functions = {},
				keywords = {},
				strings = {},
				variables = {},
				numbers = {},
				booleans = {},
				properties = {},
				types = {},
			},
			color_overrides = {
				mocha = {
					base = "#000000",
					mantle = "#000000",
					crust = "#000000",
				},
			},
			-- integrations = {
			-- 	telescope = {
			-- 		enabled = true,
			-- 		style = "nvchad",
			-- 	},
			-- },
			default_integrations = true,
			integrations = {
				cmp = true,
				gitsigns = true,
				nvimtree = true,
				treesitter = true,
				notify = false,
				mini = {
					enabled = true,
					indentscope_color = "",
				},
				dropbar = {
					enabled = true,
					color_mode = true,
				},
				-- For more plugins integrations please scroll down (https://github.com/catppuccin/nvim#integrations)
			},
		})
		vim.cmd.colorscheme("catppuccin")
	end,
}
