return {
    "yioneko/nvim-vtsls",
    dependencies = { "neovim/nvim-lspconfig" },
    config = function()
        require("lspconfig").vtsls.setup({
            cmd = { "vtsls", "--stdio" },
            filetypes = { "typescript", "javascript", "typescriptreact", "javascriptreact" },
            root_dir = require("lspconfig.util").root_pattern("tsconfig.json", "package.json"),
            single_file_support = false,
            init_options = {
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

        vim.keymap.set('n', '<leader>mi', '<cmd>VtsExec add_missing_imports<CR>')
        vim.keymap.set('n', '<leader>oi', '<cmd>VtsExec organize_imports<CR>')
    end,
}
