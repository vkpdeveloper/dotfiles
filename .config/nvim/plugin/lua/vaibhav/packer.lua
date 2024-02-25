return require('packer').startup(function(use)
    -- Packer can manage itself
    use 'wbthomason/packer.nvim'
    use {
        'nvim-telescope/telescope.nvim', tag = '0.1.4',
        requires = { {'nvim-lua/plenary.nvim'} },
        file_ignore_patterns = { "node_modules" }
    }
    use({
        'rose-pine/neovim',
        as = 'rose-pine',
        config = function()
            vim.cmd('colorscheme rose-pine')
        end
    })
    use('nvim-treesitter/nvim-treesitter', {run = ':TSUpdate'})
    use{ "williamboman/mason.nvim" }
    use {
        'nvim-lualine/lualine.nvim',
        requires = { 'nvim-tree/nvim-web-devicons', opt = true }
    }
    use {
        'lukas-reineke/indent-blankline.nvim',
        main = 'ibl',
        opts = {},
    }
    use{
        'numToStr/Comment.nvim',
        opts = {},
        config = function()
            require('Comment').setup()
        end
    }
    use("nvim-treesitter/nvim-treesitter-context");
    use {
        'VonHeikemen/lsp-zero.nvim',
        branch = 'v1.x',
        requires = {
            -- LSP Support
            {'neovim/nvim-lspconfig'},
            {'williamboman/mason.nvim'},
            {'williamboman/mason-lspconfig.nvim'},

            -- Autocompletion
            {'hrsh7th/nvim-cmp'},
            {'hrsh7th/cmp-buffer'},
            {'hrsh7th/cmp-path'},
            {'saadparwaiz1/cmp_luasnip'},
            {'hrsh7th/cmp-nvim-lsp'},
            {'hrsh7th/cmp-nvim-lua'},

            -- Snippets
            {'L3MON4D3/LuaSnip'},
            {'rafamadriz/friendly-snippets'},
        }
    }
    use("github/copilot.vim")
    use 'navarasu/onedark.nvim'
    use("tpope/vim-fugitive")
    use("Rigellute/shades-of-purple.vim")
    use({
        'projekt0n/github-nvim-theme',
    })
end)
