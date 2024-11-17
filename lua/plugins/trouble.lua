return {
  "folke/trouble.nvim",
  event = "VeryLazy",
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
        auto_close = true, -- auto close when there are no items
        auto_open = true, -- auto open when there are items
        groups = {
          { "filename", format = "{file_icon} {basename:Title} {count}" },
        },
      },
    },
  },
  cmd = "Trouble",
  dependencies = {
    "neovim/nvim-lspconfig",
  },
}
