-- https://github.com/ibhagwan/fzf-lua
return {
  "ibhagwan/fzf-lua",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
    "nvim-treesitter/nvim-treesitter-context",
    "MeanderingProgrammer/render-markdown.nvim",
    "mfussenegger/nvim-dap",
  },
  opts = { winopts = { fullscreen = true, treesitter = {
    enabled = true,
  } } },
}
