return {
    "VonHeikemen/lsp-zero.nvim",
    event = { "BufReadPre", "BufNewFile" },
    branch = "v3.x",
    dependencies = {
        { "neovim/nvim-lspconfig" },
        {
            "williamboman/mason.nvim",
            opts = {
                automatic_installation = true,
                ensure_installed = {
                    "js-debug-adapter",
                    "lua_ls",
                    "rust_analyzer",
                    "clangd",
                    "codelldb",
                    "gopls",
                    "docker_compose_language_service",
                    "dockerls",
                    "prismals",
                    "tailwindcss",
                    "eslint_d",
                    "prettierd",
                    "delve",
                    "black",
                    "isort",
                },
            },
        },
        { "williamboman/mason-lspconfig.nvim" },
    },
    config = function()
        local lsp = require("lsp-zero")
        lsp.preset("recommended")

        require("mason").setup()
        require("mason-lspconfig").setup({
            ensure_installed = {
                "ts_ls",
                "rust_analyzer",
                "clangd",
                "golangci_lint_ls",
                "gopls",
                "docker_compose_language_service",
                "dockerls",
                "biome",
                "prismals",
                "tailwindcss",
                "lua_ls",
            },
            handlers = {
                lsp.default_setup,
            },
        })

		local signs = {
			{ name = "DiagnosticSignError", text = "✘" },
			{ name = "DiagnosticSignWarn", text = "▲" },
			{ name = "DiagnosticSignHint", text = "⚑" },
			{ name = "DiagnosticSignInfo", text = "" },
		}

		lsp.set_sign_icons({
			error = "✘",
			warn = "▲",
			hint = "⚑",
			info = "",
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
            "ts_ls",
            "rust_analyzer",
            "lua_ls",
            "tailwindcss",
            "gopls",
            "dockerls",
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
			vim.keymap.set("n", "<leader>rf", function()
				vim.lsp.buf.references()
			end, opts)
			vim.keymap.set("n", "<leader>rn", function()
				vim.lsp.buf.rename()
			end, opts)
			vim.keymap.set("i", "<C-h>", function()
				vim.lsp.buf.signature_help()
			end, opts)
			vim.keymap.set("n", "<leader>qf", "<CR><Cmd>:cw<CR>", opts)
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
			signs = {
				active = signs,
			},
			update_in_insert = true,
			underline = true,
			severity_sort = true,
			float = {
				focusable = false,
				style = "minimal",
				border = "rounded",
				source = true,
				header = "",
				prefix = "",
			},
		})

		vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
			border = "rounded",
			width = 60,
		})

		vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
			border = "rounded",
			width = 60,
			close_events = { "CursorMoved", "BufHidden", "InsertCharPre" },
		})
	end,
}
