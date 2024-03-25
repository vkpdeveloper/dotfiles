return {
    'nvim-treesitter/nvim-treesitter',
    build = ":TSUpdate",
    event = {
        'BufReadPre',
        'BufNewFile'
    },
    dependencies = {
        'nvim-treesitter/nvim-treesitter-textobjects'
    },
    config = function()
        require 'nvim-treesitter.configs'.setup {
            ensure_installed = { 'c', 'lua', 'vim', 'vimdoc', 'query', 'rust', 'go', 'javascript', 'typescript', 'python', 'markdown', 'html', 'css', 'json', 'yaml', 'toml', 'tsx', 'php' },
            sync_install = false,
            auto_install = true,
            highlight = {
                enable = true,
                additional_vim_regex_highlighting = {
                    'ruby',
                    'python'
                },
            },
            indent = {
                enable = true,
                disable = {
                    'ruby'
                },
            },
            incremental_selection = {
                enable = true,
                keymaps = {
                    init_selection = '<C-space>',
                    node_incremental = '<C-space>',
                    scope_incremental = false,
                    node_decremental = '<bs>',
                },
            },
        }
    end
}
