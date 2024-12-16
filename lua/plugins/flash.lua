return {
  "folke/flash.nvim",
  event = "VeryLazy",
  opts = {},
  keys = {
    -- disable the default flash keymap
    { "s", mode = { "n", "x", "o" }, false },
    { "S", mode = { "n", "x", "o" }, false },
    { "r", mode = { "n", "x", "o" }, false },
    { "R", mode = { "n", "x", "o" }, false },
    { "t", mode = { "n", "x", "o" }, false },
    { "T", mode = { "n", "x", "o" }, false },
  },
}
