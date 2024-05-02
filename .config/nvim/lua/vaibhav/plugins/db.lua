local function db_completion()
	require("cmp").setup.buffer({ sources = { { name = "vim-dadbod-completion" } } })
end

return {
	"tpope/vim-dadbod",
	dependencies = {
		{
			"nvim-cmp",
		},
		{
			"kristijanhusak/vim-dadbod-ui",
			lazy = true,
		},
		{
			"kristijanhusak/vim-dadbod-completion",
			lazy = true,
		},
	},
	cmd = {
		"DBUI",
		"DBUIToggle",
		"DBUIAddConnection",
		"DBUIFindBuffer",
	},
	init = function()
		vim.keymap.set("n", "<leader>db", vim.cmd.DBUI)
		vim.keymap.set("n", "<leader>dbt", vim.cmd.DBUIToggle)
		vim.g.db_ui_use_nerd_fonts = 1

		vim.api.nvim_create_autocmd("FileType", {
			pattern = {
				"sql",
			},
			command = [[setlocal omnifunc=vim_dadbod_completion#omni]],
		})

		vim.api.nvim_create_autocmd("FileType", {
			pattern = {
				"sql",
				"mysql",
				"plsql",
			},
			callback = function()
				vim.schedule(db_completion)
			end,
		})
	end,
}
