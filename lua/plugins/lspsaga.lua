return {
  "nvimdev/lspsaga.nvim",
  -- enabled = false,
  config = function()
    require("lspsaga").setup({})
  end,
  dependencies = {
    "nvim-treesitter/nvim-treesitter", -- optional
    "nvim-tree/nvim-web-devicons", -- optional
  },
  -- stylua: ignore
  keys = {
    { '<F7>', mode = "n", "<cmd> Lspsaga hover_doc <CR>", desc = "Lspsaga hover_doc" },
  },
}
