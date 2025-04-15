return {
	"yioneko/nvim-vtsls",
	dependencies = { "neovim/nvim-lspconfig" },
	config = function()
		require("lspconfig").vtsls.setup({
			-- VTSLS is specifically designed to be lighter than standard tsserver
			cmd = { "vtsls", "--stdio" },
			filetypes = { "typescript", "javascript", "typescriptreact", "javascriptreact" },
			root_dir = require("lspconfig.util").root_pattern("tsconfig.json", "package.json", ".git"),
			init_options = {
				-- Disable non-essential features
				hostInfo = "neovim",
				disableAutomaticTypingAcquisition = true,
				maxTsServerMemory = 4096,
				tsserver = {
					path = "", -- Let it find from node_modules
					logDirectory = "/tmp/vtsls-logs/",
					logVerbosity = "off",
					trace = false,
				},
			},
		})
	end,
}
