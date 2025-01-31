return {
  "nvimdev/dashboard-nvim",
  lazy = true,
  event = "VimEnter",
  config = function()
    require("dashboard").setup({
      config = {
        project = { enable = false },
        -- week_header = {
        --   enable = true,
        -- },
        shortcut = {
          { desc = "󰊳 Update", group = "@property", action = "Lazy update", key = "u" },
          { desc = "󰊳 Find", group = "@property", action = "FzfLua files", key = "f" },
        },
      },
    })
  end,
  dependencies = { { "nvim-tree/nvim-web-devicons" } },
}
