return {
	"akinsho/flutter-tools.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"dart-lang/dart-vim-plugin",
		"mfussenegger/nvim-dap",
	},
	config = function(opts)
		local flutter = require("flutter-tools")
		flutter.setup({
			debugger = {
				-- make these two params true to enable debug mode
				enabled = true,
				run_via_dap = true,
				register_configurations = function(_)
					require("dap").adapters.dart = {
						type = "executable",
						command = vim.fn.stdpath("data") .. "/mason/bin/dart-debug-adapter",
						args = { "flutter" },
					}

					require("dap").configurations.dart = {
						{
							type = "dart",
							request = "launch",
							name = "Launch flutter",
							dartSdkPath = "/opt/dart-sdk",
							flutterSdkPath = "/opt/flutter",
							program = "${workspaceFolder}/lib/main.dart",
							cwd = "${workspaceFolder}",
						},
					}
				end,
			},
			dev_log = {
				enabled = false,
				open_cmd = "tabedit",
			},
			lsp = {
				on_attach = require("lsp-zero").common_on_attach,
				capabilities = require("lsp-zero").default_capabilities,
			},
		})
	end,
	lazy = false,
}
