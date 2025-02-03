return {
  "nvimdev/lspsaga.nvim",
  event = "LspAttach",
  -- ft = {'c','cpp', 'lua', 'rust', 'go'},
  config = function()
    require("lspsaga").setup({})
  end,
  dependencies = {
    "nvim-treesitter/nvim-treesitter", -- optional
    "nvim-tree/nvim-web-devicons", -- optional
  },
}
