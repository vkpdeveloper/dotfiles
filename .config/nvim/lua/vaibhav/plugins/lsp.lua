return {
	"VonHeikemen/lsp-zero.nvim",
	event = { "BufReadPre", "BufNewFile" },
	branch = "v3.x",
	dependencies = {
		{ "neovim/nvim-lspconfig" },
		{ "hrsh7th/cmp-nvim-lsp" },
		{ "hrsh7th/nvim-cmp" },
		{ "L3MON4D3/LuaSnip" },
		{ "williamboman/mason.nvim" },
		{ "williamboman/mason-lspconfig.nvim" },
	},
	config = function()
		local lsp = require("lsp-zero")
		local cmp = require("cmp")
		lsp.preset("recommended")

		-- nvim-cmp setup
		cmp.setup({
			mapping = cmp.mapping.preset.insert({
				["<Tab>"] = cmp.mapping.select_next_item(),
			}),
		})

		require("mason").setup()
		require("mason-lspconfig").setup({
			ensure_installed = {
				"tsserver",
				"rust_analyzer",
				"clangd",
				"golangci_lint_ls",
				"gopls",
				"docker_compose_language_service",
				"dockerls",
				"biome",
				"eslint",
				"prismals",
				"tailwindcss",
				"intelephense",
				"lua_ls",
			},
			handlers = {
				lsp.default_setup,
			},
		})

		lsp.set_sign_icons({
			error = "✘",
			warn = "▲",
			hint = "⚑",
			info = "»",
		})

		lsp.configure("lua_ls", {
			settings = {
				Lua = {
					runtime = {
						version = "LuaJIT",
					},
					diagnostics = {
						globals = { "vim", "require" },
					},
					workspace = {
						library = vim.api.nvim_get_runtime_file("", true),
					},
					telemetry = {
						enable = false,
					},
				},
			},
		})

		require("lspconfig").lua_ls.setup(lsp.nvim_lua_ls())
		lsp.setup_servers({
			"tsserver",
			"rust_analyzer",
			"lua_ls",
			"tailwindcss",
			"gopls",
			"dockerls",
			"eslint",
			"intelephense",
			"docker_compose_language_service",
			"prismals",
			"clangd",
		})

		lsp.on_attach(function(client, bufnr)
			lsp.default_keymaps({ buffer = bufnr })
			lsp.highlight_symbol(client, bufnr)
			local opts = { buffer = bufnr, remap = false }
			vim.keymap.set("n", "gd", function()
				vim.lsp.buf.definition()
			end, opts)
			vim.keymap.set("n", "K", function()
				vim.lsp.buf.hover()
			end, opts)
			vim.keymap.set("n", "<leader>ws", function()
				vim.lsp.buf.workspace_symbol()
			end, opts)
			vim.keymap.set("n", "<leader>vd", function()
				vim.diagnostic.open_float()
			end, opts)
			vim.keymap.set("n", "[d", function()
				vim.diagnostic.goto_next()
			end, opts)
			vim.keymap.set("n", "]d", function()
				vim.diagnostic.goto_prev()
			end, opts)
			vim.keymap.set("n", "<leader>ca", function()
				vim.lsp.buf.code_action()
			end, opts)
			vim.keymap.set("n", "<leader>vr", function()
				vim.lsp.buf.references()
			end, opts)
			vim.keymap.set("n", "<leader>rn", function()
				vim.lsp.buf.rename()
			end, opts)
			vim.keymap.set("i", "<C-h>", function()
				vim.lsp.buf.signature_help()
			end, opts)
		end)

		-- Setup dockerls
		require("lspconfig").dockerls.setup({
			on_attach = lsp.on_attach,
			capabilities = lsp.capabilities,
			filetypes = { "Dockerfile", "dockerfile" },
			cmd = { "docker-langserver", "--stdio" },
		})

		lsp.setup()
		vim.diagnostic.config({
			virtual_text = true,
		})
	end,
}
