return {
  "folke/edgy.nvim",
  enabled = false,
  event = "VeryLazy",
  init = function()
    vim.opt.laststatus = 3
    vim.opt.splitkeep = "screen"
  end,
  opts = {
    bottom = {
      "terminal",
      -- {
      --   ft = "terminal",
      --   size = { height = 0.4 },
      --   -- exclude floating windows
      --   filter = function(buf, win)
      --     return vim.api.nvim_win_get_config(win).relative == ""
      --   end,
      -- },
    },
  },
}
