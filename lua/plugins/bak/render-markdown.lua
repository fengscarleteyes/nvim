vim.pack.add({
    'https://github.com/nvim-treesitter/nvim-treesitter',
    'https://github.com/nvim-tree/nvim-web-devicons', -- if you prefer nvim-web-devicons
    'https://github.com/MeanderingProgrammer/render-markdown.nvim',
})
require('render-markdown').setup({
    latex = { enabled = false },
    yaml = { enabled = false },
    html = { enabled = false },
}) -- only mandatory if you want to set custom options

-- other
-- https://github.com/brianhuster/live-preview.nvim