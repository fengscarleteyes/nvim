return {
  "folke/flash.nvim",
  event = "VeryLazy",
  opts = {},
  config = function(_, opts)
    require("which-key").setup(opts)
  end,
  keys = {
    -- disable the default flash keymap
    { "s", mode = { "n", "x", "o" }, false },
    { "S", mode = { "n", "x", "o" }, false },
    { "r", mode = { "n", "x", "o" }, false },
    { "R", mode = { "n", "x", "o" }, false },
  },
}
