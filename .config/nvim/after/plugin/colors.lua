function ColorMyNeovim(color)
	color = color or "shades_of_purple"
	vim.cmd.colorscheme(color)

	vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
	vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })

end

ColorMyNeovim('github_dark_colorblind')
