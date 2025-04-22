return {
    'rmagatti/auto-session',
    lazy = false,
    keys = {
        { '<leader>ss', '<cmd>SessionSearch<CR>', desc = 'Session search' },
        { '<leader>sc', '<cmd>SessionSave<CR>',   desc = 'Save session' },
    },

    ---enables autocomplete for opts
    ---@module "auto-session"
    ---@type AutoSession.Config
    opts = {
        auto_save = true,
        auto_restore = true,
        auto_create = true,
        auto_restore_last_session = true,
        use_git_branch = true,
        cwd_change_handling = true,
        suppressed_dirs = { '~/Downloads' },
        session_lens = {
            load_on_setup = true,
            previewer = false,
            mappings = {
                delete_session = { "i", "<C-D>" },
                alternate_session = { "i", "<C-S>" },
                copy_session = { "i", "<C-Y>" },
            },
            theme_conf = {
                border = true,
            },
        },
    }
}
