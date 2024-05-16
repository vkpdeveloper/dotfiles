return {
	"folke/todo-comments.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-telescope/telescope.nvim",
		"folke/trouble.nvim",
	},
	event = {
		"BufReadPre",
		"BufNewFile",
	},
	opts = {
		signs = false,
		sign_priority = 8,

		keywords = {
			FIX = {
				color = "error",
				alt = { "FIXME", "BUG", "FIXIT", "ISSUE" },
			},
			TODO = { color = "info", alt = { "TODO" } },
			INFO = { color = "info", alt = { "INFO" } },
			HACK = { color = "warning" },
			WARN = { color = "warning", alt = { "WARNING", "XXX" } },
			PERF = { alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
			NOTE = { color = "hint", alt = { "INFO" } },
			TEST = { color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
		},
	},
	config = function(opts)
		local todoComments = require("todo-comments")
		todoComments.setup(opts)

		vim.keymap.set("n", "<leader>td", "<cmd>:TodoTelescope<cr>")
		vim.keymap.set("n", "<leader>tt", "<cmd>:TodoTrouble<cr>")
	end,
}
