return {
    "pmizio/typescript-tools.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
    opts = {
        separate_diagnostic_server = true,
        tsserver_max_memory = "2048M",
    },
    -- config = function(opts)
    --     local tstools = require("typescript-tools")
    --     tstools.setup(opts)
    --     local keymap = vim.keymap
    --
    --     -- Setting <leader>fi to run TSToolsOrganizeImports
    --     keymap.set("n", "<leader>fi", "<cmd>TSToolsOrganizeImports<cr>", { desc = "Organize Imports" })
    --
    --     -- Setting <leader>ai to run TSToolsAddMissingImports
    --     keymap.set("n", "<leader>ai", "<cmd>TSToolsAddMissingImports<cr>", { desc = "Add Missing Imports" })
    -- end
}
