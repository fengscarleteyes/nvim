return {
  "stevearc/oil.nvim",
  -- enabled = false,
  opts = {
    -- use_default_keymaps = false,
    columns = {
      "icon",
      "permissions",
      "size",
      "mtime",
    },
    view_options = {
      show_hidden = true,
    },
  },
  dependencies = { "nvim-tree/nvim-web-devicons" },
}
