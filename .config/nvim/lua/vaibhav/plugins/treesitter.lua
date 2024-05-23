return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	event = {
		"BufReadPre",
		"BufNewFile",
	},
	dependencies = {
		"nvim-treesitter/nvim-treesitter-textobjects",
		"nvim-treesitter/nvim-treesitter-context",
	},
	config = function()
		-- treesitter setup
		require("nvim-treesitter.configs").setup({
			ensure_installed = {
				"c",
				"lua",
				"vim",
				"vimdoc",
				"query",
				"rust",
				"go",
				"javascript",
				"typescript",
				"python",
				"markdown",
				"html",
				"css",
				"json",
				"yaml",
				"toml",
				"tsx",
				"php",
				"sql",
			},
			sync_install = true,
			auto_install = true,
			highlight = {
				enable = true,
				additional_vim_regex_highlighting = {
					"ruby",
					"python",
				},
			},
			indent = {
				enable = true,
				disable = {
					"ruby",
				},
			},
			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "<C-space>",
					node_incremental = "<C-space>",
					scope_incremental = false,
					node_decremental = "<bs>",
				},
			},
		})
		-- treesitter setup

		-- treesitter textobjects setup
		require("nvim-treesitter.configs").setup({
			textobjects = {
				select = {
					enable = true,
					lookahead = true,
					keymaps = {
						["af"] = {
							query = "@function.outer",
							desc = "Select outer part of a function",
						},
						["if"] = {
							query = "@function.inner",
							desc = "Select inner part of a function",
						},
						["ac"] = {
							query = "@class.outer",
							desc = "Select outer part of a class",
						},
						["ic"] = {
							query = "@class.inner",
							desc = "Select inner part of a class",
						},
						["a="] = {
							query = "@assignment.outer",
							desc = "Select outer part of an assignment",
						},
						["i="] = {
							query = "@assignment.inner",
							desc = "Select inner part of an assignment",
						},
						["r="] = {
							query = "@assignment.rhs",
							desc = "Select right hand side of an assignment",
						},
						["l="] = {
							query = "@assignment.lhs",
							desc = "Select left hand side of an assignment",
						},
						["a/"] = {
							query = "@comment.outer",
							desc = "Select outer part of a comment",
						},
						["i/"] = {
							query = "@comment.inner",
							desc = "Select inner part of a comment",
						},
						["aa"] = {
							query = "@parameter.outer",
							desc = "Select outer part of a parameter",
						},
						["ia"] = {
							query = "@parameter.inner",
							desc = "Select inner part of a parameter",
						},
						["al"] = {
							query = "@loop.outer",
							desc = "Select outer part of a loop",
						},
						["il"] = {
							query = "@loop.inner",
							desc = "Select inner part of a loop",
						},
						["ai"] = {
							query = "@conditional.outer",
							desc = "Select outer part of a conditional",
						},
						["ii"] = {
							query = "@conditional.inner",
							desc = "Select inner part of a conditional",
						},
						["ab"] = {
							query = "@block.outer",
							desc = "Select outer part of a block",
						},
						["ib"] = {
							query = "@block.inner",
							desc = "Select inner part of a block",
						},
					},
				},
			},
		})
		-- treesitter textobjects setup

		-- treesitter context setup
		local treesitterContext = require("treesitter-context")
		treesitterContext.setup()

		vim.keymap.set("n", "[c", function()
			treesitterContext.go_to_context(vim.v.count1)
		end, { desc = "move to the current context" })
		-- treesitter context setup
	end,
}
