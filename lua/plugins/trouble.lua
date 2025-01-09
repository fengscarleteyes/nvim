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
        groups = {
          { "filename", format = "{file_icon} {basename:Title} {count}" },
        },
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
    local actions = require("telescope.actions")
    local open_with_trouble = require("trouble.sources.telescope").open

    -- Use this to add more results without clearing the trouble list
    local add_to_trouble = require("trouble.sources.telescope").add

    local telescope = require("telescope")

    telescope.setup({
      defaults = {
        mappings = {
          i = { ["<c-t>"] = open_with_trouble },
          n = { ["<c-t>"] = open_with_trouble },
        },
      },
    })
  end,
}
