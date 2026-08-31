vim.pack.add({
  'https://github.com/folke/tokyonight.nvim',
})

require("tokyonight").setup({ transparent = vim.g.transparent_enabled })

vim.cmd("colorscheme tokyonight-night")
