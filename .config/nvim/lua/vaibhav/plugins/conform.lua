return {
	"stevearc/conform.nvim",
	event = {
		"BufReadPre",
		"BufNewFile",
		"LspAttach",
	},
	opts = {
		notify_on_error = false,
		format_on_save = function(bufnr)
			-- Disable "format_on_save lsp_fallback" for languages that don't
			-- have a well standardized coding style. You can add additional
			-- languages here or re-enable it for the disabled ones.
			local disable_filetypes = {}
			return {
				timeout_ms = 2500,
				lsp_fallback = true,
			}
		end,
		formatters_by_ft = {
			lua = { "stylua" },
			-- Conform can also run multiple formatters sequentially
			python = { "black" },
			javascript = { { "prettier" } },
			typescript = { { "prettier" } },
			rust = { { "rustfmt" } },
			go = { { "goimports", "goimports-reviser" } },
			yaml = { { "prettier" } },
			json = { { "prettier" } },
			html = { { "prettier" } },
			css = { { "prettier" } },
			markdown = { { "prettier" } },
			php = { { "phpcbf" } },
			scala = { { "scalafmt" } },
		},
	},
	config = function(_, opts)
		local conform = require("conform")
		conform.setup(opts)
		conform.formatters.prettier = {
			prepend_args = { "--prose-wrap", "always" },
		}
	end,
}
