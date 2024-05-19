return {
	"supermaven-inc/supermaven-nvim",
	config = function()
		require("supermaven-nvim").setup({
			keymaps = {
				accept_suggestion = "<C-g>",
				clear_suggestion = "<C-]>",
				accept_word = "<C-w>",
			},
			ignore_filetypes = {},
			color = {
				suggestion_color = "#878787",
				cterm = 244,
			},
			disable_inline_completion = false, -- disables inline completion for use with cmp
			disable_keymaps = false, -- disables built in keymaps for more manual control
		})
	end,
}
