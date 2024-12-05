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
        filter = {
          any = {
            buf = 0, -- current buffer
            {
              severity = vim.diagnostic.severity.ERROR, -- errors only
              -- limit to files in the current project
              function(item)
                return item.filename:find((vim.loop or vim.uv).cwd(), 1, true)
              end,
            },
          },
        },
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
