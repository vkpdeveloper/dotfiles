local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)
require("lazy").setup("vaibhav.plugins", {
    colorscheme = require("vaibhav.plugins.colorscheme"),
    change_detection = {
        enabled = false,
        notify = false
    },
    checker = {
        enabled = true,
        notify = false,
        concurrency = 1,
        frequency = 3600
    },
    ui = {
        border = "rounded",
    },
})
