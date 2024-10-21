return {
  "stevearc/oil.nvim",
  ---@module 'oil'
  ---@type oil.SetupOpts
  opts = {
    view_options = {
      show_hidden = true,
    },
  },
  keys = {
    { '<F5>', mode = "n", function() require('oil').toggle_float() end, desc = "Oil toggle" },
  },
  dependencies = { "nvim-tree/nvim-web-devicons" },
}
