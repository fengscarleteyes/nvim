-- https://github.com/nvimdev/lspsaga.nvim
-- https://nvimdev.github.io/lspsaga/

return {
  "nvimdev/lspsaga.nvim",
  -- enabled = false,
  event = "LspAttach",
  -- ft = {'c','cpp', 'lua', 'rust', 'go'},
  config = function()
    require("lspsaga").setup({})
  end,
  dependencies = {
    "nvim-treesitter/nvim-treesitter", -- optional
    "nvim-tree/nvim-web-devicons", -- optional
    "neovim/nvim-lspconfig",
  },
}
