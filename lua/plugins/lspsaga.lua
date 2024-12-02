return {
  "nvimdev/lspsaga.nvim",
  config = function()
    require("lspsaga").setup({
      -- TODO: this
    })
  end,
  dependencies = {
    "nvim-treesitter/nvim-treesitter", -- optional
    "nvim-tree/nvim-web-devicons", -- optional
  },
}
