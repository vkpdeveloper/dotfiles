return {
    'rmagatti/auto-session',
    lazy = false,
    ---enables autocomplete for opts
    ---@module "auto-session"
    ---@type AutoSession.Config
    opts = {
        suppressed_dirs = { '~/Downloads', '~/Documents' },
        auto_save = true,
        use_git_branch = true,
        continue_restore_on_error = false
    },
    keys = {
        -- Will use Telescope if installed or a vim.ui.select picker otherwise
        { '<leader>ss', '<cmd>SessionSearch<CR>',  desc = 'Session search' },
        { '<leader>sS', '<cmd>SessionSave<CR>',    desc = 'Save session' },
        -- { '<leader>sa', '<cmd>SessionToggleAutoSave<CR>', desc = 'Toggle autosave' },
        { '<leader>sr', '<cmd>SessionRestore<CR>', desc = 'Restore session' },
    },
}
