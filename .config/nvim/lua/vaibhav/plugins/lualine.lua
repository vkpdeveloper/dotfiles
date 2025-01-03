return {
    "nvim-lualine/lualine.nvim",
    dependencies = {
        "nvim-tree/nvim-web-devicons",
    },
    lazy = false,
    config = function()
        require("lualine").setup({
            options = {
                icons_enabled = true,
                theme = "ayu_dark",
                component_separators = { left = "", right = "" },
                section_separators = { left = "", right = "" },
                disabled_filetypes = {
                    statusline = {},
                    winbar = {},
                },
                ignore_focus = {},
                always_divide_middle = true,
                globalstatus = false,
                refresh = {
                    statusline = 100,
                    tabline = 100,
                    winbar = 100,
                },
            },
            sections = {
                lualine_a = { "mode" },
                lualine_b = { "diff", "diagnostics" },
                lualine_c = { "filename" },
                lualine_x = { "branch" },
                lualine_y = { "searchcount", "filetype" },
                lualine_z = { "location" },
            },
            inactive_sections = {
                lualine_a = { "mode" },
                lualine_b = {},
                lualine_c = {},
                lualine_x = { "branch" },
                lualine_y = {},
                lualine_z = {},
            },
            tabline = {},
            winbar = {},
            inactive_winbar = {},
            extensions = {},
        })
    end,
}
