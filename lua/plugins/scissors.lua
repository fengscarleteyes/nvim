return {
  "chrisgrieser/nvim-scissors",
  dependencies = {
    -- "L3MON4D3/LuaSnip",
    "nvim-telescope/telescope.nvim",
  },
  opts = {
    snippetDir = vim.fn.stdpath("config") .. "/snippets",
    jsonFormatter = "jq",
  },
}
