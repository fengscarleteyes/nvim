return {
  "folke/trouble.nvim",
  cmd = "Trouble",
  event = "LspAttach",
  opts = {
    icons = {
      indent = {
        middle = " ",
        last = " ",
        top = " ",
        ws = "│  ",
      },
    },
    modes = {
      diagnostics = {
        groups = {
          { "filename", format = "{file_icon} {basename:Title} {count}" },
        },
        auto_open = true,
        auto_close = true,
      },
    },
    -- keys = false -- disable default keybindings
  },
}
