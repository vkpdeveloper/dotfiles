return {
    "stevearc/conform.nvim",
    event = {
        "BufReadPre",
        "BufNewFile",
        "LspAttach",
    },
    opts = {
        format_on_save = function(bufnr)
            -- Disable "format_on_save lsp_fallback" for languages that don't
            -- have a well standardized coding style. You can add additional
            -- languages here or re-enable it for the disabled ones.
            local disable_filetypes = { "oil" }
            return {
                lsp_format = "fallback",
                timeout_ms = 500,
                lsp_fallback = true,
                disable_filetypes = disable_filetypes,
            }
        end,
        notify_no_formatters = true,
        notify_on_error = false,
        log_level = vim.log.levels.ERROR,
        formatters_by_ft = {
            lua = { "stylua" },
            python = { "ruff" },
            javascript = { "prettierd" },
            typescript = { "prettierd" },
            jsx = { "prettierd" },
            graphql = { "prettierd" },
            rust = { "rustfmt" },
            go = { "goimports", "goimports-reviser" },
            yaml = { "prettierd" },
            json = { "jq" },
            html = { "prettierd" },
            css = { "prettierd" },
            markdown = { "prettierd" },
            php = { "phpcbf" },
            scala = { "scalafmt" },
            sql = { "sqlfmt" },
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
