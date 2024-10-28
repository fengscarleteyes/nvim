return {
  "stevearc/oil.nvim",
  opts = {
    view_options = {
      show_hidden = true,
    },
  },
  dependencies = { "nvim-tree/nvim-web-devicons" },
  -- stylua: ignore
  keys = {
    { "<F5>", mode = "n", function() require("oil").toggle_float() end, desc = "Oil toggle" },
  },
}
