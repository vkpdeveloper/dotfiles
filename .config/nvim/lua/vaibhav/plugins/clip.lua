return {
	"AckslD/nvim-neoclip.lua",
	lazy = false,
	config = function()
		require("neoclip").setup({
			history = 30,
			enable_persistent_history = false,
			keys = {
				telescope = {
					i = {
						select = "<cr>",
						paste = "<c-p>",
						paste_behind = "<c-k>",
						replay = "<c-q>",
						delete = "<c-d>",
						edit = "<c-e>",
						custom = {},
					},
					n = {
						select = "<cr>",
						paste = "p",
						paste_behind = "P",
						replay = "q",
						delete = "d",
						edit = "e",
						custom = {},
					},
				},
			},
		})

		vim.keymap.set("n", "<leader>fc", "<Cmd>Telescope neoclip<CR>")
	end,
}
