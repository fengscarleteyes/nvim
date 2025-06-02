-- https://github.com/neovim/nvim-lspconfig

return {
  "neovim/nvim-lspconfig",
  dependencies = "folke/lazydev.nvim",
  event = "BufEnter"
}