-- TODO: add handle enable & delete other plugin like Fterm,noice ...
return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    bigfile = { enabled = true },
    bufdelete = { enabled = true },
    dashboard = { enabled = false },
    notifier = { enabled = true },
    -- noitfy = { enabled = true },
    -- quickfile = { enabled = true },
    -- statuscolumn = { enabled = true },
    -- words = { enabled = true },
    -- lazygit = { enabled = true },
  },
}
