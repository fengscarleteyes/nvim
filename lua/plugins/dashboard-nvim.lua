-- https://github.com/nvimdev/dashboard-nvim

return {
  "nvimdev/dashboard-nvim",
  event = "VimEnter",
  -- enabled = false,
  config = function()
    require("dashboard").setup({
      theme = "hyper",
      disable_move = true,
      shortcut_type = "number",
      hide = {
        statusline = true, -- hide statusline default is true
        tabline = true, -- hide the tabline
        winbar = true, -- hide winbar
      },
      config = {
        header = {},
        week_header = { enable = false },
        disable_move = true,
        shortcut = {
          -- action can be a function type
          { desc = "Lazy update", key = "u", action = "Lazy update", icon = "  " },
          { desc = "Mason", key = "m", action = "Mason", icon = "  " },
          { desc = "Lazygit", key = "g", action = "Fterm lazygit", icon = "  " },
          -- { desc = "Fzf Live Grep", key = "G", action = "FzfLua live_grep" },
          { desc = "Fzf Files", key = "f", action = "FzfLua files", icon = "  " },
          { desc = "Fzf colorschemes", key = "c", action = "FzfLua colorschemes", icon = "  " },
          { desc = "Quit", key = "q", action = "q", icon = " 󰿅 " },
        },
        packages = { enable = true },
        project = { enable = false, limit = 5 },
        mru = { enable = true, limit = 15, cwd_only = false },
        footer = {},
      },
    })
  end,
  dependencies = { "nvim-tree/nvim-web-devicons" },
}
