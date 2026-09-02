-- NOTE: This requires Neovim version 0.12 and greater!
vim.pack.add({ {
    src = "https://github.com/kylechui/nvim-surround",
    version = vim.version.range("4.x"), -- Use for stability; omit to use `main` branch for the latest features
} })

vim.g.nvim_surround_no_mappings = true

-- Optional: See `:h nvim-surround.configuration` and `:h nvim-surround.setup` for details
require("nvim-surround").setup({})

-- command
-- <Plug>(nvim-surround-insert)
-- <Plug>(nvim-surround-insert-line)
-- <Plug>(nvim-surround-normal)
-- <Plug>(nvim-surround-normal-cur)
-- <Plug>(nvim-surround-normal-line)
-- <Plug>(nvim-surround-normal-cur-line)
-- <Plug>(nvim-surround-visual)
-- <Plug>(nvim-surround-visual-line)
-- <Plug>(nvim-surround-delete)
-- <Plug>(nvim-surround-change)
-- <Plug>(nvim-surround-change-line)
