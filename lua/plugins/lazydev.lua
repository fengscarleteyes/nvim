-- https://github.com/folke/lazydev.nvim

vim.g.lazydev_enabled = true

return {
  "folke/lazydev.nvim",
  ft = "lua", -- only load on lua files
  -- enabled = false,
  opts = {
    library = {
      { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      "lazy.nvim",
      vim.env.VIMRUNTIME,
      vim.env.VIMRUNTIME .. "/lua",
      vim.env.VIMRUNTIME .. "/lua/vim",
      vim.env.VIMRUNTIME .. "/lua/vim/lsp",
    },
  },
}
