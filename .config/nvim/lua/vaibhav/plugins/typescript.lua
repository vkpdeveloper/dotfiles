return {
	"pmizio/typescript-tools.nvim",
	dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
	opts = {
		separate_diagnostic_server = true,
		tsserver_max_memory = "2048M",
	},
}
