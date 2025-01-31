return {
    "Exafunction/codeium.vim",
    event = "BufEnter",
    config = function()
        local keymap = vim.keymap

        keymap.set("i", "<C-g>", function()
            return vim.fn["codeium#Accept"]()
        end, { expr = true, silent = true })
        keymap.set("i", "<c-;>", function()
            return vim.fn["codeium#CycleCompletions"](1)
        end, { expr = true, silent = true })
        keymap.set("i", "<c-,>", function()
            return vim.fn["codeium#CycleCompletions"](-1)
        end, { expr = true, silent = true })
        keymap.set("i", "<c-x>", function()
            return vim.fn["codeium#Clear"]()
        end, { expr = true, silent = true })
    end,
}

-- return {
-- 	"monkoose/neocodeium",
-- 	event = "VeryLazy",
-- 	config = function()
-- 		local keymap = vim.keymap
-- 		local neocodeium = require("neocodeium")
-- 		neocodeium.setup()
--
-- 		keymap.set("i", "<C-g>", function()
-- 			return neocodeium.accept()
-- 		end, { expr = true, silent = true })
-- 	end,
-- }
