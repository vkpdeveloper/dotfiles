return {
	"mbbill/undotree",
	cmd = "UndotreeToggle",
	opts = {},
	lazy = true,
	config = function()
		vim.keymap.set("n", "<leader>U", vim.cmd.UndotreeToggle)
	end,
}
