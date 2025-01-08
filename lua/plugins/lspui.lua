return {
  "jinzhongjia/LspUI.nvim",
  -- enabled = false,
  branch = "main",
  dependencies = { "neovim/nvim-lspconfig" },
  config = function()
    require("LspUI").setup({})
  end,
}
-- TODO:
-- https://github.com/DNLHC/glance.nvim
