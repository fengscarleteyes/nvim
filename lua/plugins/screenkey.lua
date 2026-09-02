vim.pack.add({
  "https://github.com/NStefan002/screenkey.nvim",
})

local screenkey = require("screenkey")
screenkey.setup({
  win_opts = {
    width = 20,
    title = "",
    border = "none", -- "single",
  },
  clear_after = 1, -- seconds,
  disable = {
    filetypes = { "dashboard" },
    buftypes = {},
    modes = {},
  },
})

screenkey.toggle_statusline_component()
