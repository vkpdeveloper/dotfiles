vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = true

vim.keymap.set("n", "<leader>w", vim.cmd.write)
vim.keymap.set("n", "U", vim.cmd.redo)

-- Diagnostic keymaps
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous [D]iagnostic message" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next [D]iagnostic message" })

-- Panes Controls
vim.keymap.set("n", "<leader>sv", vim.cmd.vsplit, { desc = "Open a vertical split" })
vim.keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" })
vim.keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" })

-- Panes navigation
vim.keymap.set("n", "<C-h>", "<C-W><C-h>", { desc = "Move focus to the left panes" })
vim.keymap.set("n", "<C-l>", "<C-W><C-l>", { desc = "Move focus to the right panes" })
vim.keymap.set("n", "<C-j>", "<C-W><C-j>", { desc = "Move focus to the lower panes" })
vim.keymap.set("n", "<C-k>", "<C-W><C-k>", { desc = "Move focus to the upper panes" })

-- Remaps for Tabbars
vim.keymap.set("n", "<leader>tx", vim.cmd.tabclose, { desc = "Close current tab" })
vim.keymap.set("n", "<leader>tn", vim.cmd.tabnew, { desc = "Open a new tab" })

-- Remap for moving to 1st to 6 tabs
vim.keymap.set("n", "<leader>t1", "1gt", { desc = "Go to tab 1" })
vim.keymap.set("n", "<leader>t2", "2gt", { desc = "Go to tab 2" })
vim.keymap.set("n", "<leader>t3", "3gt", { desc = "Go to tab 3" })
vim.keymap.set("n", "<leader>t4", "4gt", { desc = "Go to tab 4" })

-- TIP: Disable arrow keys in normal mode
vim.keymap.set("n", "<left>", '<cmd>echo "Use h to move!!"<CR>')
vim.keymap.set("n", "<right>", '<cmd>echo "Use l to move!!"<CR>')
vim.keymap.set("n", "<up>", '<cmd>echo "Use k to move!!"<CR>')
vim.keymap.set("n", "<down>", '<cmd>echo "Use j to move!!"<CR>')

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight when yanking (copying) text",
    group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
    callback = function()
        vim.highlight.on_yank()
    end,
})
