return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  opts = {
    event_handlers = {
      {
        event = "file_moved",
        handler = function(data)
          require("snacks").rename.on_rename_file(data.source, data.destination)
        end,
      },
      {
        event = "file_renamed",
        handler = function(data)
          require("snacks").rename.on_rename_file(data.source, data.destination)
        end,
      },
    },
    source_selector = {
      winbar = false,
      statusline = false,
    },
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
    "MunifTanjim/nui.nvim",
    -- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
  },
}
