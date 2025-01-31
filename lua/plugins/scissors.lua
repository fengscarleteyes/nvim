return {
  "chrisgrieser/nvim-scissors",
  dependencies = {
    "stevearc/dressing.nvim",
    "ibhagwan/fzf-lua",
  },
  opts = {
    snippetDir = vim.fn.stdpath("config") .. "/snippets",
  },
}
