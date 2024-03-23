return {
    'nvim-treesitter/nvim-treesitter',
    build = ":TSUpdate",
    config = function()
        require'nvim-treesitter.configs'.setup {
            ensure_installed = { 'c', 'lua', 'vim', 'vimdoc', 'query', 'rust', 'go', 'javascript', 'typescript', 'python', 'markdown', 'html', 'css', 'json', 'yaml', 'toml' },
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
            }
        }
    end
}
