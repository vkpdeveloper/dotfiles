return {
	"nvim-telescope/telescope.nvim",
	branch = "0.1.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		"nvim-telescope/telescope-dap.nvim",
		"folke/todo-comments.nvim",
	},
	config = function()
		local telescope = require("telescope")
		local keymap = vim.keymap
		local builtin = require("telescope.builtin")

		telescope.setup({
			defaults = {
				file_ignore_patterns = { "node_modules", "dist", "build", "target", "vendor" },
			},
		})
		telescope.load_extension("fzf")
		telescope.load_extension("dap")

		keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
		keymap.set("n", "<leader>fe", function()
			builtin.find_files({
				prompt_title = "Search Environment files",
				find_command = {
					"rg",
					"--files",
					"--hidden",
					"-g",
					".env",
					"-g",
					".env.*",
				},
			})
		end, { desc = "Find environment files" })
		keymap.set("n", "<leader>fg", builtin.git_files, { desc = "Find git files" })
		keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Find buffers" })
		keymap.set("n", "<leader>fs", builtin.live_grep, { desc = "Live grep" })
		keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Find help" })
		keymap.set("n", "<leader>ft", "<cmd>TodoTelescope<cr>", { desc = "Find todos" })

		-- LSP Pickers
		keymap.set("n", "<leader>sy", builtin.lsp_document_symbols, { desc = "Document Symbols" })
	end,
}
