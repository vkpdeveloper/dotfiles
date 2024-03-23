return {
    "projekt0n/github-nvim-theme",
    lazy = false,
    name = "github-dark",
    priority = 1000,
    config = function()
        require('github-theme').setup({})
        vim.cmd([[colorscheme github_dark_colorblind]])
    end
}
