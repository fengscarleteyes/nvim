return {
  "folke/flash.nvim",
  event = "VeryLazy",
  opts = {},
  config = function(_, opts)
    require("which-key").setup(opts)
    -- require('which-key').register()
  end,
  -- keys = {
  --   -- disable the default flash keymap
  --   { "s", mode = { "n", "x", "o" }, false },
  -- },
}
