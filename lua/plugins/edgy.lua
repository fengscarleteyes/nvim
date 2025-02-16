return {
  "folke/edgy.nvim",
  event = "VeryLazy",
  -- enabled = false,
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
      {
        title = "Neo-Tree",
        ft = "neo-tree",
        filter = function(buf)
          return vim.b[buf].neo_tree_source == "filesystem"
        end,
        size = { height = 0.5 },
      },
    },
  },
}
