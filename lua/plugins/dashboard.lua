-- https://github.com/nvimdev/dashboard-nvim

return {
  "nvimdev/dashboard-nvim",
  event = "VimEnter",
  -- enabled = false,
  config = function()
    require("dashboard").setup({
      shortcut_type = "number",
      theme = "hyper",
      hide = {
        statusline = true, -- hide statusline default is true
        tabline = true, -- hide the tabline
        winbar = true, -- hide winbar
      },
      config = {
        header = {},
        shortcut = {
          -- action can be a function type
          { desc = "Lazy update", key = "U", action = "Lazy update" },
          { desc = "Mason", key = "M", action = "Mason" },
        },
        packages = { enable = true },
        project = { enable = true, limit = 5 },
        mru = { enable = true, limit = 10, cwd_only = false },
        footer = {},
      },
    })
  end,
  dependencies = {"nvim-tree/nvim-web-devicons" },
}
