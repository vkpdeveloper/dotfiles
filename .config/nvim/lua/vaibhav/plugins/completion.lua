return {
    "hrsh7th/nvim-cmp",
    dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-cmdline",
        "hrsh7th/cmp-nvim-lsp-signature-help",
        "saadparwaiz1/cmp_luasnip",
        {
            "L3MON4D3/LuaSnip",
            version = "v2.*",
            build = "make install_jsregexp",
        },
        "onsails/lspkind.nvim",
    },
    event = "InsertEnter",
    config = function()
        local cmp = require("cmp")
        local luasnip = require("luasnip")
        local lspkind = require("lspkind")

        cmp.setup({
            mapping = cmp.mapping.preset.insert({
                ["<Tab>"] = cmp.mapping.select_next_item(),
                ["<S-Tab>"] = cmp.mapping.select_prev_item(),
            }),
            completion = {
                completeopt = "menu,menuone,preview,noselect",
            },
            snippet = { -- configure how nvim-cmp interacts with snippet engine
                expand = function(args)
                    luasnip.lsp_expand(args.body)
                end,
            },

            -- sources for autocompletion
            sources = cmp.config.sources({
                { name = "nvim_lsp" },
                { name = "cmp_nvim_lsp_signature_help" },
                { name = "luasnip" },
                { name = "buffer" },
                { name = "path" },
                { name = "supermaven" },
            }),

            -- configure lspkind for vs-code like pictograms in completion menu
            formatting = {
                format = lspkind.cmp_format({
                    maxwidth = 50,
                    ellipsis_char = "...",
                }),
            },
        })
    end,
}

-- return {
-- 	"saghen/blink.cmp",
-- 	version = "*",
-- 	---@module 'blink.cmp'
-- 	---@type blink.cmp.Config
-- 	opts = {
-- 		keymap = {
-- 			preset = "default",
--
-- 			["<Tab>"] = { "select_next", "fallback" },
-- 			["<S-Tab>"] = { "select_prev", "fallback" },
-- 		},
--
-- 		appearance = {
-- 			use_nvim_cmp_as_default = true,
-- 			nerd_font_variant = "mono",
-- 		},
-- 		sources = {
-- 			default = { "lsp", "path", "snippets", "buffer" },
-- 			cmdline = {},
-- 		},
-- 		signature = { enabled = true },
-- 	},
-- 	opts_extend = { "sources.default" },
-- }
