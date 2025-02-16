return {
  "folke/edgy.nvim",
  event = "VeryLazy",
  init = function()
    vim.opt.laststatus = 3
    vim.opt.splitkeep = "screen"
  end,
  opts = {
    bottom = {
      "Trouble",
      {
        ft = "neaterm",
        size = { height = 0.3 },
      },
    },
    left = {
      -- Neo-tree filesystem always takes half the screen height
    },
  },
}
