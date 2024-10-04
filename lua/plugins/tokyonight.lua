return {
  "folke/tokyonight.nvim",
  lazy = false,
  priority = 1000,
  opts = {},
  config = function()
    require('tokyonight').setup({ transparent = vim.g.transparent_enabled })
    vim.cmd('colorscheme tokyonight-night')
  end,
}
