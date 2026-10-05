-- 已停用（放在 bak/ 里不会被 plugins.lua 的 :runtime! lua/plugins/*.lua 加载，见 lua/plugins.lua 约定 3）
-- 启动仪表盘改由 lua/custom/dashboard.lua 实现（自带历史文件数字键 + 快捷功能 + 自带配色），
-- 下面的配置内容已全部搬到该模块的 DEFAULTS.shortcuts，保留此文件仅供对照 / 回退。
vim.pack.add({
  "https://github.com/nvimdev/dashboard-nvim",
  "https://github.com/nvim-tree/nvim-web-devicons",
})

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
      {
        desc = "vim pack update",
        key = "u",
        action = function()
          vim.pack.update()
        end,
        icon = "󰚰",
      },
      { desc = "Mason", key = "m", action = "Mason", icon = "  " },
      {
        desc = "Lazygit",
        key = "g",
        action = function()
          require("custom.terminal").run("lazygit")
        end,
        icon = "  ",
      },
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
