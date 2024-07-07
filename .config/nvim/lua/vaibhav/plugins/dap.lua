local js_based_languages = {
	"typescript",
	"javascript",
	"typescriptreact",
	"javascriptreact",
}

return {
	"mfussenegger/nvim-dap",
	dependencies = {
		"leoluz/nvim-dap-go",
		{
			"Joakker/lua-json5",
			build = "./install.sh",
		},
		-- virtual text
		{
			"theHamsta/nvim-dap-virtual-text",
			opts = {},
		},
		-- mason.nvim integration
		{
			"jay-babu/mason-nvim-dap.nvim",
			dependencies = "mason.nvim",
			cmd = { "DapInstall", "DapUninstall" },
			event = "VeryLazy",
			opts = {
				-- Makes a best effort to setup the various debuggers with
				-- reasonable debug configurations
				automatic_installation = true,

				-- You can provide additional configuration to the handlers,
				-- see mason-nvim-dap README for more information
				handlers = {},

				-- You'll need to check that you have the required things installed
				-- online, please don't ask me how to install them :)
				ensure_installed = {
					"codelldb",
				},
			},
		},
		-- neoconf for launch.json parser
		{
			"folke/neoconf.nvim",
		},
		{
			"rcarriga/nvim-dap-ui",
		},
		"nvim-neotest/nvim-nio",
		{
			"microsoft/vscode-js-debug",
			-- After install, build it and rename the dist directory to out
			build = "npm install --legacy-peer-deps --no-save && npx gulp vsDebugServerBundle && rm -rf out && mv dist out",
			version = "1.*",
		},
		{
			"mxsdev/nvim-dap-vscode-js",
			config = function()
				---@diagnostic disable-next-line: missing-fields
				require("dap-vscode-js").setup({
					-- Path of node executable. Defaults to $NODE_PATH, and then "node"
					-- node_path = "node",

					-- Path to vscode-js-debug installation.
					debugger_path = vim.fn.resolve(vim.fn.stdpath("data") .. "/lazy/vscode-js-debug"),

					-- Command to use to launch the debug server. Takes precedence over "node_path" and "debugger_path"
					-- debugger_cmd = { "js-debug-adapter" },

					-- which adapters to register in nvim-dap
					adapters = {
						"chrome",
						"pwa-node",
						"pwa-chrome",
						"pwa-msedge",
						"pwa-extensionHost",
						"node-terminal",
					},
				})
			end,
		},
	},
	config = function()
		local dap = require("dap")
		local dapui = require("dapui")
		local dapGo = require("dap-go")
		dapui.setup()
		dapGo.setup()

		local sign = vim.fn.sign_define

		local dap_round_groups = { "DapBreakpoint", "DapBreakpointCondition", "DapBreakpointRejected", "DapLogPoint" }
		for _, group in pairs(dap_round_groups) do
			sign(group, { text = "●", texthl = group })
		end

		-- Adding listeners for dap to automatically open the daptui
		dap.listeners.before.attach.dapui_config = function()
			dapui.open()
		end
		dap.listeners.before.launch.dapui_config = function()
			dapui.open()
		end
		dap.listeners.before.event_terminated.dapui_config = function()
			dapui.close()
		end
		dap.listeners.before.event_exited.dapui_config = function()
			dapui.close()
		end

		dap.adapters.codelldb = {
			type = "server",
			port = "${port}",
			executable = {
				command = "codelldb",
				args = { "--port", "${port}" },
			},
		}

		vim.keymap.set("n", "<leader>ui", function()
			dapui.toggle()
		end)
	end,
	keys = {
		{
			"<leader>O",
			function()
				require("dap").step_out()
			end,
			desc = "Step Out",
		},
		{
			"<leader>o",
			function()
				require("dap").step_over()
			end,
			desc = "Step Over",
		},
		{
			"<leader>d",
			function()
				if vim.fn.filereadable(".vscode/launch.json") then
					local dap_vscode = require("dap.ext.vscode")
					dap_vscode.load_launchjs(nil, {
						["pwa-node"] = js_based_languages,
						["chrome"] = js_based_languages,
						["pwa-chrome"] = js_based_languages,
					})
				end
				require("dap").continue()
			end,
			desc = "Start or continue our debugger",
		},
		{
			"<leader>B",
			function()
				require("dap").toggle_breakpoint()
			end,
			desc = "Toggle Breakpoint",
		},
		{
			"<leader>dt",
			function()
				require("dap").terminate()
			end,
			desc = "Terminate",
		},
	},
}
