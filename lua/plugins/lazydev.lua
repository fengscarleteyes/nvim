-- https://github.com/folke/lazydev.nvim

vim.g.lazydev_enabled = true

return {
  "folke/lazydev.nvim",
  ft = "lua", -- only load on lua files
  opts = {
    library = {
      { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      "lazy.nvim",
    },
  },
}
