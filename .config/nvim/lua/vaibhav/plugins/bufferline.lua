return {
    'akinsho/bufferline.nvim',
    version = "*",
    event = {
        'TabNew',
        'TabClosed',
        'BufReadPre',
        'BufNewFile'
    },
    dependencies = {
        'nvim-tree/nvim-web-devicons'
    },
    config = function()
        require('bufferline').setup {}
    end
}
