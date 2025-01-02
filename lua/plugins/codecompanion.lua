-- TODO: add more details about this plugin
-- https://github.com/olimorris/codecompanion.nvim
return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    { "MeanderingProgrammer/render-markdown.nvim", ft = { "markdown", "codecompanion" } },
  },
  opts = { language = "Chinese" },
  config = true,
}
