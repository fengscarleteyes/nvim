return {
  "chrisgrieser/nvim-scissors",
  dependencies = "nvim-telescope/telescope.nvim",
  opts = {
    snippetDir = vim.fs.joinpath(vim.fn.stdpath("config"), "snippets"),
    jsonFormatter = "jq",
  },
}
