return {
    "tpope/vim-fugitive",
    cmd = { "Git", "Gdiffsplit", "Gvdiffsplit" },
    lazy = false,
    config = function()
        -- thanks to @ThePrimeagen
        local Vaibhav_Fugitive = vim.api.nvim_create_augroup("vaibhav_fugitive", {})
        vim.keymap.set("n", "<C-G>", "<Cmd>Git<Cr>")

        local autocmd = vim.api.nvim_create_autocmd
        autocmd("BufWinEnter", {
            group = Vaibhav_Fugitive,
            pattern = "*",
            callback = function()
                if vim.bo.ft ~= "fugitive" then
                    return
                end

                local bufnr = vim.api.nvim_get_current_buf()
                local opts = { buffer = bufnr, remap = false }
                vim.keymap.set("n", "<leader>p", function()
                    vim.cmd.Git("push")
                end, opts)

                -- rebase always
                vim.keymap.set("n", "<leader>P", function()
                    vim.cmd.Git({ "pull --rebase" })
                end, opts)
            end,
        })
    end,
}
