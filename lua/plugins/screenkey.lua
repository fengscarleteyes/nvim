-- https://github.com/NStefan002/screenkey.nvim

return {
  "NStefan002/screenkey.nvim",
  enabled = false,
  lazy = false,
  -- version = "main"
  opts = {
    win_opts = {
      width = 20,
      title = "",
      border = "none", -- "single",
    },
    clear_after = 1, -- seconds
  },
}
