return {
    "ellisonleao/glow.nvim",
    config = true,
    cmd = "Glow",
    opts = {
        border = "rounded",
        style = "dark",
        height = 100,
        width = 150,
        width_ratio = 0.6, -- maximum width of the Glow window compared to the nvim window size (overrides `width`)
        height_ratio = 0.8,
    },
    keys = {
        { "<leader>gg", "<cmd>Glow<cr>", desc = "Glow" },
    },
}
