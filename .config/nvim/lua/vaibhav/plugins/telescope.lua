return {
	"nvim-telescope/telescope.nvim",
	branch = "0.1.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-telescope/telescope-dap.nvim",
	},
	config = function()
		-- local trouble = require("trouble.providers.telescope")
		require("telescope").setup({
			defaults = {
				file_ignore_patterns = { "node_modules", "dist", "build", "target", "vendor" },
			},
		})
		require("telescope").load_extension("dap")
		local builtin = require("telescope.builtin")
		vim.keymap.set("n", "<leader>f", builtin.find_files, {})
		vim.keymap.set("n", "<leader>gf", builtin.git_files, {})
		vim.keymap.set("n", "<leader>b", builtin.buffers, {})
		vim.keymap.set("n", "<leader>lg", builtin.live_grep, {})
		vim.keymap.set("n", "<leader>vh", builtin.help_tags, {})
	end,
}
