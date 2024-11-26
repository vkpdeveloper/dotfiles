return {
	"folke/persistence.nvim",
	event = "BufReadPre", -- this will only start session saving when an actual file was opened
	opts = {
		dir = vim.fn.stdpath("state") .. "/sessions/",
		need = 1,
		branch = true,
	},
	config = function(opts)
		local persistence = require("persistence")
		persistence.setup(opts)

		local map = vim.keymap.set

		map("n", "<leader>ps", function()
			persistence.load()
		end)

		map("n", "<leader>pS", function()
			persistence.select()
		end)
	end,
}
