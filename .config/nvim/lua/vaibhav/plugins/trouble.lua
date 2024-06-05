return {
	"folke/trouble.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	event = {
		"BufReadPre",
		"BufNewFile",
	},
	opts = {
		auto_refresh = true,
		keys = {
			q = "close",
			r = "refresh",
			["?"] = "help",
		},
	},
	config = function(_, opts)
		local trouble = require("trouble")
		local map = vim.keymap.set
		trouble.setup(opts)

		map("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>")
		map("n", "<leader>xd", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>")
		map("n", "<leader>xq", "<cmd>Trouble qflist toggle<cr>")
		-- map("n", "<leader>xl", function()
		-- 	trouble.toggle("loclist")
		-- end)
		-- map("n", "gR", function()
		-- 	trouble.toggle("lsp_references")
		-- end)
	end,
}
