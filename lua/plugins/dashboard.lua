return {
  "nvimdev/dashboard-nvim",
  lazy = true,
  enabled = false,
  event = "VimEnter",
  config = function()
    require("dashboard").setup({
      config = {
        project = { enable = false },
        mru = { enable = true, limit = 10, icon = "󰈔 ", label = "History", cwd_only = true },
        week_header = {
          enable = true,
        },
        shortcut = {
          { desc = "󰊳 Update", group = "@property", action = "Lazy update", key = "u" },
          { desc = "󰊳 Find", group = "@property", action = "FzfLua files", key = "f" },
          { desc = "󰊳 Quit", group = "@property", action = "qa", key = "q" },
        },
        footer = {},
      },
    })
  end,
  dependencies = { { "nvim-tree/nvim-web-devicons" } },
}
