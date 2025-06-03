-- https://github.com/neovim/nvim-lspconfig

vim.lsp.enable({
  "taplo",
  "pyright",
  "ty",
  "ruff",
  "lua_ls",
})

return {
  "neovim/nvim-lspconfig",
  dependencies = "folke/lazydev.nvim",
  event = "BufEnter",
}

