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
        mode = "diagnostics",
        filter = { buf = 0 },
        auto_open = true,
        auto_close = true,
        preview = {
          type = "float",
          relative = "editor",
          border = "rounded",
          title = "Preview",
          title_pos = "center",
          position = { 0, -2 },
          size = { width = 0.3, height = 0.3 },
          zindex = 200,
        },
      },
    },
    -- keys = false -- disable default keybindings
  },
  config = function(_, opts)
    require("trouble").setup(opts)
  end,
}
