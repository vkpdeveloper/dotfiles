return {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
        height = 10,
        position = "bottom",
        icons = true,
        fold_open = "",
        fold_closed = "",
        action_keys = {
            close = "q",                  -- close the list
            cancel = "<esc>",             -- cancel the preview and get back to your last window / buffer / cursor
            refresh = "r",                -- manually refresh
            jump = { "<cr>", "<tab>" },   -- jump to the diagnostic or open / close folds
            open_split = { "<c-x>" },     -- open buffer in new split
            open_vsplit = { "<c-v>" },    -- open buffer in new vsplit
            open_tab = { "<c-t>" },       -- open buffer in new tab
            jump_close = { "o" },         -- jump to the diagnostic and close the list
            toggle_mode = "m",            -- toggle between "workspace" and "document" diagnostics mode
            switch_severity = "s",        -- switch "diagnostics" severity filter level to HINT / INFO / WARN / ERROR
            toggle_preview = "P",         -- toggle auto_preview
            hover = "K",                  -- opens a small popup with the full multiline message
            preview = "p",                -- preview the diagnostic location
            open_code_href = "c",         -- if present, open a URI with more information about the diagnostic error
            close_folds = { "zM", "zm" }, -- close all folds
            open_folds = { "zR", "zr" },  -- open all folds
            toggle_fold = { "zA", "za" }, -- toggle fold of current file
            previous = "k",               -- previous item
            next = "j",                   -- next item
            help = "?"                    -- help menu
        },
        signs = {
            error = '✘',
            warning = '▲',
            hint = '⚑',
            information = '»',
            other = '»',
        },
    },
    config = function(_, opts)
        local trouble = require("trouble")
        local map = vim.keymap.set
        trouble.setup(opts)

        map("n", "<leader>xx", function() trouble.toggle() end)
        map("n", "<leader>xw", function() trouble.toggle("workspace_diagnostics") end)
        map("n", "<leader>xd", function() trouble.toggle("document_diagnostics") end)
        map("n", "<leader>xq", function() trouble.toggle("quickfix") end)
        map("n", "<leader>xl", function() trouble.toggle("loclist") end)
        map("n", "gR", function() trouble.toggle("lsp_references") end)
    end,
}
