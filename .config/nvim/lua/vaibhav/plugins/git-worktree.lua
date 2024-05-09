return {
	"ThePrimeagen/git-worktree.nvim",
	lazy = false,
	dependencies = { "nvim-telescope/telescope.nvim" },
	config = function()
		local Worktree = require("git-worktree")
		local telescope = require("telescope")
		Worktree.setup()
		telescope.load_extension("git_worktree")
		local tWorktree = telescope.extensions.git_worktree

		vim.keymap.set("n", "<leader>sw", function()
			tWorktree.git_worktrees()
		end, { desc = "Switch Git Worktree" })

		Worktree.on_tree_change(function(op, metadata)
			if op == Worktree.Operations.Switch then
				local prevPathLastSegment = metadata.prev_path:gmatch("/([^/]+)$")()
				local currentPathLastSegment = metadata.path:gmatch("/([^/]+)$")()
				print("Switched from " .. prevPathLastSegment .. " to " .. currentPathLastSegment)
			end
		end)
	end,
}
